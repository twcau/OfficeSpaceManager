# Load Shared Connection Logic
. "$PSScriptRoot\..\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Warning "⚠️ Skipping resource sync: unable to authenticate with Exchange Online."
    return
}

function Run-FirstTimeSetup {
    Render-PanelHeader -Title "First-Time Setup Wizard"

    Write-Host "ðŸ”§ Collecting tenant domain info..."
    $org = Get-OrganizationConfig
    $defaultDomain = $org.DefaultDomain
    Write-Host "Detected default domain: $defaultDomain"

    # Confirm enabling Places
    $placesEnabled = $org.PlacesEnabled
    if (-not $placesEnabled) {
        Write-Host "`nMicrosoft Places is not enabled."
        $confirm = Read-Host "Enable it now? (Y/N)"
        if ($confirm -eq 'Y') {
            . "$PSScriptRoot\Enable-PlacesFeatures.ps1"
        }
    }

    Write-Host "`nðŸ“¥ Syncing cached resources..."
    . "$PSScriptRoot\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force

# After syncing cached resources
Write-Host "`nWould you like to export editable metadata templates for Pathways and Roles?"
$export = Read-Host "Export metadata templates now? (Y/N)"
if ($export -eq 'Y') {
    . "$PSScriptRoot\TemplateManagement\Export-MetadataTemplates.ps1"
    Write-Host "`nðŸ“¥ You can now populate the CSVs and import them using Configuration > Templates > Import Metadata"
}

    Write-Host "`nðŸ“ Generating templates..."
    . "$PSScriptRoot\TemplateManagement\Export-AllTemplates.ps1"

    Write-Host "`nâœ… First-Time Setup Complete."
    Set-Content ".\config\FirstRunComplete.json" '{ "status": "done" }'
    Write-Log "First-time setup completed and domain info saved"
}
Run-FirstTimeSetup
