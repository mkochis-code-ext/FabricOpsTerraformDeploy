<#
.SYNOPSIS
    Shared helpers for calling the Microsoft Fabric REST API.

.DESCRIPTION
    Authentication uses a bearer token supplied via the FABRIC_TOKEN environment
    variable. In Azure DevOps this token is produced by the AzureCLI@2 task using:

        az account get-access-token --resource https://api.fabric.microsoft.com --query accessToken -o tsv

    The helpers handle Fabric's long-running operation (LRO) pattern: a 202 response
    returns an operation URL that must be polled until the operation completes.

    Dot-source this file to import the functions:

        . "$PSScriptRoot/FabricApi.ps1"
#>

Set-StrictMode -Version Latest

$script:FabricBaseUrl = 'https://api.fabric.microsoft.com/v1'
$script:FabricTimeoutSec = 120

function Get-FabricToken {
    $token = $env:FABRIC_TOKEN
    if ([string]::IsNullOrWhiteSpace($token)) {
        Write-Error 'FABRIC_TOKEN environment variable is not set.'
        exit 1
    }
    return $token
}

function Get-FabricHeaders {
    return @{
        Authorization  = "Bearer $(Get-FabricToken)"
        'Content-Type' = 'application/json'
    }
}

function Get-FabricHeaderValue {
    param(
        [Parameter(Mandatory)]$Headers,
        [Parameter(Mandatory)][string]$Name
    )
    if (-not $Headers.ContainsKey($Name)) {
        return $null
    }
    $value = $Headers[$Name]
    if ($value -is [System.Array]) {
        return $value[0]
    }
    return $value
}

function Invoke-FabricRequest {
    <#
    .SYNOPSIS
        Issue a request against the Fabric API. `Path` is relative to the base URL.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][string]$Path,
        [object]$Body
    )

    $url = if ($Path -like 'http*') { $Path } else { "$script:FabricBaseUrl$Path" }

    $params = @{
        Method             = $Method
        Uri                = $url
        Headers            = Get-FabricHeaders
        TimeoutSec         = $script:FabricTimeoutSec
        SkipHttpErrorCheck = $true
    }
    if ($null -ne $Body) {
        $params.Body = ($Body | ConvertTo-Json -Depth 10)
    }

    $response = Invoke-WebRequest @params
    if ([int]$response.StatusCode -ge 400) {
        Write-Error "ERROR: $Method $url failed with $($response.StatusCode): $($response.Content)"
        exit 1
    }
    return $response
}

function Wait-FabricOperation {
    <#
    .SYNOPSIS
        Poll a long-running operation until it succeeds, throwing on failure.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Response
    )

    if ([int]$Response.StatusCode -ne 202) {
        return
    }

    $operationUrl = Get-FabricHeaderValue -Headers $Response.Headers -Name 'Location'
    if ([string]::IsNullOrWhiteSpace($operationUrl)) {
        return
    }

    $retryAfter = Get-FabricHeaderValue -Headers $Response.Headers -Name 'Retry-After'
    $retryAfter = if ($retryAfter) { [int]$retryAfter } else { 5 }

    while ($true) {
        Start-Sleep -Seconds $retryAfter

        $poll = Invoke-WebRequest -Method Get -Uri $operationUrl -Headers (Get-FabricHeaders) -TimeoutSec $script:FabricTimeoutSec
        $payload = $poll.Content | ConvertFrom-Json
        $status = $payload.status

        if ($status -in @('Succeeded', 'Completed')) {
            return
        }
        if ($status -in @('Failed', 'Cancelled')) {
            throw "Fabric operation $status`: $($poll.Content)"
        }

        $next = Get-FabricHeaderValue -Headers $poll.Headers -Name 'Retry-After'
        if ($next) {
            $retryAfter = [int]$next
        }
    }
}
