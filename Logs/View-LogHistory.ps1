Render-PanelHeader -Title "View Log Files"

$logFiles = Get-ChildItem ".\Logs" -Filter "*.log" | Sort-Object LastWriteTime -Descending
if ($logFiles.Count -eq 0) {
    Write-Host "❌ No logs found in the Logs folder." -ForegroundColor Yellow
    return
}

$selected = $logFiles | Select-Object Name, LastWriteTime | Out-GridView -Title "Select a log to view" -PassThru
if (-not $selected) { return }

$path = ".\Logs\$($selected.Name)"
Write-Host "`nContents of $($selected.Name):" -ForegroundColor Cyan
Get-Content $path | Out-Host
Write-Log "Viewed log file: $($selected.Name)"
