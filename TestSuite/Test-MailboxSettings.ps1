# Load Shared Connection Logic
. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    return
}

function Test-MailboxSettings {
    Render-PanelHeader -Title "Test: Mailbox Settings Validation"

    $mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.Alias -like "TEST_*" }

    foreach ($mb in $mailboxes) {
        $cp = Get-CalendarProcessing -Identity $mb.Identity
Write-Log -Message "mb.Alias) - AutoAccept: $($cp.AutomateProcessing)" -Level 'INFO'
    }

    Write-Log "Mailbox booking settings validated for test resources."
}
Test-MailboxSettings




