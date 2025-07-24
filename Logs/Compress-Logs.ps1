param (
    [int]$DaysOld = 7
)

Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\CLI\CLI.psm1')
Get-PanelHeader -Title "Compress Old Logs"

$logFolder = ".\Logs"
$archiveFolder = "$logFolder\Archive"
if (!(Test-Path $archiveFolder)) { New-Item -ItemType Directory -Path $archiveFolder | Out-Null }

$cutoff = (Get-Date).AddDays(-$DaysOld)
$oldLogs = Get-ChildItem $logFolder -Filter "*.log" | Where-Object { $_.LastWriteTime -lt $cutoff }

if ($oldLogs.Count -eq 0) {
    Write-Host "✅ No logs older than $DaysOld days found." -ForegroundColor Green
    return
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$zipPath = "$archiveFolder\LogsBackup-$timestamp.zip"

Write-Host "`nStarting log compression..." -ForegroundColor Cyan

Compress-Archive -Path $oldLogs.FullName -DestinationPath $zipPath -Force

Write-Host ("`n✅ Log compression complete. Output file: {0}" -f $zipPath) -ForegroundColor Green
# Pause for user review
Read-Host "`nPress Enter to return to the main menu."
Write-Log "Compressed old logs to $zipPath"
