<#
.SYNOPSIS
    Detects non-standard resource names in OfficeSpaceManager.
.DESCRIPTION
    Scans for resources with names that do not match the standard naming convention. Uses EN-AU spelling and accessible output.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

Import-Module "$PSScriptRoot/../Modules/CLI/CLI.psm1"
Import-Module "$PSScriptRoot/../Modules/Logging/Logging.psm1"
function Test-NonStandardResources {
    Get-PanelHeader -Title "Detect Non-Standard Resource Calendars"

    $cache = Get-Content ".\Metadata\CachedResources.json" | ConvertFrom-Json

    foreach ($desk in $cache.Desks) {
        if ($desk.DisplayName -notmatch '^[A-Z]{3}[A-Z0-9]+ Shared Desk \d+ \(.+\)$') {
Write-Log -Message "desk.DisplayName) does not match naming convention" -Level 'WARN'
        }
    }

    Write-Log "Naming convention audit completed"
}
Test-NonStandardResources
