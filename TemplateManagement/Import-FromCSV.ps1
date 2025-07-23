<#
.SYNOPSIS
    Imports a CSV metadata file into local metadata storage for supported resource types.
.DESCRIPTION
    This script allows the user to select a CSV file from the .\Imports folder and imports its contents into the appropriate local metadata JSON file. Supports Sites, Buildings+Floors, Desks, Desk Pools, and Equipment. Handles merging and updating of existing records, and logs all actions.
.FILECREATED
    2023-07-01
.FILELASTUPDATED
    2025-07-23
.OUTPUTS
    Updates local metadata JSON files based on imported CSV data.
.EXAMPLE
    .\Import-FromCSV.ps1
    # Imports a selected CSV file from .\Imports into the appropriate metadata store.
.DOCUMENTATION Import-Csv
    https://learn.microsoft.com/en-au/powershell/module/microsoft.powershell.utility/import-csv
#>

# Import global error handling and logging
. (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Logging/GlobalErrorHandling.ps1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Logging/Logging.psm1')

Display-PanelHeader -Title "Import Metadata from CSV"

$importFolder = ".\Imports"
if (!(Test-Path $importFolder)) {
    Write-Log -Message "Imports folder does not exist." -Level 'WARN'
    Read-Host "Press Enter to continue..."
    return
}

$csvFiles = Get-ChildItem $importFolder -Filter *.csv
if ($csvFiles.Count -eq 0) {
    Write-Log -Message "No CSV files found in .\Imports" -Level 'WARN'
    Read-Host "Press Enter to continue..."
    return
}

$file = $csvFiles | Out-GridView -Title "📂 Select a CSV file to import" -PassThru
if (-not $file) { Read-Host "Press Enter to continue..."; return }

$filename = $file.Name
$fullPath = $file.FullName

try {
    $csvData = Import-Csv $fullPath -ErrorAction Stop
    if ($csvData.Count -eq 0) {
        Write-Log -Message "CSV is empty." -Level 'WARN'
        Read-Host "Press Enter to continue..."
        return
    }
}
catch {
    Write-Log -Message "Failed to read CSV file: $_" -Level 'ERROR'
    Read-Host "Press Enter to continue..."
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
            }
            else {
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
                DisplayName        = $row.DisplayName
                Alias              = $row.Alias
                Domain             = $row.Domain
                SiteCode           = $row.SiteCode
                BuildingCode       = $row.BuildingCode
                FloorId            = $row.FloorId
                FloorName          = $row.FloorName
                Pathway            = $row.Pathway
                DeskNumber         = $row.DeskNumber
                Role               = $row.Role
                ObjectType         = "desk"
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
                DisplayName   = $row.DisplayName
                Alias         = $row.Alias
                Domain        = $row.Domain
                SiteCode      = $row.SiteCode
                BuildingCode  = $row.BuildingCode
                FloorId       = $row.FloorId
                Pathway       = $row.Pathway
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



