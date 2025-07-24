param (
    [int]$DaysOld = 30
)

Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\CLI\CLI.psm1')
Get-PanelHeader -Title "Clear Old Log Files"

$logFolder = ".\Logs"
$cutoff = (Get-Date).AddDays(-$DaysOld)
$oldLogs = Get-ChildItem $logFolder -Filter "*.log" | Where-Object { $_.LastWriteTime -lt $cutoff }

if ($oldLogs.Count -eq 0) {
    Write-Host "✅ No logs older than $DaysOld days to delete." -ForegroundColor Green
    Read-Host "`nPress Enter to return to the main menu."
    return
}

Write-Host ("`n⚠️ {0} log files found older than {1} days." -f $oldLogs.Count, $DaysOld)
$defaultCompress = 'Y'
$compressFirst = Read-Host ("Do you want to compress them before deleting? (Y/N) [Default: {0}]" -f $defaultCompress)
if ([string]::IsNullOrWhiteSpace($compressFirst)) { $compressFirst = $defaultCompress }
if ($compressFirst.ToUpper() -eq 'Y') {
    . "$PSScriptRoot\Compress-Logs.ps1" -DaysOld $DaysOld
}

$defaultConfirm = 'CANCEL'
$confirm = Read-Host ("Are you absolutely sure you want to delete these logs? Type DELETE to confirm [Default: {0}]" -f $defaultConfirm)
if ([string]::IsNullOrWhiteSpace($confirm)) { $confirm = $defaultConfirm }
if ($confirm -eq "DELETE") {
    Write-Host "`nClearing log history..." -ForegroundColor Cyan
    # (Insert progress bar logic here if deletion is lengthy)
    $oldLogs | Remove-Item -Force
    Write-Host ("`n✅ Log history cleared. {0} files removed." -f $filesRemoved) -ForegroundColor Green
    Read-Host "`nPress Enter to return to the main menu."
    Write-Host "🧹 Logs deleted successfully." -ForegroundColor Yellow
    Write-Log "Deleted $($oldLogs.Count) logs older than $DaysOld days"
}
else {
    Write-Host "❌ Deletion cancelled. Logs retained." -ForegroundColor Cyan
}
