<#
.SYNOPSIS
    Site management: building, floor, site, desk management for OfficeSpaceManager.
.DESCRIPTION
    Provides functions to export/import site/building templates, list site structure, and (future) sync metadata to cloud. Ensures all site management logic is modular, maintainable, and auditable.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

# SiteManagement.psm1

function Export-SiteStructureTemplates {
    <#
    .SYNOPSIS
        Exports example site and building templates to the Exports folder.
    .DESCRIPTION
        Creates sample CSV templates for sites and buildings in the Exports folder, for use in import and onboarding.
    .OUTPUTS
        None. Writes CSV files to disk.
    .EXAMPLE
        Export-SiteStructureTemplates
    #>
    Display-PanelHeader -Title "Export Site & Building Templates"
    $date = Get-Date -Format "yyyy-MM-dd"
    $folder = ".\Exports\$date"
    if (!(Test-Path $folder)) { New-Item -ItemType Directory -Path $folder | Out-Null }
    @(
        [PSCustomObject]@{
            SiteCode = "HQ1"
            SiteName = "Headquarters"
            Domain   = "hq1.contoso.com"
            Notes    = "Main campus"
        }
    ) | Export-Csv "$folder\Template-Sites.csv" -NoTypeInformation
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

function Import-SiteStructureFromCSV {
    <#
    .SYNOPSIS
        Imports site/building structure from a selected CSV template.
    .DESCRIPTION
        Allows user to select a CSV template and imports site/building data into metadata JSON files.
    .OUTPUTS
        None. Writes JSON files to disk.
    .EXAMPLE
        Import-SiteStructureFromCSV
    #>
    Display-PanelHeader -Title "Import Site & Building Structure"
    $latestExportFolder = Get-Item ".\Exports\" | Get-ChildItem -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $latestExportFolder) {
        Write-Log -Message "No export folder found." -Level 'WARN'
        return
    }
    $csvFiles = Get-ChildItem $latestExportFolder.FullName -Filter "Template-*.csv"
    $file = $csvFiles | Out-GridView -Title "Select a Site/Building CSV to import" -PassThru
    if (-not $file) { return }
    switch -Wildcard ($file.Name) {
        "Template-Sites.csv" {
            $data = Import-Csv -Path $file.FullName
            $data | ConvertTo-Json -Depth 5 | Set-Content ".\Metadata\SiteDefinitions.json"
            Write-Log -Message "Imported Sites" -Level 'INFO'
            Write-Log "Imported SiteDefinitions.json"
        }
        "Template-Buildings.csv" {
            $data = Import-Csv -Path $file.FullName
            $grouped = $data | Group-Object -Property BuildingCode
            $jsonOut = @()
            foreach ($g in $grouped) {
                $first = $g.Group[0]
                $floors = $g.Group | Sort-Object FloorNumber | ForEach-Object {
                    @{
                        FloorNumber = [int]$_.FloorNumber
                        FloorName   = $_.FloorName
                        Notes       = $_.Notes
                    }
                }
                $jsonOut += @{
                    BuildingCode = $first.BuildingCode
                    BuildingName = $first.BuildingName
                    SiteCode     = $first.SiteCode
                    Floors       = $floors
                }
            }
            $jsonOut | ConvertTo-Json -Depth 5 | Set-Content ".\Metadata\BuildingDefinitions.json"
            Write-Log -Message "Imported Buildings and Floors" -Level 'INFO'
            Write-Log "Imported BuildingDefinitions.json"
        }
        default {
            Write-Log -Message "Unsupported template format" -Level 'WARN'
        }
    }
}

function Get-SiteStructure {
    <#
    .SYNOPSIS
        Lists all sites, buildings, and floors from metadata.
    .DESCRIPTION
        Reads metadata JSON files and prints a summary of all sites, buildings, and floors.
    .OUTPUTS
        None. Writes to console.
    .EXAMPLE
        Get-SiteStructure
    #>
    Display-PanelHeader -Title "Site, Building & Floor Metadata"
    $sites = Get-Content ".\Metadata\SiteDefinitions.json" | ConvertFrom-Json
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

function Sync-MetadataToCloud {
    <#
    .SYNOPSIS
        Placeholder for future cloud sync logic.
    .DESCRIPTION
        Not yet implemented. Will sync metadata to Microsoft Places/Graph API when available.
    .OUTPUTS
        None.
    .EXAMPLE
        Sync-MetadataToCloud
    #>
    Display-PanelHeader -Title "Sync Metadata to Cloud (Preview Module)"
    Write-Log -Message "n🛠 This feature is not yet implemented." -Level 'WARN'
    Write-Log -Message "Microsoft Places currently does not provide full Graph API write support for sites/buildings/floors." -Level 'INFO'
    Write-Host "`nℹ️ Keep track of Places API features here:"
    Write-Log -Message "https://learn.microsoft.com/en-us/microsoftplaces/" -Level 'INFO'
    Read-Host "`nPress Enter to return to the previous menu..."
    return
}

Export-ModuleMember -Function Export-SiteStructureTemplates, Import-SiteStructureFromCSV, Get-SiteStructure, Sync-MetadataToCloud
