param (
    [int]$DaysOld = 7
)

Render-PanelHeader -Title "Compress Old Logs"

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

Compress-Archive -Path $oldLogs.FullName -DestinationPath $zipPath -Force

Write-Host "✅ Compressed $($oldLogs.Count) logs to archive: $zipPath" -ForegroundColor Green
Write-Log "Compressed old logs to $zipPath"
