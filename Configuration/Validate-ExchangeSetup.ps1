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

    Write-Host "✔️ Exchange resource validation completed"
    Write-Log "Exchange validation completed"
}
