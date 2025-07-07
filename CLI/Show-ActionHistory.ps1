function Show-ActionHistory {
    if ($Global:ActionLog.Count -eq 0) { return }

    Write-Host "`n╔══════════ Recent Actions ══════════╗" -ForegroundColor DarkGray
    $Global:ActionLog | Select-Object -Last 5 | ForEach-Object {
        Write-Host "• $_" -ForegroundColor Gray
    }
    Write-Host "╚════════════════════════════════════╝`n" -ForegroundColor DarkGray
}
