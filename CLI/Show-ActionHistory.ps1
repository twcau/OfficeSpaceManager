function Show-ActionHistory {
    if ($Global:ActionLog.Count -eq 0) { return }

    Write-Host "`n╔══════════ Recent Actions ══════════╗" -ForegroundColor DarkGray

    # Take the last 5 entries
    $Global:ActionLog |
      Select-Object -Last 5 |
      ForEach-Object {
        # If it's a string, just print it
        if ($_ -is [string]) {
          Write-Host "• $_" -ForegroundColor Gray
        }
        else {
          # Pull the timestamp & message/action
          $ts  = $_.Timestamp
          # different folks name it differently…
          $msg = $_.Action  ?? $_.Message
          # fallback if neither prop exists
          if (-not $msg) { $msg = $_ | Out-String }

          Write-Host ("• [{0}] {1}" -f $ts, $msg) -ForegroundColor Gray
        }
      }

    Write-Host "╚════════════════════════════════════╝`n" -ForegroundColor DarkGray
}
