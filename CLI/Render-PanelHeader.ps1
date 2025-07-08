function Render-PanelHeader {
param (
    [string]$Title = "Main Menu"
)

$padding = 2
$width = $Title.Length + ($padding * 2)
$top    = "╔" + ("═" * $width) + "╗"
$middle = "║" + (" " * $padding) + $Title + (" " * $padding) + "║"
$bottom = "╚" + ("═" * $width) + "╝"

Write-Host ""
Write-Host $top -ForegroundColor Cyan
Write-Host $middle -ForegroundColor Cyan
Write-Host $bottom -ForegroundColor Cyan
Write-Host ""
}