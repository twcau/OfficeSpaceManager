<#
.SYNOPSIS
    Ensures calendar processing settings are correct for OfficeSpaceManager resources.
.DESCRIPTION
    Validates and updates calendar processing settings for Exchange resources. Uses EN-AU spelling and accessible output.
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

function Ensure-CalendarProcessingSettings {
    Display-PanelHeader -Title "Calendar Processing Settings Check"

    $resources = Get-Mailbox -RecipientTypeDetails RoomMailbox -ResultSize Unlimited

    foreach ($r in $resources) {
        $cp = Get-CalendarProcessing -Identity $r.Alias

        if ($cp.AutomateProcessing -ne "AutoAccept") {
            Write-Log -Message "$($r.DisplayName): not set to AutoAccept" -Level 'WARN'
            $fix = Read-Host "Fix this? (Y/N)"
            if ($fix -eq 'Y') {
                Set-CalendarProcessing -Identity $r.Alias -AutomateProcessing AutoAccept -RemoveOldMeetingMessages $true
                Write-Log "Set AutoAccept on $($r.Alias)"
            }
        }
    }

    Write-Log -Message "Calendar processing settings validated" -Level 'INFO'
}
Ensure-CalendarProcessingSettings




