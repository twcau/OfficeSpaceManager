. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
function Sync-MetadataToCloud {
    Render-PanelHeader -Title "Sync Metadata to Cloud (Preview Module)"

Write-Log -Message "n🛠 This feature is not yet implemented." -Level 'WARN'
Write-Log -Message "Microsoft Places currently does not provide full Graph API write support for sites/buildings/floors." -Level 'INFO'

    Write-Host "`nℹ️ Keep track of Places API features here:"
Write-Log -Message "https://learn.microsoft.com/en-us/microsoftplaces/" -Level 'INFO'

    Read-Host "`nPress Enter to return to the previous menu..."
    return
}
Sync-MetadataToCloud
