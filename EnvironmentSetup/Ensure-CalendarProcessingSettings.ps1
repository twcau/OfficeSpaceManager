function Ensure-CalendarProcessingSettings {
    Render-PanelHeader -Title "Calendar Processing Settings Check"

    $resources = Get-Mailbox -RecipientTypeDetails RoomMailbox -ResultSize Unlimited

    foreach ($r in $resources) {
        $cp = Get-CalendarProcessing -Identity $r.Alias

        if (-not $cp.AutomateProcessing -eq "AutoAccept") {
            Write-Warning "$($r.DisplayName): not set to AutoAccept"
            $fix = Read-Host "Fix this? (Y/N)"
            if ($fix -eq 'Y') {
                Set-CalendarProcessing -Identity $r.Alias -AutomateProcessing AutoAccept -RemoveOldMeetingMessages $true
                Write-Log "Set AutoAccept on $($r.Alias)"
            }
        }
    }

    Write-Host "✔️ Calendar processing settings validated"
}
Ensure-CalendarProcessingSettings