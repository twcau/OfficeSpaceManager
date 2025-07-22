# Load Shared Connection Logic
. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    return
}

function Update-MailboxTypes {
    Render-PanelHeader -Title "Update Mailbox Types in Bulk"

    $resources = Get-Mailbox -RecipientTypeDetails RoomMailbox,SharedMailbox,EquipmentMailbox -ResultSize Unlimited

    foreach ($r in $resources) {
        $alias = $r.Alias
        $type = $r.RecipientTypeDetails

        # Simple rule logic based on naming
        $suggestedType = switch -Wildcard ($r.DisplayName) {
            "*Shared Desk*"     { "Room" }
            "*Meeting Room*"    { "Room" }
            "*Equipment Room*"  { "Room" }
            "*TV*"              { "Equipment" }
            "*Projector*"       { "Equipment" }
            Default             { "Shared" }
        }

        if ($suggestedType -ne $type) {
Write-Log -Message "alias Ã¢â€ â€™ Suggested Type: $suggestedType (Current: $type)" -Level 'INFO'
            $apply = Read-Host "Update mailbox type? (Y/N)"
            if ($apply -eq 'Y') {
                Set-Mailbox -Identity $alias -Type $suggestedType
Write-Log -Message "Updated $alias to $suggestedType" -Level 'INFO'
                Write-Log "$alias type updated to $suggestedType"
            }
        }
    }

    Write-Host "`nÃ¢Å“â€¦ Mailbox type update complete."
}
Update-MailboxTypes




