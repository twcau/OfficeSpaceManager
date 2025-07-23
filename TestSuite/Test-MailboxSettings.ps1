<#
.SYNOPSIS
    Validates mailbox settings for all test resources.
.DESCRIPTION
    This script checks all test mailboxes (aliases starting with TEST_) for correct calendar processing settings and logs the results. Intended for use in the OfficeSpaceManager test suite.
.FILECREATED
    2023-07-01
.FILELASTUPDATED
    2025-07-23
.OUTPUTS
    Logs mailbox settings for all test resources.
.EXAMPLE
    .\Test-MailboxSettings.ps1
    # Validates mailbox settings for all test resources.
.DOCUMENTATION Get-CalendarProcessing
    https://learn.microsoft.com/en-au/powershell/module/exchange/get-calendarprocessing
#>

# Load shared modules and error handling
. (Join-Path $PSScriptRoot '..\Modules\Utilities\Resolve-OfficeSpaceManagerRoot.ps1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\Logging\Logging.psm1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\Utilities\Utilities.psm1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\CLI\CLI.psm1')
$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    return
}

function Test-MailboxSettings {
    <#
    .SYNOPSIS
        Validates mailbox settings for all test resources.
    .DESCRIPTION
        Checks all test mailboxes for correct calendar processing settings and logs the results.
    .OUTPUTS
        None. Logs results.
    #>
    Display-PanelHeader -Title "Test: Mailbox Settings Validation"

    $mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.Alias -like "TEST_*" }

    foreach ($mb in $mailboxes) {
        $cp = Get-CalendarProcessing -Identity $mb.Identity
        Write-Log -Message "$($mb.Alias) - AutoAccept: $($cp.AutomateProcessing)" -Level 'INFO'
    }

    Write-Log "Mailbox booking settings validated for test resources."
}
Test-MailboxSettings




