# Load Shared Connection Logic
. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    return
}

function Run-TestSuite {
    Render-PanelHeader -Title "OfficeSpaceManager - Run Full Test Suite"

    $logFolder = ".\TestResults"
    if (!(Test-Path $logFolder)) { New-Item -Path $logFolder -ItemType Directory | Out-Null }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $logFile = "$logFolder\TestLog-$timestamp.log"
Write-Log -Message "Logging test results to: $logFile`n" -Level 'INFO'

    . "$PSScriptRoot\Test-DeskProvisioning.ps1"     2>&1 | Tee-Object -FilePath $logFile -Append
    . "$PSScriptRoot\Test-RoomProvisioning.ps1"     2>&1 | Tee-Object -FilePath $logFile -Append
    . "$PSScriptRoot\Test-MailboxSettings.ps1"      2>&1 | Tee-Object -FilePath $logFile -Append

    Write-Host "`nÃ¢Å“â€¦ Test Suite Completed. Review log at: $logFile"
}
Run-TestSuite




