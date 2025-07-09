. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
function Show-ActionHistory {
  $logDir = Join-Path $PSScriptRoot "..\Logs"
  $logFile = Join-Path $logDir ("Log_" + (Get-Date -Format "yyyyMMdd") + ".log")

  if (-not (Test-Path $logFile)) {
    Write-Host "`n(No log entries found for today.)`n" -ForegroundColor DarkGray
    return
  }

  $lines = Get-Content $logFile | Where-Object { $_.Trim() -ne "" }
  if ($lines.Count -eq 0) {
    Write-Host "`n(No log entries found for today.)`n" -ForegroundColor DarkGray
    return
  }

  Write-Host "`n╔══════════ Recent Actions ══════════╗" -ForegroundColor DarkGray

  $lines | Select-Object -Last 5 | ForEach-Object {
    Write-Host "• $_" -ForegroundColor Gray
  }

  Write-Host "╚════════════════════════════════════╝`n" -ForegroundColor DarkGray
}
