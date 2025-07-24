<#
.SYNOPSIS
    Updates mailbox types in bulk for OfficeSpaceManager.
.DESCRIPTION
    Updates mailbox types for resources as required, supporting bulk operations and validation. Uses EN-AU spelling and accessible output.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules/CLI/CLI.psm1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Logging/Logging.psm1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Utilities/Utilities.psm1')
# Import Connections module for robust service connections
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Connections/Connections.psm1') -Force

$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    return
}

function Update-MailboxTypes {
    Get-PanelHeader -Title "Update Mailbox Types in Bulk"

    $resources = Get-Mailbox -RecipientTypeDetails RoomMailbox, SharedMailbox, EquipmentMailbox -ResultSize Unlimited

    foreach ($r in $resources) {
        $alias = $r.Alias
        $type = $r.RecipientTypeDetails

        # Simple rule logic based on naming
        $suggestedType = switch -Wildcard ($r.DisplayName) {
            "*Shared Desk*" { "Room" }
            "*Meeting Room*" { "Room" }
            "*Equipment Room*" { "Room" }
            "*TV*" { "Equipment" }
            "*Projector*" { "Equipment" }
            Default { "Shared" }
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

    Write-Host "`n✔ Mailbox type update complete."
}

Update-MailboxTypes




