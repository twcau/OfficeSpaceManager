# Load Shared Connection Logic
. "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Warning "âš ï¸ Skipping resource sync: unable to authenticate with Exchange Online."
    return
}

function Pin-PlacesAppInTeams {
    Render-PanelHeader -Title "Pin Places App in Teams"

    $policy = Get-CsTeamsAppSetupPolicy -Identity "Global"
    $appId = "com.microsoft.places"

    if ($policy.PinnedApps -contains $appId) {
        Write-Host "Ã¢Å“â€¦ Places app already pinned."
    } else {
        $newPinnedApps = $policy.PinnedApps + $appId
        Set-CsTeamsAppSetupPolicy -Identity "Global" -PinnedApps $newPinnedApps
        Write-Host "Ã¢Å“â€Ã¯Â¸Â Pinned Places app in Teams setup policy."
        Write-Log "Pinned Places app in Teams"
    }
}
Pin-PlacesAppInTeams



