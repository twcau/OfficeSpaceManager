# Load Shared Connection Logic
. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Warning "âš ï¸ Skipping resource sync: unable to authenticate with Exchange Online."
    return
}

function Validate-ExchangeSetup {
    Render-PanelHeader -Title "Validating Exchange Setup"

    $resources = Get-Mailbox -RecipientTypeDetails RoomMailbox -ResultSize Unlimited

    foreach ($r in $resources) {
        $place = Get-Place -Identity $r.Alias -ErrorAction SilentlyContinue
        if (-not $place) {
            Write-Warning "$($r.Alias): No Place metadata"
        }
        if ($r.HiddenFromAddressListsEnabled) {
            Write-Warning "$($r.Alias): Hidden from GAL"
        }
    }

    Write-Host "Ã¢Å“â€Ã¯Â¸Â Exchange resource validation completed"
    Write-Log "Exchange validation completed"
}




