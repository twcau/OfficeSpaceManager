function Pin-PlacesAppInTeams {
    Render-PanelHeader -Title "Pin Places App in Teams"

    $policy = Get-CsTeamsAppSetupPolicy -Identity "Global"
    $appId = "com.microsoft.places"

    if ($policy.PinnedApps -contains $appId) {
        Write-Host "✅ Places app already pinned."
    } else {
        $newPinnedApps = $policy.PinnedApps + $appId
        Set-CsTeamsAppSetupPolicy -Identity "Global" -PinnedApps $newPinnedApps
        Write-Host "✔️ Pinned Places app in Teams setup policy."
        Write-Log "Pinned Places app in Teams"
    }
}
Pin-PlacesAppInTeams
