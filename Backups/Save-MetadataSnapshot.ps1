$timestamp = Get-Date -Format "yyyy-MM-ddTHH-mm-ss"
$outputDir = ".\Backups\Snapshots"
if (!(Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }

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

$snapshot | ConvertTo-Json -Depth 10 | Set-Content "$outputDir\MetadataSnapshot-$timestamp.json"

Write-Host "✅ Snapshot saved: MetadataSnapshot-$timestamp.json" -ForegroundColor Green
Write-Log "Saved metadata snapshot at $timestamp"
