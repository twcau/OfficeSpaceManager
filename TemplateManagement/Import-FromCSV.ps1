. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
<#
.SYNOPSIS
    Imports a CSV metadata file into local metadata storage
.DESCRIPTION
    Supports Sites, Buildings+Floors, Desks, Desk Pools, and Equipment resources.
#>

. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Write-Log.ps1"
Render-PanelHeader -Title "Import Metadata from CSV"

$importFolder = ".\Imports"
if (!(Test-Path $importFolder)) {
Write-Log -Message "Imports folder does not exist." -Level 'WARN'
    return
}

$csvFiles = Get-ChildItem $importFolder -Filter *.csv
if ($csvFiles.Count -eq 0) {
Write-Log -Message "No CSV files found in .\Imports" -Level 'WARN'
    return
}

$file = $csvFiles | Out-GridView -Title "📂 Select a CSV file to import" -PassThru
if (-not $file) { return }

$filename = $file.Name
$fullPath = $file.FullName

try {
    $csvData = Import-Csv $fullPath -ErrorAction Stop
    if ($csvData.Count -eq 0) {
Write-Log -Message "CSV is empty." -Level 'WARN'
        return
    }
} catch {
Write-Log -Message "Failed to read CSV file: $_" -Level 'ERROR'
    return
}

# region 🧠 Routing based on filename
switch ($filename) {

    'Template-Sites.csv' {
        $target = ".\Metadata\Sites.json"
        $merged = @()
        $existing = @()
        if (Test-Path $target) {
            $existing = Get-Content $target | ConvertFrom-Json
        }
        foreach ($row in $csvData) {
            $match = $existing | Where-Object { $_.SiteCode -eq $row.SiteCode }
            if ($match) {
Write-Log -Message "Updating site: $($row.SiteCode)" -Level 'INFO'
                $existing = $existing | Where-Object { $_.SiteCode -ne $row.SiteCode }
            } else {
Write-Log -Message "Adding site: $($row.SiteCode)" -Level 'INFO'
            }
            $merged += [PSCustomObject]@{
                SiteCode = $row.SiteCode
                SiteName = $row.SiteName
            }
        }
        $result = $existing + $merged
        $result | ConvertTo-Json -Depth 6 | Set-Content $target
        Write-Log "Imported Sites metadata from $filename"
    }

    'Template-Buildings.csv' {
        $target = ".\Metadata\Buildings.json"
        $grouped = $csvData | Group-Object -Property SiteCode, BuildingCode

        $buildings = foreach ($group in $grouped) {
            $sample = $group.Group[0]
            $floors = foreach ($row in $group.Group) {
                [PSCustomObject]@{
                    FloorNumber = $row.FloorNumber
                    FloorName   = $row.FloorName
                    FloorId     = $row.FloorId
                }
            }
            [PSCustomObject]@{
                SiteCode     = $sample.SiteCode
                BuildingCode = $sample.BuildingCode
                BuildingName = $sample.BuildingName
                Floors       = $floors
            }
        }

        $buildings | ConvertTo-Json -Depth 8 | Set-Content $target
        Write-Log "Imported Buildings/Floors from $filename"
    }

    'Template-Desks.csv' {
        $target = ".\Metadata\Desks.json"
        $converted = foreach ($row in $csvData) {
            [PSCustomObject]@{
                DisplayName       = $row.DisplayName
                Alias             = $row.Alias
                Domain            = $row.Domain
                SiteCode          = $row.SiteCode
                BuildingCode      = $row.BuildingCode
                FloorId           = $row.FloorId
                FloorName         = $row.FloorName
                Pathway           = $row.Pathway
                DeskNumber        = $row.DeskNumber
                Role              = $row.Role
                ObjectType        = "desk"
                IsHeightAdjustable = $row.IsHeightAdjustable
                HasDockingStation  = $row.HasDockingStation
                IsAccessible       = $row.IsAccessible
            }
        }
        $converted | ConvertTo-Json -Depth 8 | Set-Content $target
        Write-Log "Imported Desk metadata from $filename"
    }

    'Template-DeskPools.csv' {
        $target = ".\Metadata\DeskPools.json"
        $grouped = $csvData | Group-Object -Property PoolName

        $pools = foreach ($group in $grouped) {
            $members = $group.Group | Select-Object -ExpandProperty DeskId
            $pathway = $group.Group[0].Pathway
            [PSCustomObject]@{
                PoolName = $group.Name
                Pathway  = $pathway
                Members  = $members
            }
        }

        $pools | ConvertTo-Json -Depth 6 | Set-Content $target
        Write-Log "Imported Desk Pools from $filename"
    }

    'Template-Equipment.csv' {
        $target = ".\Metadata\Equipment.json"
        $converted = foreach ($row in $csvData) {
            [PSCustomObject]@{
                DisplayName  = $row.DisplayName
                Alias        = $row.Alias
                Domain       = $row.Domain
                SiteCode     = $row.SiteCode
                BuildingCode = $row.BuildingCode
                FloorId      = $row.FloorId
                Pathway      = $row.Pathway
                EquipmentType = $row.EquipmentType
            }
        }
        $converted | ConvertTo-Json -Depth 8 | Set-Content $target
        Write-Log "Imported Equipment metadata from $filename"
    }

    default {
Write-Log -Message "No import logic exists for: $filename" -Level 'WARN'
    }
}



