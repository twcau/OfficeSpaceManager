<#
.SYNOPSIS
    Provisions a test desk resource mailbox and updates metadata for testing.
.DESCRIPTION
    This script creates a test desk mailbox in Exchange Online, configures it for AutoAccept, and adds it to DeskDefinitions.json for test automation. Intended for use in the OfficeSpaceManager test suite.
.FILECREATED
    2023-07-01
.FILELASTUPDATED
    2025-07-23
.OUTPUTS
    Creates a test desk mailbox and updates metadata JSON.
.EXAMPLE
    .\Test-DeskProvisioning.ps1
    # Provisions a test desk mailbox and updates metadata.
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
    Read-Host "Press Enter to continue..."
    return
}

function Test-DeskProvisioning {
    <#
    .SYNOPSIS
        Provisions a test desk mailbox and updates metadata.
    .DESCRIPTION
        Creates a test desk mailbox, configures AutoAccept, and adds to DeskDefinitions.json.
    .OUTPUTS
        None. Updates Exchange and metadata files.
    #>
    Display-PanelHeader -Title "Test: Desk Provisioning"

    $tenantConfig = Get-Content ".\config\TenantConfig.json" | ConvertFrom-Json
    $domain = $tenantConfig.TenantDomain

    $guid = (New-Guid).Guid.Substring(0, 8)
    $alias = "TEST_DESK_$guid"
    $displayName = "TEST Desk $guid (Automation Test)"
    $email = "$alias@$domain"

    Write-Log -Message "Creating test desk resource: $displayName" -Level 'INFO'

    New-Mailbox -Name $displayName -Alias $alias -Room `
        -PrimarySmtpAddress $email `
        -DisplayName $displayName -ErrorAction Stop

    Set-Mailbox -Identity $alias -Type Room
    Set-CalendarProcessing -Identity $alias -AutomateProcessing AutoAccept

    Write-Log -Message "Desk created and configured." -Level 'INFO'

    # Update metadata
    $metadataPath = ".\Metadata\DeskDefinitions.json"
    $desks = Get-Content $metadataPath | ConvertFrom-Json
    $newDesk = @{
        DeskId           = $alias
        DisplayName      = $displayName
        ExchangeObjectId = (Get-Mailbox $alias).ExternalDirectoryObjectId
        Email            = $email
        SiteCode         = "TST"
        BuildingCode     = "TST"
        FloorNumber      = 1
        DeskNumber       = 999
        Retired          = $false
    }
    $desks += $newDesk
    $desks | ConvertTo-Json -Depth 4 | Set-Content $metadataPath

    Write-Log "Test desk $alias created and added to metadata."
}
Test-DeskProvisioning




