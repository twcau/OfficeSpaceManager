<#
.SYNOPSIS
    Saves a snapshot of all current metadata files to a timestamped JSON file.
.DESCRIPTION
    This script collects all key metadata files (sites, buildings, floors, desks, desk pools, rooms, equipment, tenant config) and saves them as a single JSON snapshot in the Backups/Snapshots folder. Used for backup and restore operations.
.FILECREATED
    2023-07-01
.FILELASTUPDATED
    2025-07-23
.OUTPUTS
    A timestamped JSON snapshot file in .\Backups\Snapshots.
.EXAMPLE
    .\Save-MetadataSnapshot.ps1
    # Saves a snapshot of all metadata files to a timestamped JSON file.
#>

# Generate timestamp and ensure output directory exists
$timestamp = Get-Date -Format "yyyy-MM-ddTHH-mm-ss"
$outputDir = ".\Backups\Snapshots"
if (!(Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }

# Collect all metadata into a single object
$snapshot = @{
    Sites       = Get-Content ".\Metadata\Sites.json" | ConvertFrom-Json
    Buildings   = Get-Content ".\Metadata\Buildings.json" | ConvertFrom-Json
    Floors      = Get-Content ".\Metadata\Floors.json" | ConvertFrom-Json
    Desks       = Get-Content ".\Metadata\DeskDefinitions.json" | ConvertFrom-Json
    DeskPools   = Get-Content ".\Metadata\DeskPools.json" | ConvertFrom-Json
    Rooms       = Get-Content ".\Metadata\Rooms.json" | ConvertFrom-Json
    Equipment   = Get-Content ".\Metadata\Equipment.json" | ConvertFrom-Json
    TenantConfig = Get-Content ".\config\TenantConfig.json" | ConvertFrom-Json
}

# Save snapshot to file
$snapshot | ConvertTo-Json -Depth 10 | Set-Content "$outputDir\MetadataSnapshot-$timestamp.json"

Write-Host "\u2705 Snapshot saved: MetadataSnapshot-$timestamp.json" -ForegroundColor Green
Write-Log "Saved metadata snapshot at $timestamp"
