$snapshotFiles = Get-ChildItem ".\Backups\Snapshots" -Filter "MetadataSnapshot-*.json"
if ($snapshotFiles.Count -eq 0) {
    Write-Host "⚠️ No snapshot files found." -ForegroundColor Yellow
    return
}

$selected = $snapshotFiles | Out-GridView -Title "Select a snapshot to restore" -PassThru
if (-not $selected) { return }

$snapshot = Get-Content $selected.FullName | ConvertFrom-Json

Write-Host "`nThis will overwrite your current metadata. Are you sure?" -ForegroundColor Yellow
$confirm = Read-Host "Type RESTORE to continue"
if ($confirm -ne "RESTORE") {
    Write-Host "Restore cancelled." -ForegroundColor Cyan
    return
}

# Write back each file
$snapshot.Sites       | ConvertTo-Json -Depth 8 | Set-Content ".\Metadata\Sites.json"
$snapshot.Buildings   | ConvertTo-Json -Depth 8 | Set-Content ".\Metadata\Buildings.json"
$snapshot.Floors      | ConvertTo-Json -Depth 8 | Set-Content ".\Metadata\Floors.json"
$snapshot.Desks       | ConvertTo-Json -Depth 8 | Set-Content ".\Metadata\DeskDefinitions.json"
$snapshot.DeskPools   | ConvertTo-Json -Depth 8 | Set-Content ".\Metadata\DeskPools.json"
$snapshot.Rooms       | ConvertTo-Json -Depth 8 | Set-Content ".\Metadata\Rooms.json"
$snapshot.Equipment   | ConvertTo-Json -Depth 8 | Set-Content ".\Metadata\Equipment.json"
$snapshot.TenantConfig | ConvertTo-Json -Depth 8 | Set-Content ".\config\TenantConfig.json"

Write-Host "✅ Metadata restored from snapshot." -ForegroundColor Green
Write-Log "Restored metadata from snapshot: $($selected.Name)"
