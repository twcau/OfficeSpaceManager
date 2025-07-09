. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
function Validate-PlacesFeatures {
    Render-PanelHeader -Title "Validating Microsoft Places Setup"

    $org = Get-OrganizationConfig
    if ($org.PlacesEnabled) {
        Write-Host "✅ Places feature is ENABLED."
    } else {
        Write-Warning "❌ Places feature is DISABLED."
    }

    $apps = Get-CsTeamsAppSetupPolicy -Identity Global
    if ($apps.PinnedApps -contains "com.microsoft.places") {
        Write-Host "✅ Places App is pinned in Teams."
    } else {
        Write-Warning "⚠️ Places App is not pinned."
    }

    Write-Log "Places features validated"
}
