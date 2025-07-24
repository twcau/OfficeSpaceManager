<#
.SYNOPSIS
    Metadata and logs menu for OfficeSpaceManager CLI.
.DESCRIPTION
    Provides interactive options for saving/restoring metadata snapshots, viewing logs, exporting action history, compressing and clearing logs. All output uses inclusive, accessible language and EN-AU spelling.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

. (Join-Path $PSScriptRoot '..\Modules\Utilities\Resolve-OfficeSpaceManagerRoot.ps1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\CLI\CLI.psm1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\Logging\Logging.psm1')
Get-PanelHeader -Title "Metadata & Logs"

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
    '1' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'Backups/Save-MetadataSnapshot.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Save-MetadataSnapshot.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Save-MetadataSnapshot.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '2' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'Backups/Restore-MetadataSnapshot.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Restore-MetadataSnapshot.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Restore-MetadataSnapshot.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '3' {
        $logDate = Get-Date -Format 'yyyy-MM-dd'
        $logFile = ".\Logs\$logDate.log"
        if (Test-Path $logFile) {
            Get-Content $logFile | Out-Host
        }
        else {
            Write-Host "No log file found for today." -ForegroundColor Yellow
            Read-Host "Press Enter to return to menu..."
        }
    }
    '4' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'Logs/View-LogHistory.ps1')
        }
        catch {
            Write-Log -Message "Failed to run View-LogHistory.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running View-LogHistory.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '5' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'Logs/Export-ActionHistory.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Export-ActionHistory.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Export-ActionHistory.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '6' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'Logs/Compress-Logs.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Compress-Logs.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Compress-Logs.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '7' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'Logs/Clear-LogHistory.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Clear-LogHistory.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Clear-LogHistory.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '8' { return }
    default {
        Write-Host "Invalid option." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}





