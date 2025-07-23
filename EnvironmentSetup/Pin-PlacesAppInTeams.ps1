<#
.SYNOPSIS
    Sets the Microsoft Places app as pinned in Teams for OfficeSpaceManager.
.DESCRIPTION
    Pins the Places app in Teams for all users or selected policies. Uses EN-AU spelling and accessible output. Uses approved verb 'Set'.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

Import-Module "$PSScriptRoot/../Modules/CLI/CLI.psm1"

# Load Shared Connection Logic
. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    return
}

function Set-TeamsPlacesAppPinned {
    Display-PanelHeader -Title "Pin Places App in Teams"

    $policy = Get-CsTeamsAppSetupPolicy -Identity "Global"
    $appId = "com.microsoft.places"

    if ($policy.PinnedApps -contains $appId) {
        Write-Log -Message "Places app already pinned." -Level 'INFO'
    }
    else {
        $newPinnedApps = $policy.PinnedApps + $appId
        Set-CsTeamsAppSetupPolicy -Identity "Global" -PinnedApps $newPinnedApps
        Write-Log -Message "Pinned Places app in Teams setup policy." -Level 'INFO'
        Write-Log "Pinned Places app in Teams"
    }
}
Set-TeamsPlacesAppPinned




