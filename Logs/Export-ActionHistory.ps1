Render-PanelHeader -Title "Export Action History"

if (-not $Global:ActionLog -or $Global:ActionLog.Count -eq 0) {
    Write-Host "⚠️ No action history available to export." -ForegroundColor Yellow
    return
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outPath = ".\Logs\ActionHistory-$timestamp.txt"
$Global:ActionLog | Out-File -FilePath $outPath -Encoding UTF8

Write-Host "✅ Action history exported to: $outPath" -ForegroundColor Green
Write-Log "Exported action history to $outPath"
