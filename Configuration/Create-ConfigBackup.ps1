. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
function Create-ConfigBackup {
    Render-PanelHeader -Title "Creating Configuration Backup"

    $timestamp = Get-Date -Format 'yyyy-MM-dd-HHmm'
    $zipPath = ".\Backups\ConfigBackup-$timestamp.zip"

    if (!(Test-Path ".\Backups")) {
        New-Item -Path ".\Backups" -ItemType Directory | Out-Null
    }

    $itemsToBackup = @()
    $paths = @(".\Metadata", ".\Logs", ".\config")

    foreach ($p in $paths) {
        if (Test-Path $p) {
            $itemsToBackup += $p
        } else {
Write-Log -Message "Skipping missing path: $p" -Level 'WARN'
        }
    }

    # Include specific JSON files from Backups
    $jsonFiles = Get-ChildItem ".\Backups" -Filter *.json -ErrorAction SilentlyContinue
    if ($jsonFiles) {
        $itemsToBackup += $jsonFiles.FullName
    }

    if ($itemsToBackup.Count -eq 0) {
Write-Log -Message "No valid content found to back up. Backup aborted." -Level 'WARN'
        Write-Log "Backup skipped — no items found."
        return
    }

    Compress-Archive -Path $itemsToBackup -DestinationPath $zipPath -Force

    Write-Host "`n📦 Backup created: $zipPath" -ForegroundColor Green
    Write-Log "Created config backup ZIP: $zipPath"
}

Create-ConfigBackup
