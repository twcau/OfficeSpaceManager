<#
.SYNOPSIS
    Validates structure and content of metadata CSV templates before importing.
.DESCRIPTION
    Ensures correct headers, sample row values, and flags anything that would break import logic.
#>

. "$PSScriptRoot\..\Shared\Write-Log.ps1"
Render-PanelHeader -Title "CSV Template Validation"

$importFolder = ".\Imports"
if (!(Test-Path $importFolder)) {
    Write-Warning "No .\Imports folder found. Please place CSV files there first."
    return
}

$csvFiles = Get-ChildItem $importFolder -Filter *.csv
if ($csvFiles.Count -eq 0) {
    Write-Warning "No CSV files found in .\Imports."
    return
}

Write-Host "`n📁 Available CSV files in .\Imports:" -ForegroundColor Cyan
$selected = $csvFiles | Out-GridView -Title "Select a CSV file to validate" -PassThru
if (-not $selected) { return }

$csvPath = $selected.FullName
$fileName = $selected.Name

# region 🔎 Load and Sample
try {
    $data = Import-Csv $csvPath -ErrorAction Stop
    if ($data.Count -eq 0) {
        Write-Warning "CSV appears empty."
        return
    }
} catch {
    Write-Warning "❌ Failed to load CSV: $_"
    return
}

# region 🎯 Expected Headers by File
$expectedHeadersMap = @{
    'Template-Desks.csv' = @('DisplayName','Alias','Domain','SiteCode','BuildingCode','FloorId','FloorName','Pathway','DeskNumber','Role','ObjectType','IsHeightAdjustable','HasDockingStation','IsAccessible')
    'Template-DeskPools.csv' = @('PoolName','Pathway','DeskId')
    'Template-Sites.csv' = @('SiteCode','SiteName')
    'Template-Buildings.csv' = @('SiteCode','BuildingCode','BuildingName','FloorNumber','FloorName','FloorId')
    'Template-Equipment.csv' = @('DisplayName','Alias','Domain','SiteCode','BuildingCode','FloorId','Pathway','EquipmentType')
}

if (-not $expectedHeadersMap.ContainsKey($fileName)) {
    Write-Warning "⚠️ Unknown file type: $fileName. No validation map available."
    return
}
$expected = $expectedHeadersMap[$fileName]
# endregion

# region 🧪 Validate Headers
$headers = $data[0].PSObject.Properties.Name
$missing = $expected | Where-Object { $_ -notin $headers }
$unexpected = $headers | Where-Object { $_ -notin $expected }

if ($missing.Count -gt 0) {
    Write-Warning "Missing expected fields: $($missing -join ', ')"
    Write-Log "CSV Validation: Missing headers in $fileName: $($missing -join ', ')"
}
if ($unexpected.Count -gt 0) {
    Write-Warning "Unexpected fields present: $($unexpected -join ', ')"
    Write-Log "CSV Validation: Extra fields in $fileName: $($unexpected -join ', ')"
}

if ($missing.Count -gt 0) {
    Write-Host "`n❌ Cannot proceed until required fields are present." -ForegroundColor Red
    return
}

# region ✅ Sample Row Validation
Write-Host "`n🔍 Previewing sample rows..." -ForegroundColor Cyan
$data | Select-Object -First 5 | Format-Table | Out-Host

$invalidRows = @()
$rowNum = 1

foreach ($row in $data) {
    $rowNum++
    foreach ($field in $expected) {
        if (-not $row.$field -and $row.$field -ne 0) {
            $invalidRows += "Row $rowNum → Missing value in '$field'"
        }
    }
}

if ($invalidRows.Count -gt 0) {
    Write-Host "`n⚠️ Found $($invalidRows.Count) data issues:" -ForegroundColor Yellow
    $invalidRows | Select-Object -First 10 | ForEach-Object { Write-Host $_ }
    if ($invalidRows.Count -gt 10) {
        Write-Host "...and $($invalidRows.Count - 10) more issues not shown"
    }
    Write-Log "CSV validation for $fileName found $($invalidRows.Count) row-level issues."
} else {
    Write-Host "`n✅ All rows passed structure validation." -ForegroundColor Green
    Write-Log "CSV validation passed for $fileName"
}

# endregion
