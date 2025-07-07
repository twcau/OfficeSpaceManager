function Render-PanelHeader {
    param([string]$Title)

    $line = "═" * ($Title.Length + 4)
    Write-Host "`n╔$line╗" -ForegroundColor Cyan
    Write-Host "║  $Title  ║" -ForegroundColor Cyan
    Write-Host "╚$line╝`n" -ForegroundColor Cyan
}
