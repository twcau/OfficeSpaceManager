param (
    [int]$DaysOld = 30
)

Render-PanelHeader -Title "Clear Old Log Files"

$logFolder = ".\Logs"
$cutoff = (Get-Date).AddDays(-$DaysOld)
$oldLogs = Get-ChildItem $logFolder -Filter "*.log" | Where-Object { $_.LastWriteTime -lt $cutoff }

if ($oldLogs.Count -eq 0) {
    Write-Host "✅ No logs older than $DaysOld days to delete." -ForegroundColor Green
    return
}

Write-Host "`n⚠️ $($oldLogs.Count) log files found older than $DaysOld days."
$compressFirst = Read-Host "Do you want to compress them before deleting? (Y/N)"
if ($compressFirst -eq 'Y') {
    . "$PSScriptRoot\Compress-Logs.ps1" -DaysOld $DaysOld
}

$confirm = Read-Host "Are you absolutely sure you want to delete these logs? Type DELETE to confirm"

if ($confirm -eq "DELETE") {
    $oldLogs | Remove-Item -Force
    Write-Host "🧹 Logs deleted successfully." -ForegroundColor Yellow
    Write-Log "Deleted $($oldLogs.Count) logs older than $DaysOld days"
} else {
    Write-Host "❌ Deletion cancelled. Logs retained." -ForegroundColor Cyan
}
