<#
.SYNOPSIS
    About, Help & Instructions page for OfficeSpaceManager CLI.
.DESCRIPTION
    Displays project information, copyright, license, and key links. Provides a two-column layout with numbered options to open links in the browser, or press Enter/X to return to the main menu. Accessible, maintainable, and EN-AU compliant.
#>

Clear-Host
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\\CLI\\CLI.psm1') -Force
Get-PanelHeader -Title "OfficeSpaceManager - About, Help & Instructions"

# Project info (vertical layout with breaks)
Write-Host "A modular PowerShell CLI toolkit to establish a simple, and logical workflow from a single place to establish and manage Microsoft Places, Exchange Room Resources, and Metadata across Microsoft 365 environments."
Write-Host ""
Write-Host "Copyright (c) 2025, Michael Harris, All rights reserved."
Write-Host ""
# Project License menu item (option 1)
$licenseLink = "https://github.com/twcau/OfficeSpaceManager/blob/main/LICENSE"
Write-Host "[1] Project License: $licenseLink"
Write-Host ""
Write-Host (('-' * 80))
Write-Host ""

# Heading for documentation/resources
Write-Host "Documentation and resources" -ForegroundColor Magenta -BackgroundColor Black
Write-Host ""

# Links (numbered, vertical, reordered)
$links = @(
    @{ Label = "[2] Documentation & Manual"; Url = "https://twcau.github.io/OfficeSpaceManager/" },
    @{ Label = "[3] Project README.md"; Url = "https://github.com/twcau/OfficeSpaceManager/blob/main/README.md" },
    @{ Label = "[4] GitHub Repository"; Url = "https://github.com/twcau/OfficeSpaceManager" }
)
foreach ($link in $links) {
    Write-Host ("{0}: {1}" -f $link.Label, $link.Url)
}

Write-Host ""
Write-Host ("Enter a number to open a link, or press Enter/X to return to the main menu.")
$userInput = Read-Host "Selection"
if ([string]::IsNullOrWhiteSpace($userInput) -or $userInput.Trim().ToUpper() -eq 'X') {
    return
}
if ($userInput -match '^[1-4]$') {
    if ($userInput -eq '1') {
        $url = $licenseLink
    }
    else {
        $url = $links[[int]$userInput - 2].Url
    }
    try {
        Start-Process $url
        Write-Host ""
        Write-Host ("Opened {0} in your default browser." -f $url) -ForegroundColor Green
    }
    catch {
        Write-Host ""
        Write-Host ("Unable to open {0}. Please copy and paste it into your browser." -f $url) -ForegroundColor Yellow
    }
    Read-Host "Press Enter to return to the main menu."
}
return
