<#
.SYNOPSIS
    Exports all supported metadata templates (desks, desk pools, sites, buildings, floors, etc.)
    into a date-stamped folder for bulk data import.
#>

function Export-AllTemplates {
    Render-PanelHeader -Title "Export All Metadata Templates"

    # region 🔍 Domain Context for Templates
    $tenantConfigPath = ".\config\TenantConfig.json"
    if (-not (Test-Path $tenantConfigPath)) {
        Write-Warning "TenantConfig.json not found. Please run first-time setup."
        return
    }
    $tenantConfig = Get-Content $tenantConfigPath | ConvertFrom-Json
    $domains = @($tenantConfig.DefaultDomain) + ($tenantConfig.Domains | Where-Object { $_ -ne $tenantConfig.DefaultDomain })
    $domainHint = ($domains -join ", ")
    # endregion

    # region 📁 Folder Structure
    $exportDate = Get-Date -Format 'yyyy-MM-dd'
    $folder = ".\Exports\$exportDate"
    if (!(Test-Path $folder)) { New-Item -ItemType Directory -Path $folder | Out-Null }
    # endregion

    # region 🪑 Desks
    $desks = Get-Content ".\Metadata\DeskDefinitions.json" -Raw | ConvertFrom-Json
    if ($desks.Count -eq 0) {
        $desks = @(
            [PSCustomObject]@{
                DisplayName       = "FRE-FIN-17 Ops Desk"
                Alias             = "frefin17ops"
                Domain            = $tenantConfig.DefaultDomain
                SiteCode          = "FRE"
                BuildingCode      = "01"
                FloorId           = "FRE-01-F1"
                FloorName         = "Level 1"
                Pathway           = "FIN"
                DeskNumber        = "17"
                Role              = "Ops"
                ObjectType        = "desk"
                IsHeightAdjustable = "Y"
                HasDockingStation  = "Y"
                IsAccessible       = "N"
            }
        )
    }
    $desks | Export-Csv "$folder\Template-Desks.csv" -NoTypeInformation
    # endregion

    # region 🪑 Desk Pools
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
    if ($flatPools) {
        $flatPools | Export-Csv "$folder\Template-DeskPools.csv" -NoTypeInformation
    }
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
                DisplayName    = "FRE-PROJ-A01"
                Alias          = "freproja01"
                Domain         = $tenantConfig.DefaultDomain
                SiteCode       = "FRE"
                BuildingCode   = "01"
                FloorId        = "FRE-01-F1"
                Pathway        = "FIN"
                EquipmentType  = "Projector"
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

Export-AllTemplates
