<#
.SYNOPSIS
    Runs the full OfficeSpaceManager test suite and logs results.
.DESCRIPTION
    This script executes all major test scripts (desk provisioning, room provisioning, mailbox settings) and logs results to a timestamped file in the TestResults folder. Intended for regression and integration testing.
.FILECREATED
    2023-07-01
.FILELASTUPDATED
    2025-07-23
.OUTPUTS
    Test results are logged to a file in .\TestResults.
.EXAMPLE
    .\Run-TestSuite.ps1
    # Runs all test scripts and logs results.
#>

# Load shared modules and error handling
. (Join-Path $PSScriptRoot '..\Modules\Utilities\Resolve-OfficeSpaceManagerRoot.ps1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\Utilities\Utilities.psm1')
. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"

$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    return
}

Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\CLI\CLI.psm1')

function Run-TestSuite {
    <#
    .SYNOPSIS
        Executes all major test scripts and logs results.
    .DESCRIPTION
        Runs desk provisioning, room provisioning, and mailbox settings tests, logging all output to a timestamped file.
    .OUTPUTS
        None. Results are logged to file.
    #>
    Display-PanelHeader -Title "OfficeSpaceManager - Run Full Test Suite"

    $logFolder = ".\TestResults"
    if (!(Test-Path $logFolder)) { New-Item -Path $logFolder -ItemType Directory | Out-Null }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $logFile = "$logFolder\TestLog-$timestamp.log"
    Write-Log -Message "Logging test results to: $logFile`n" -Level 'INFO'

    # Execute test scripts and log output
    . "$PSScriptRoot\Test-DeskProvisioning.ps1"     2>&1 | Tee-Object -FilePath $logFile -Append
    . "$PSScriptRoot\Test-RoomProvisioning.ps1"     2>&1 | Tee-Object -FilePath $logFile -Append
    . "$PSScriptRoot\Test-MailboxSettings.ps1"      2>&1 | Tee-Object -FilePath $logFile -Append

    Write-Host "`n4e2 Test Suite Completed. Review log at: $logFile"
}

Run-TestSuite

Invoke-FirstTimeSetup




