. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
function Detect-NonStandardResources {
    Render-PanelHeader -Title "Detect Non-Standard Resource Calendars"

    $cache = Get-Content ".\Metadata\CachedResources.json" | ConvertFrom-Json

    foreach ($desk in $cache.Desks) {
        if ($desk.DisplayName -notmatch '^[A-Z]{3}[A-Z0-9]+ Shared Desk \d+ \(.+\)$') {
Write-Log -Message "desk.DisplayName) does not match naming convention" -Level 'WARN'
        }
    }

    Write-Log "Naming convention audit completed"
}
Detect-NonStandardResources
