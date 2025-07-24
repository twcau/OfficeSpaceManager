<#
.SYNOPSIS
    Resource management menu for OfficeSpaceManager CLI.
.DESCRIPTION
    Provides interactive options for creating/editing resources, recovering drafts, retiring/reactivating resources, running booking simulations, and managing desk pools. All output uses inclusive, accessible language and EN-AU spelling.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

. (Join-Path $PSScriptRoot '..\Modules\Utilities\Resolve-OfficeSpaceManagerRoot.ps1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\CLI\CLI.psm1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\Logging\Logging.psm1')
Get-PanelHeader -Title "Manage Resources"

# ðŸ‘‡ Check if any valid drafts exist
$hasDrafts = @(Get-ChildItem ".\.Drafts" -Filter *.json -ErrorAction SilentlyContinue | Where-Object {
        try {
            $null = Get-Content $_.FullName | ConvertFrom-Json -ErrorAction Stop
            return $true
        }
        catch {
            return $false
        }
    }).Count -gt 0

# ðŸ‘‡ Display menu
Write-Host "[1] Create or Edit a Resource (Desk / Room / Equipment)"
if ($hasDrafts) {
    Write-Host "[2] Recover Failed Draft(s)"
}
Write-Host "[3] Retire or Reactivate a Resource"
Write-Host "[4] Run Booking Simulation Test"
Write-Host "[5] Create Desk Pool"
Write-Host "[6] Manage Desk Pools"
Write-Host "[7] Return to Main Menu"

$choice = Read-Host "`nSelect an option"

switch ($choice) {
    '1' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'CLI/Wizards/Manage-ResourceWizard.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Manage-ResourceWizard.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Manage-ResourceWizard.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '2' {
        if ($hasDrafts) {
            try {
                . (Join-Path $env:OfficeSpaceManagerRoot 'CLI/Wizards/Retry-DraftRunner.ps1')
            }
            catch {
                Write-Log -Message "Failed to run Retry-DraftRunner.ps1: $($_.Exception.Message)" -Level 'ERROR'
                Write-Host "\n❌ Error running Retry-DraftRunner.ps1. See log for details." -ForegroundColor Red
                Read-Host "Press Enter to return to menu..."
            }
        }
        else {
            Write-Host "No drafts available to recover." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
    '3' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'CLI/Manage/Toggle-ResourceState.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Toggle-ResourceState.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Toggle-ResourceState.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '4' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'TestSuite/Run-BookingSimulation.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Run-BookingSimulation.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Run-BookingSimulation.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '5' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'CLI/Wizards/Create-DeskPoolWizard.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Create-DeskPoolWizard.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Create-DeskPoolWizard.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '6' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'CLI/Wizards/Manage-DeskPools.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Manage-DeskPools.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Manage-DeskPools.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '7' {
        return
    }
    default {
        Write-Host "Invalid option." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}





