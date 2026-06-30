<#
.SYNOPSIS
    Promote content between two Fabric deployment pipeline stages.

.DESCRIPTION
    Used for the Non-Prod and Prod "fabric deploy" steps: Non-Prod deploys the Dev
    stage content into the Test (Non-Prod) stage, and Prod deploys the Test stage
    content into the Production stage.

    The deployment pipeline definition (stages and their workspace assignments) is
    managed by Terraform. This script performs the imperative deploy action via the
    Fabric 'Deployment Pipelines - Deploy' REST API.

    Required environment variables:
      FABRIC_PIPELINE_ID     The deployment pipeline ID (Terraform output).
      FABRIC_STAGES_JSON     JSON array of stages from Terraform output
                             (each item has display_name and id).
      FABRIC_SOURCE_STAGE    Display name of the source stage (e.g. 'Development').
      FABRIC_TARGET_STAGE    Display name of the target stage (e.g. 'Test').
      FABRIC_TOKEN           Bearer token for the Fabric API.

    Optional environment variables:
      FABRIC_DEPLOY_NOTE     Note attached to the deployment.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/FabricApi.ps1"

function Get-RequiredEnv {
    param([Parameter(Mandatory)][string]$Name)
    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($value)) {
        Write-Error "required environment variable '$Name' is not set."
        exit 1
    }
    return $value
}

function Get-StageId {
    param(
        [Parameter(Mandatory)]$Stages,
        [Parameter(Mandatory)][string]$DisplayName
    )
    foreach ($stage in $Stages) {
        if ($stage.display_name -eq $DisplayName) {
            if ([string]::IsNullOrWhiteSpace($stage.id)) {
                Write-Error "stage '$DisplayName' has no id in the Terraform output."
                exit 1
            }
            return $stage.id
        }
    }
    $names = ($Stages | ForEach-Object { $_.display_name }) -join ', '
    Write-Error "stage '$DisplayName' not found in pipeline stages: $names"
    exit 1
}

$pipelineId = Get-RequiredEnv 'FABRIC_PIPELINE_ID'
$stagesJson = Get-RequiredEnv 'FABRIC_STAGES_JSON'
$sourceStage = Get-RequiredEnv 'FABRIC_SOURCE_STAGE'
$targetStage = Get-RequiredEnv 'FABRIC_TARGET_STAGE'
$note = if ($env:FABRIC_DEPLOY_NOTE) { $env:FABRIC_DEPLOY_NOTE } else { "Deploy $sourceStage -> $targetStage" }

$stages = $stagesJson | ConvertFrom-Json
$sourceStageId = Get-StageId -Stages $stages -DisplayName $sourceStage
$targetStageId = Get-StageId -Stages $stages -DisplayName $targetStage

Write-Host "Deploying pipeline '$pipelineId': '$sourceStage' ($sourceStageId) -> '$targetStage' ($targetStageId)."

$body = @{
    sourceStageId = $sourceStageId
    targetStageId = $targetStageId
    note          = $note
}

$response = Invoke-FabricRequest -Method 'POST' -Path "/deploymentPipelines/$pipelineId/deploy" -Body $body
Wait-FabricOperation -Response $response

Write-Host 'Deployment pipeline promotion completed successfully.'
