. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
function Enable-PlacesFeatures {
    Write-Host "✔️ Enabling Microsoft Places features..."
    Set-OrganizationConfig -PlacesEnabled $true
    Write-Host "✅ Microsoft Places enabled."
    Write-Log "Enabled Microsoft Places"
}
