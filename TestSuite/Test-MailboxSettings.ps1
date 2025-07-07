function Test-MailboxSettings {
    Render-PanelHeader -Title "Test: Mailbox Settings Validation"

    $mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.Alias -like "TEST_*" }

    foreach ($mb in $mailboxes) {
        $cp = Get-CalendarProcessing -Identity $mb.Identity
        Write-Host "🔍 $($mb.Alias) - AutoAccept: $($cp.AutomateProcessing)"
    }

    Write-Log "Mailbox booking settings validated for test resources."
}
Test-MailboxSettings
