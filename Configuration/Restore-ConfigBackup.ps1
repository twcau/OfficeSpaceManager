function Restore-ConfigBackup {
    Render-PanelHeader -Title "Restore Metadata from Backup Archive"

    # ðŸ§­ Step 1: Select Backup
    $backups = Get-ChildItem ".\Backups" -Filter *.zip -ErrorAction SilentlyContinue
    if (-not $backups) {
        Write-Warning "âŒ No backup archives found in .\Backups"
        return
    }

    try {
        $file = $backups | Out-GridView -Title "Select Backup to Restore" -PassThru
    } catch {
        $file = $backups | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        Write-Warning "âš ï¸ Out-GridView unavailable. Using most recent backup: $($file.Name)"
    }

    if (-not $file) { return }

    # ðŸ—ƒï¸ Step 2: Unpack
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $restoreFolder = ".\Temp\Restore_$timestamp"

    if (!(Test-Path $restoreFolder)) {
        New-Item -Path $restoreFolder -ItemType Directory | Out-Null
    }

    Expand-Archive -Path $file.FullName -DestinationPath $restoreFolder -Force
    Write-Log "Expanded backup to $restoreFolder"

    # ðŸ” Step 3: Validate Required Files
    $requiredFiles = @(
        "DeskDefinitions.json",
        "DeskPools.json",
        "SiteDefinitions.json",
        "BuildingDefinitions.json"
    )

    $missing = @()
    foreach ($f in $requiredFiles) {
        $path = Join-Path $restoreFolder $f
        if (-not (Test-Path $path)) {
            $missing += $f
        }
    }

    if ($missing.Count -gt 0) {
        Write-Warning "`nâŒ The following required files were missing from the archive:"
        $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
        Write-Log "Restore aborted. Missing files: $($missing -join ', ')"
        return
    }

    # ðŸ§ª Step 4: Validate JSON and summarize
    function Try-LoadJson($filePath) {
        try {
            return Get-Content $filePath -Raw | ConvertFrom-Json -ErrorAction Stop
        } catch {
            Write-Warning "âŒ Invalid JSON in $filePath"
            throw
        }
    }

    $desks     = Try-LoadJson "$restoreFolder\DeskDefinitions.json"
    $pools     = Try-LoadJson "$restoreFolder\DeskPools.json"
    $sites     = Try-LoadJson "$restoreFolder\SiteDefinitions.json"
    $buildings = Try-LoadJson "$restoreFolder\BuildingDefinitions.json"

    Write-Host "`nðŸ“‹ Summary of Incoming Metadata:`n" -ForegroundColor Cyan
    Write-Host "  Desks:      $($desks.Count)"
    Write-Host "  Desk Pools: $($pools.Count)"
    Write-Host "  Sites:      $($sites.Count)"
    Write-Host "  Buildings:  $($buildings.Count)"

    # ðŸ” Step 5: Backup existing metadata first
    $backupChoice = Read-Host "`nDo you want to backup existing metadata before restore? (Y/N)"
    if ($backupChoice -eq 'Y') {
. "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\Configuration\Create-ConfigBackup.ps1"
    }

    # âœ… Step 6: Confirm restore
    $confirm = Read-Host "`nProceed with overwriting current metadata with the above? (Y/N)"
    if ($confirm -ne 'Y') {
        Write-Warning "âŒ Restore cancelled by user."
        return
    }

    # ðŸš€ Step 7: Restore JSON files
    Copy-Item "$restoreFolder\*.json" ".\Metadata\" -Force
    Write-Host "`nâœ… Metadata restored successfully." -ForegroundColor Green
    Write-Log "Restored metadata from backup: $($file.Name)"

    # ðŸ§¼ Step 8: Clean temp
    try {
        Remove-Item $restoreFolder -Recurse -Force -ErrorAction Stop
    } catch {
        Write-Warning "âš ï¸ Could not delete temp folder: $restoreFolder"
    }
}

Restore-ConfigBackup



