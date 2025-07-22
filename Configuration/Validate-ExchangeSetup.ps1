# Load Shared Connection Logic
. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    return
}

function Validate-ExchangeSetup {
    Render-PanelHeader -Title "Validating Exchange Setup"

    $resources = Get-Mailbox -RecipientTypeDetails RoomMailbox -ResultSize Unlimited

    foreach ($r in $resources) {
        $place = Get-Place -Identity $r.Alias -ErrorAction SilentlyContinue
        if (-not $place) {
Write-Log -Message "r.Alias): No Place metadata" -Level 'WARN'
        }
        if ($r.HiddenFromAddressListsEnabled) {
Write-Log -Message "r.Alias): Hidden from GAL" -Level 'WARN'
        }
    }

Write-Log -Message "Exchange resource validation completed" -Level 'INFO'
    Write-Log "Exchange validation completed"
}




