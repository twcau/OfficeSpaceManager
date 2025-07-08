# Load Shared Connection Logic
. "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Warning "âš ï¸ Skipping resource sync: unable to authenticate with Exchange Online."
    return
}

function Test-DeskProvisioning {
    Render-PanelHeader -Title "Test: Desk Provisioning"

    $tenantConfig = Get-Content ".\config\TenantConfig.json" | ConvertFrom-Json
    $domain = $tenantConfig.TenantDomain

    $guid = (New-Guid).Guid.Substring(0, 8)
    $alias = "TEST_DESK_$guid"
    $displayName = "TEST Desk $guid (Automation Test)"
    $email = "$alias@$domain"

    Write-Host "Ã°Å¸â€Â§ Creating test desk resource: $displayName"

    New-Mailbox -Name $displayName -Alias $alias -Room `
        -PrimarySmtpAddress $email `
        -DisplayName $displayName -ErrorAction Stop

    Set-Mailbox -Identity $alias -Type Room
    Set-CalendarProcessing -Identity $alias -AutomateProcessing AutoAccept

    Write-Host "Ã¢Å“â€¦ Desk created and configured."

    # Update metadata
    $metadataPath = ".\Metadata\DeskDefinitions.json"
    $desks = Get-Content $metadataPath | ConvertFrom-Json
    $newDesk = @{
        DeskId = $alias
        DisplayName = $displayName
        ExchangeObjectId = (Get-Mailbox $alias).ExternalDirectoryObjectId
        Email = $email
        SiteCode = "TST"
        BuildingCode = "TST"
        FloorNumber = 1
        DeskNumber = 999
        Retired = $false
    }
    $desks += $newDesk
    $desks | ConvertTo-Json -Depth 4 | Set-Content $metadataPath

    Write-Log "Test desk $alias created and added to metadata."
}
Test-DeskProvisioning



