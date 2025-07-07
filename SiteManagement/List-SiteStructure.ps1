function List-SiteStructure {
    Render-PanelHeader -Title "Site, Building & Floor Metadata"

    $sites     = Get-Content ".\Metadata\SiteDefinitions.json" | ConvertFrom-Json
    $buildings = Get-Content ".\Metadata\BuildingDefinitions.json" | ConvertFrom-Json

    foreach ($site in $sites) {
        Write-Host "`n📍 Site: $($site.SiteCode) - $($site.SiteName)" -ForegroundColor Cyan
        $siteBuildings = $buildings | Where-Object { $_.SiteCode -eq $site.SiteCode }

        foreach ($b in $siteBuildings) {
            Write-Host "  🏢 Building: $($b.BuildingCode) - $($b.BuildingName)" -ForegroundColor Yellow
            foreach ($floor in $b.Floors) {
                Write-Host "    ▸ Floor $($floor.FloorNumber): $($floor.FloorName)" -ForegroundColor Gray
            }
        }
    }
}
List-SiteStructure
