# Load Shared Connection Logic
. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    return
}

function Test-RoomProvisioning {
    Render-PanelHeader -Title "Test: Meeting Room Provisioning"

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




