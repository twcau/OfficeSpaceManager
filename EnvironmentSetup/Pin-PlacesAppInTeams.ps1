# Load Shared Connection Logic
. "$PSScriptRoot\..\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Warning "⚠️ Skipping resource sync: unable to authenticate with Exchange Online."
    return
}

function Pin-PlacesAppInTeams {
    Render-PanelHeader -Title "Pin Places App in Teams"

    $policy = Get-CsTeamsAppSetupPolicy -Identity "Global"
    $appId = "com.microsoft.places"

    if ($policy.PinnedApps -contains $appId) {
        Write-Host "âœ… Places app already pinned."
    } else {
        $newPinnedApps = $policy.PinnedApps + $appId
        Set-CsTeamsAppSetupPolicy -Identity "Global" -PinnedApps $newPinnedApps
        Write-Host "âœ”ï¸ Pinned Places app in Teams setup policy."
        Write-Log "Pinned Places app in Teams"
    }
}
Pin-PlacesAppInTeams
