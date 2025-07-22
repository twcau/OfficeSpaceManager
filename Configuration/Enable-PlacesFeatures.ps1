. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
function Enable-PlacesFeatures {
Write-Log -Message "Enabling Microsoft Places features..." -Level 'INFO'
    Set-OrganizationConfig -PlacesEnabled $true
Write-Log -Message "Microsoft Places enabled." -Level 'INFO'
    Write-Log "Enabled Microsoft Places"
}
