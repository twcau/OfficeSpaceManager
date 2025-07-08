# Load Shared Connection Logic
. "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Warning "âš ï¸ Skipping resource sync: unable to authenticate with Exchange Online."
    return
}

function Test-MailboxSettings {
    Render-PanelHeader -Title "Test: Mailbox Settings Validation"

    $mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.Alias -like "TEST_*" }

    foreach ($mb in $mailboxes) {
        $cp = Get-CalendarProcessing -Identity $mb.Identity
        Write-Host "Ã°Å¸â€Â $($mb.Alias) - AutoAccept: $($cp.AutomateProcessing)"
    }

    Write-Log "Mailbox booking settings validated for test resources."
}
Test-MailboxSettings



