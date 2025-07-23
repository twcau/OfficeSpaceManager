<#
.SYNOPSIS
    Restores all metadata from a selected snapshot file.
.DESCRIPTION
    This script allows the user to select a metadata snapshot (JSON) and restores all metadata files (sites, buildings, floors, desks, desk pools, rooms, equipment, tenant config) from the snapshot. Overwrites current metadata after confirmation.
.FILECREATED
    2023-07-01
.FILELASTUPDATED
    2025-07-23
.OUTPUTS
    Overwrites metadata JSON files with contents from the selected snapshot.
.EXAMPLE
    .\Restore-MetadataSnapshot.ps1
    # Prompts user to select a snapshot and restores all metadata files.
#>

# List available snapshot files
$snapshotFiles = Get-ChildItem ".\Backups\Snapshots" -Filter "MetadataSnapshot-*.json"
if ($snapshotFiles.Count -eq 0) {
    Write-Host "\u26a0\ufe0f No snapshot files found." -ForegroundColor Yellow
    return
}

# Prompt user to select a snapshot
$selected = $snapshotFiles | Out-GridView -Title "Select a snapshot to restore" -PassThru
if (-not $selected) { return }

# Load snapshot contents
$snapshot = Get-Content $selected.FullName | ConvertFrom-Json

Write-Host "`nThis will overwrite your current metadata. Are you sure?" -ForegroundColor Yellow
$confirm = Read-Host "Type RESTORE to continue"
if ($confirm -ne "RESTORE") {
    Write-Host "Restore cancelled." -ForegroundColor Cyan
    return
}

# Overwrite each metadata file from snapshot
$snapshot.Sites       | ConvertTo-Json -Depth 8 | Set-Content ".\Metadata\Sites.json"
$snapshot.Buildings   | ConvertTo-Json -Depth 8 | Set-Content ".\Metadata\Buildings.json"
$snapshot.Floors      | ConvertTo-Json -Depth 8 | Set-Content ".\Metadata\Floors.json"
$snapshot.Desks       | ConvertTo-Json -Depth 8 | Set-Content ".\Metadata\DeskDefinitions.json"
$snapshot.DeskPools   | ConvertTo-Json -Depth 8 | Set-Content ".\Metadata\DeskPools.json"
$snapshot.Rooms       | ConvertTo-Json -Depth 8 | Set-Content ".\Metadata\Rooms.json"
$snapshot.Equipment   | ConvertTo-Json -Depth 8 | Set-Content ".\Metadata\Equipment.json"
$snapshot.TenantConfig | ConvertTo-Json -Depth 8 | Set-Content ".\config\TenantConfig.json"

Write-Host "\u2705 Metadata restored from snapshot." -ForegroundColor Green
Write-Log "Restored metadata from snapshot: $($selected.Name)"
