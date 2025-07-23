<#
.SYNOPSIS
    Renders a stylised panel header for CLI menus in OfficeSpaceManager.
.DESCRIPTION
    Displays a Unicode-styled header for CLI sections, improving readability and user experience. Uses EN-AU spelling and accessible output.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

function Display-PanelHeader {
    param (
        [string]$Title,
        [string]$Subtitle = "",
        [string]$Icon = "📂"
    )

    $width = 50
    $border = "═" * $width
    $titlePadding = [math]::Max(0, ($width - $Title.Length - 2) / 2)
    $subtitlePadding = [math]::Max(0, ($width - $Subtitle.Length - 2) / 2)

    Write-Host "$border" -ForegroundColor DarkCyan
    Write-Host ("║" + " " * $titlePadding + $Icon + " " + $Title + " " * $titlePadding + "║") -ForegroundColor Cyan
    if ($Subtitle) {
        Write-Host ("║" + " " * $subtitlePadding + $Subtitle + " " * $subtitlePadding + "║") -ForegroundColor DarkGray
    }
    Write-Host "$border" -ForegroundColor DarkCyan
}

# Example usage
Display-PanelHeader -Title "Main Menu" -Subtitle "Select an option" -Icon "🏠"