<#
.SYNOPSIS
    Trigger a Fabric 'Update From Git' to sync the Dev workspace with Azure DevOps.

.DESCRIPTION
    The Dev workspace is connected to the ADO repository by Terraform
    (fabric_workspace_git). This script pulls the latest committed content from the
    tracked branch into the workspace, which is the Dev environment's "fabric deploy".

    Required environment variables:
      FABRIC_WORKSPACE_ID  The Dev workspace ID.
      FABRIC_TOKEN         Bearer token for the Fabric API.

    Optional environment variables:
      FABRIC_GIT_CONFLICT_POLICY  Conflict resolution policy when workspace and Git
                                  diverge. One of 'PreferRemote' (default) or
                                  'PreferWorkspace'.
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

$workspaceId = Get-RequiredEnv 'FABRIC_WORKSPACE_ID'
$conflictPolicy = if ($env:FABRIC_GIT_CONFLICT_POLICY) { $env:FABRIC_GIT_CONFLICT_POLICY } else { 'PreferRemote' }

# Determine the current Git status (remote and workspace head commits).
$status = (Invoke-FabricRequest -Method 'GET' -Path "/workspaces/$workspaceId/git/status").Content | ConvertFrom-Json
$remoteCommitHash = $status.remoteCommitHash
$workspaceHead = $status.workspaceHead

if ([string]::IsNullOrWhiteSpace($remoteCommitHash)) {
    Write-Host 'No remote commit found for the workspace; nothing to sync.'
    exit 0
}

if ($remoteCommitHash -eq $workspaceHead) {
    Write-Host 'Workspace is already up to date with Git. Nothing to sync.'
    exit 0
}

Write-Host "Updating workspace '$workspaceId' from Git (workspaceHead=$workspaceHead -> remoteCommitHash=$remoteCommitHash)."

$body = @{
    remoteCommitHash   = $remoteCommitHash
    workspaceHead      = $workspaceHead
    conflictResolution = @{
        conflictResolutionType   = 'Workspace'
        conflictResolutionPolicy = $conflictPolicy
    }
    options            = @{
        allowOverrideItems = $true
    }
}

$response = Invoke-FabricRequest -Method 'POST' -Path "/workspaces/$workspaceId/git/updateFromGit" -Body $body
Wait-FabricOperation -Response $response

Write-Host 'Workspace successfully updated from Git.'
