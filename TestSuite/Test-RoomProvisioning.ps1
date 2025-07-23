<#
.SYNOPSIS
    Provisions a test meeting room resource mailbox for testing.
.DESCRIPTION
    This script creates a test meeting room mailbox in Exchange Online, configures it for AutoAccept, and logs the result. Intended for use in the OfficeSpaceManager test suite.
.FILECREATED
    2023-07-01
.FILELASTUPDATED
    2025-07-23
.OUTPUTS
    Creates a test meeting room mailbox in Exchange Online.
.EXAMPLE
    .\Test-RoomProvisioning.ps1
    # Provisions a test meeting room mailbox for testing.
.DOCUMENTATION New-Mailbox
    https://learn.microsoft.com/en-au/powershell/module/exchange/new-mailbox
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

function Test-RoomProvisioning {
    <#
    .SYNOPSIS
        Provisions a test meeting room mailbox for testing.
    .DESCRIPTION
        Creates a test meeting room mailbox, configures AutoAccept, and logs the result.
    .OUTPUTS
        None. Updates Exchange.
    #>
    Display-PanelHeader -Title "Test: Meeting Room Provisioning"

    $tenantConfig = Get-Content ".\config\TenantConfig.json" | ConvertFrom-Json
    $domain = $tenantConfig.TenantDomain

    $guid = (New-Guid).Guid.Substring(0, 8)
    $alias = "TEST_ROOM_$guid"
    $displayName = "TEST Meeting Room $guid"
    $email = "$alias@$domain"

    Write-Log -Message "Creating test room resource: $displayName" -Level 'INFO'

    New-Mailbox -Name $displayName -Alias $alias -Room `
        -PrimarySmtpAddress $email `
        -DisplayName $displayName -ErrorAction Stop

    Set-Mailbox -Identity $alias -Type Room
    Set-CalendarProcessing -Identity $alias -AutomateProcessing AutoAccept

    Write-Log "Test room $alias provisioned."
}
Test-RoomProvisioning




