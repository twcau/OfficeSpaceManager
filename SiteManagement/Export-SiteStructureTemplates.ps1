function Export-SiteStructureTemplates {
    Render-PanelHeader -Title "Export Site & Building Templates"

    $date = Get-Date -Format "yyyy-MM-dd"
    $folder = ".\Exports\$date"
    if (!(Test-Path $folder)) { New-Item -ItemType Directory -Path $folder | Out-Null }

    # Export Site Template
    @(
        [PSCustomObject]@{
            SiteCode  = "HQ1"
            SiteName  = "Headquarters"
            Domain    = "hq1.contoso.com"
            Notes     = "Main campus"
        }
    ) | Export-Csv "$folder\Template-Sites.csv" -NoTypeInformation

    # Export Building Template
    @(
        [PSCustomObject]@{
            BuildingCode = "B1"
            BuildingName = "Block 1"
            SiteCode     = "HQ1"
            FloorNumber  = 1
            FloorName    = "Ground Floor"
        },
        [PSCustomObject]@{
            BuildingCode = "B1"
            BuildingName = "Block 1"
            SiteCode     = "HQ1"
            FloorNumber  = 2
            FloorName    = "Second Floor"
        }
    ) | Export-Csv "$folder\Template-Buildings.csv" -NoTypeInformation

    Write-Host "`n📁 Templates exported to $folder"
    Write-Log "Exported site and building templates to $folder"
}
Export-SiteStructureTemplates
