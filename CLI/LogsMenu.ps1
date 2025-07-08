Render-PanelHeader -Title "Metadata & Logs"

Write-Host "[1] Save Metadata Snapshot"
Write-Host "[2] Restore Metadata Snapshot"
Write-Host "[3] View Today's Log"
Write-Host "[4] View Previous Logs"
Write-Host "[5] View Action History Summary"
Write-Host "[6] Compress Old Logs"
Write-Host "[7] Clear Old Logs (With Caution)"
Write-Host "[8] Return to Main Menu"

$choice = Read-Host "`nSelect an option"

switch ($choice) {
    '1' { . "$PSScriptRoot\Backups\Save-MetadataSnapshot.ps1" }

    '2' { . "$PSScriptRoot\Backups\Restore-MetadataSnapshot.ps1" }

    '3' {
        $logDate = Get-Date -Format 'yyyy-MM-dd'
        $logFile = ".\Logs\$logDate.log"
        if (Test-Path $logFile) {
            Get-Content $logFile | Out-Host
        } else {
            Write-Host "No log file found for today." -ForegroundColor Yellow
        }
    }

    '4' {
        . "$PSScriptRoot\Logs\View-LogHistory.ps1"
    }

    '5' {
        . "$PSScriptRoot\Logs\Export-ActionHistory.ps1"
    }

    '6' {
        . "$PSScriptRoot\Logs\Compress-Logs.ps1"
    }

    '7' {
        . "$PSScriptRoot\Logs\Clear-LogHistory.ps1"
    }

    '8' { return }

    default {
        Write-Host "Invalid option." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}

