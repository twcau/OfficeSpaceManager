<#
.SYNOPSIS
    Imports site/building structure from a selected CSV template.
.DESCRIPTION
    Imports and processes site/building structure from CSV templates, updating metadata JSON files. Uses EN-AU spelling and accessible output.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

Import-Module "$PSScriptRoot/../Modules/Logging/Logging.psm1"
Import-Module "$PSScriptRoot/../Modules/SiteManagement/SiteManagement.psm1"

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

        # Build nested JSON grouped by building
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
                BuildingCode  = $first.BuildingCode
                BuildingName  = $first.BuildingName
                SiteCode      = $first.SiteCode
                Floors        = $floors
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

Import-SiteStructureFromCSV
