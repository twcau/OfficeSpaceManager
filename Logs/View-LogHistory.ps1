param (
    [switch]$TodayOnly
)

Get-PanelHeader -Title "View Log Files"

if ($TodayOnly) {
    $today = Get-Date -Format 'yyyyMMdd'
    $logFolder = Join-Path $PSScriptRoot 'Logs'
    $todayLogFile = Join-Path $logFolder "Log_${today}.log"
    if (Test-Path $todayLogFile) {
        Write-Host ("`nOpening today's log file in Notepad: Log_{0}.log" -f $today) -ForegroundColor Cyan
        Start-Process notepad.exe $todayLogFile
        Write-Log ("Opened today's log file: Log_{0}.log" -f $today)
    }
    else {
        Write-Host ("No log file found for today. Searched for: {0}" -f $todayLogFile) -ForegroundColor Yellow
        Read-Host "Press Enter to return to menu..."
    }
    return
}

# Option 4: View Log File from Grid
$logFiles = Get-ChildItem "./Logs" -Filter "*.log" | Sort-Object LastWriteTime -Descending
if ($logFiles.Count -eq 0) {
    Write-Host "❌ No logs found in the Logs folder." -ForegroundColor Yellow
    Read-Host "Press Enter to return to menu..."
    return
}
$selected = $logFiles | Select-Object Name, LastWriteTime | Out-GridView -Title "Select a log to view" -PassThru
if (-not $selected) { return }
$path = "./Logs/$($selected.Name)"
Write-Host ("`nOpening {0} in Notepad..." -f $selected.Name) -ForegroundColor Cyan
Start-Process notepad.exe $path
Write-Log ("Opened log file: {0}" -f $selected.Name)
