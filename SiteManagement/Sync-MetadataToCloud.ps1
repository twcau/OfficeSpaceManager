. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
function Sync-MetadataToCloud {
    Render-PanelHeader -Title "Sync Metadata to Cloud (Preview Module)"

    Write-Warning "`n🛠 This feature is not yet implemented."
    Write-Host "Microsoft Places currently does not provide full Graph API write support for sites/buildings/floors."

    Write-Host "`nℹ️ Keep track of Places API features here:"
    Write-Host "   https://learn.microsoft.com/en-us/microsoftplaces/" -ForegroundColor Blue

    Read-Host "`nPress Enter to return to the previous menu..."
    return
}
Sync-MetadataToCloud
