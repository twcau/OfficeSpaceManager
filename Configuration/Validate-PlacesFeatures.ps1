. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
function Validate-PlacesFeatures {
    Render-PanelHeader -Title "Validating Microsoft Places Setup"

    $org = Get-OrganizationConfig
    if ($org.PlacesEnabled) {
Write-Log -Message "Places feature is ENABLED." -Level 'INFO'
    } else {
Write-Log -Message "Places feature is DISABLED." -Level 'WARN'
    }

    $apps = Get-CsTeamsAppSetupPolicy -Identity Global
    if ($apps.PinnedApps -contains "com.microsoft.places") {
Write-Log -Message "Places App is pinned in Teams." -Level 'INFO'
    } else {
Write-Log -Message "Places App is not pinned." -Level 'WARN'
    }

    Write-Log "Places features validated"
}
