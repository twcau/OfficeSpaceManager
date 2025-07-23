<#
.SYNOPSIS
    Exports all supported metadata templates (desks, desk pools, sites, buildings, floors, etc.) into a date-stamped folder for bulk data import.
.DESCRIPTION
    This script exports all key metadata templates used by OfficeSpaceManager, including desks, desk pools, sites, buildings, and floors, to CSV files in a date-stamped export folder. It ensures that sample data is available if no data exists, and provides a consistent export structure for bulk import or backup.
.FILECREATED
    2023-07-01
.FILELASTUPDATED
    2025-07-23
.OUTPUTS
    CSV files for each metadata type in the .\Exports\<date> folder.
.EXAMPLE
    .\Export-AllTemplates.ps1
    # Exports all templates to a new folder under .\Exports
.DOCUMENTATION Export-Csv
    https://learn.microsoft.com/en-au/powershell/module/microsoft.powershell.utility/export-csv
#>

# Import global error handling and logging
. (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Logging/GlobalErrorHandling.ps1')

function Export-AllTemplates {
    <#
    .SYNOPSIS
        Main function to export all metadata templates.
    .DESCRIPTION
        Handles folder creation, loads tenant config, and exports each template type to CSV.
    .OUTPUTS
        None. Writes CSV files to disk.
    #>
    Display-PanelHeader -Title "Export All Metadata Templates"

    # region 50d Domain Context for Templates
    $tenantConfigPath = ".\config\TenantConfig.json"
    if (-not (Test-Path $tenantConfigPath)) {
        Write-Log -Message "TenantConfig.json not found. Please run first-time setup." -Level 'WARN'
        Read-Host "Press Enter to continue..."
        return
    }
    $tenantConfig = Get-Content $tenantConfigPath | ConvertFrom-Json
    # endregion

    # region 4c1 Folder Structure
    $exportDate = Get-Date -Format 'yyyy-MM-dd'
    $folder = ".\Exports\$exportDate"
    if (!(Test-Path $folder)) { New-Item -ItemType Directory -Path $folder | Out-Null }
    # endregion

    # region a91 Desks
    # Export desks, or provide a sample if none exist
    $desks = Get-Content ".\Metadata\DeskDefinitions.json" -Raw | ConvertFrom-Json
    if ($desks.Count -eq 0) {
        $desks = @(
            [PSCustomObject]@{
                DisplayName        = "FRE-FIN-E7 Ops Desk"
                Alias              = "frefin17ops"
                Domain             = $tenantConfig.DefaultDomain
                SiteCode           = "FRE"
                BuildingCode       = "01"
                FloorId            = "FRE-01-G"
                FloorName          = "Ground Floor"
                Pathway            = "FIN"
                DeskNumber         = "E7"
                Role               = "Ops"
                ObjectType         = "desk"
                IsHeightAdjustable = "Y"
                HasDockingStation  = "Y"
                IsAccessible       = "N"
            }
        )
    }
    $desks | Export-Csv "$folder\Template-Desks.csv" -NoTypeInformation
    # endregion

    # region a91 Desk Pools
    $pools = Get-Content ".\Metadata\DeskPools.json" -Raw | ConvertFrom-Json
    $flatPools = foreach ($p in $pools) {
        foreach ($member in $p.Members) {
            [PSCustomObject]@{
                PoolName = $p.PoolName
                Pathway  = $p.Pathway
                DeskId   = $member
            }
        }
    }
    $flatPools | Export-Csv "$folder\Template-DeskPools.csv" -NoTypeInformation
    # endregion

    # region 🏢 Sites
    $sites = Get-Content ".\Metadata\SiteDefinitions.json" -Raw | ConvertFrom-Json
    if ($sites.Count -eq 0) {
        $sites = @(
            [PSCustomObject]@{
                SiteCode = "FRE"
                SiteName = "Fremont HQ"
            }
        )
    }
    $sites | Export-Csv "$folder\Template-Sites.csv" -NoTypeInformation
    # endregion

    # region 🏢 Buildings & Floors
    $buildings = Get-Content ".\Metadata\BuildingDefinitions.json" -Raw | ConvertFrom-Json
    $flatBuildings = foreach ($b in $buildings) {
        foreach ($floor in $b.Floors) {
            [PSCustomObject]@{
                SiteCode     = $b.SiteCode
                BuildingCode = $b.BuildingCode
                BuildingName = $b.BuildingName
                FloorNumber  = $floor.FloorNumber
                FloorName    = $floor.FloorName
                FloorId      = $floor.Id
            }
        }
    }
    if ($flatBuildings) {
        $flatBuildings | Export-Csv "$folder\Template-Buildings.csv" -NoTypeInformation
    }
    # endregion

    # region 🧳 Equipment (sample only if missing)
    $equipmentFile = ".\Metadata\Equipment.json"
    if (!(Test-Path $equipmentFile) -or ((Get-Content $equipmentFile | ConvertFrom-Json).Count -eq 0)) {
        $equipment = @(
            [PSCustomObject]@{
                DisplayName   = "FRE-PROJ-A01"
                Alias         = "freproja01"
                Domain        = $tenantConfig.DefaultDomain
                SiteCode      = "FRE"
                BuildingCode  = "01"
                FloorId       = "FRE-01-F1"
                Pathway       = "FIN"
                EquipmentType = "Projector"
            }
        )
        $equipment | Export-Csv "$folder\Template-Equipment.csv" -NoTypeInformation
    }
    # endregion

    # region 🧾 Done
    Write-Host "`n✅ All templates exported to: $folder" -ForegroundColor Green
    Write-Log "Exported all metadata templates to $folder"
    # endregion
}

# Call the main function
Export-AllTemplates
