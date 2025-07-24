<#
.SYNOPSIS
    Orphan and metadata management menu for OfficeSpaceManager CLI.
.DESCRIPTION
    Provides interactive options for finding/fixing orphaned resources, validating desk pool mappings, detecting non-standard resource names, and suggesting renames. All output uses inclusive, accessible language and EN-AU spelling.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

# Robustly resolve project root for all module imports
. (Join-Path $PSScriptRoot '..\Modules\Utilities\Resolve-OfficeSpaceManagerRoot.ps1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\CLI\CLI.psm1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\Logging\Logging.psm1')
Get-PanelHeader -Title "Orphan & Metadata Management"

Write-Host "[1] Find Orphaned Resources"
Write-Host "[2] Fix Orphaned Resources"
Write-Host "[3] Validate Desk Pool Mappings"
Write-Host "[4] Detect Non-Standard Resource Names"
Write-Host "[5] Suggest and Apply Renames"
Write-Host "[6] Return to Main Menu"

$choice = Read-Host "`nSelect an option"

switch ($choice) {
    '1' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'OrphanFixer/Find-OrphanedResources.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Find-OrphanedResources.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Find-OrphanedResources.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '2' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'OrphanFixer/Repair-OrphanedResources.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Repair-OrphanedResources.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Repair-OrphanedResources.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '3' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'OrphanFixer/Test-DeskPoolMappings.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Test-DeskPoolMappings.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Test-DeskPoolMappings.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '4' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'OrphanFixer/Test-NonStandardResources.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Test-NonStandardResources.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Test-NonStandardResources.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '5' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'OrphanFixer/Invoke-RenameResource.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Invoke-RenameResource.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Invoke-RenameResource.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '6' { return }
    default {
        Write-Host "Invalid option." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}
