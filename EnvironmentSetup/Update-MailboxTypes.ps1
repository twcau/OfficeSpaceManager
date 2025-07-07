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
            Write-Host "$alias → Suggested Type: $suggestedType (Current: $type)"
            $apply = Read-Host "Update mailbox type? (Y/N)"
            if ($apply -eq 'Y') {
                Set-Mailbox -Identity $alias -Type $suggestedType
                Write-Host "✔️ Updated $alias to $suggestedType"
                Write-Log "$alias type updated to $suggestedType"
            }
        }
    }

    Write-Host "`n✅ Mailbox type update complete."
}
Update-MailboxTypes
