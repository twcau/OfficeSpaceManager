# Load Shared Connection Logic
. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    return
}

function Run-FirstTimeSetup {
    Render-PanelHeader -Title "First-Time Setup Wizard"

Write-Log -Message "Collecting tenant domain info..." -Level 'INFO'
    $org = Get-OrganizationConfig
    $defaultDomain = $org.DefaultDomain
Write-Log -Message "Detected default domain: $defaultDomain" -Level 'INFO'

    # Confirm enabling Places
    $placesEnabled = $org.PlacesEnabled
    if (-not $placesEnabled) {
        Write-Host "`nMicrosoft Places is not enabled."
        $confirm = Read-Host "Enable it now? (Y/N)"
        if ($confirm -eq 'Y') {
            . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Enable-PlacesFeatures.ps1"
        }
    }

    Write-Host "`nÃ°Å¸â€œÂ¥ Syncing cached resources..."
    . "$PSScriptRoot\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force

    # After syncing cached resources
    Write-Host "`nWould you like to export editable metadata templates for Pathways and Roles?"
    $export = Read-Host "Export metadata templates now? (Y/N)"
    if ($export -eq 'Y') {
        . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\TemplateManagement\Export-MetadataTemplates.ps1"
        Write-Host "`nÃ°Å¸â€œÂ¥ You can now populate the CSVs and import them using Configuration > Templates > Import Metadata"
    }

    Write-Host "`nÃ°Å¸â€œÂ Generating templates..."
    . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\TemplateManagement\Export-AllTemplates.ps1"

    Write-Host "`nÃ¢Å“â€¦ First-Time Setup Complete."
    Set-Content ".\config\FirstRunComplete.json" '{ "status": "done" }'
    Write-Log "First-time setup completed and domain info saved"
}
Run-FirstTimeSetup




