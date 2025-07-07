function Run-TestSuite {
    Render-PanelHeader -Title "OfficeSpaceManager - Run Full Test Suite"

    $logFolder = ".\TestResults"
    if (!(Test-Path $logFolder)) { New-Item -Path $logFolder -ItemType Directory | Out-Null }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $logFile = "$logFolder\TestLog-$timestamp.log"
    Write-Host "Logging test results to: $logFile`n"

    . "$PSScriptRoot\Test-DeskProvisioning.ps1"     2>&1 | Tee-Object -FilePath $logFile -Append
    . "$PSScriptRoot\Test-RoomProvisioning.ps1"     2>&1 | Tee-Object -FilePath $logFile -Append
    . "$PSScriptRoot\Test-MailboxSettings.ps1"      2>&1 | Tee-Object -FilePath $logFile -Append

    Write-Host "`n✅ Test Suite Completed. Review log at: $logFile"
}
Run-TestSuite
