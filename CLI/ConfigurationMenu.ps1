<#
.SYNOPSIS
    Configuration and setup menu for OfficeSpaceManager CLI.
.DESCRIPTION
    Provides interactive options for importing/exporting templates, managing sites/buildings/floors, syncing cloud resources, environment setup, validation, and backup/restore. All output uses inclusive, accessible language and EN-AU spelling.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

. (Join-Path $PSScriptRoot '..\Modules\Utilities\Resolve-OfficeSpaceManagerRoot.ps1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\CLI\CLI.psm1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\Logging\Logging.psm1')
Display-PanelHeader -Title "Configuration & Setup"

Write-Host "[1] Import / Export Templates"
Write-Host "[2] Manage Sites, Buildings & Floors"
Write-Host "[3] Sync Cloud Resources to Local Metadata"
Write-Host "[4] Environment Setup & Validation"
Write-Host "[5] Configuration Backup & Restore"
Write-Host "[6] Backup & Templates"
Write-Host "[7] Run First-Time Setup Wizard"
Write-Host "[8] Return to Main Menu"

$choice = Read-Host "`nSelect an option"

switch ($choice) {
    '1' {
        Display-PanelHeader -Title "Import / Export Templates"
        Write-Host "[1.1] Export All Templates"
        Write-Host "[1.2] Validate Templates"
        Write-Host "[1.3] Import Validated Templates"
        $sub = Read-Host "`nSelect an option"
        switch ($sub) {
            '1.1' {
                try {
                    . (Join-Path $env:OfficeSpaceManagerRoot 'TemplateManagement/Export-AllTemplates.ps1')
                }
                catch {
                    Write-Log -Message "Failed to run Export-AllTemplates.ps1: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Export-AllTemplates.ps1. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '1.2' {
                try {
                    . (Join-Path $env:OfficeSpaceManagerRoot 'TemplateManagement/Validate-CSVImport.ps1')
                }
                catch {
                    Write-Log -Message "Failed to run Validate-CSVImport.ps1: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Validate-CSVImport.ps1. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '1.3' {
                try {
                    . (Join-Path $env:OfficeSpaceManagerRoot 'TemplateManagement/Import-FromCSV.ps1')
                }
                catch {
                    Write-Log -Message "Failed to run Import-FromCSV.ps1: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Import-FromCSV.ps1. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
        }
    }
    '2' {
        Display-PanelHeader -Title "Manage Site, Building & Floor Metadata"
        Write-Host "[2.1] Export Site/Building Templates"
        Write-Host "[2.2] Import Site/Building from CSV"
        Write-Host "[2.3] View Current Site/Building Structure"
        Write-Host "[2.4] Return to Previous Menu"
        $sub = Read-Host "`nSelect an option"
        switch ($sub) {
            '2.1' {
                try {
                    Export-SiteStructureTemplates
                }
                catch {
                    Write-Log -Message "Failed to run Export-SiteStructureTemplates: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Export-SiteStructureTemplates. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '2.2' {
                try {
                    Import-SiteStructureFromCSV
                }
                catch {
                    Write-Log -Message "Failed to run Import-SiteStructureFromCSV: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Import-SiteStructureFromCSV. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '2.3' {
                try {
                    Get-SiteStructure
                }
                catch {
                    Write-Log -Message "Failed to run Get-SiteStructure: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Get-SiteStructure. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '2.4' { return }
        }
    }
    '3' {
        Display-PanelHeader -Title "Sync Cloud Resources"
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'SiteManagement/CachedResources/Refresh-CachedResources.ps1') -Force
            Write-Log -Message "Cached metadata refreshed." -Level 'INFO'
        }
        catch {
            Write-Log -Message "Failed to run Refresh-CachedResources.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Refresh-CachedResources.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '4' {
        Display-PanelHeader -Title "Environment Setup & Validation"
        Write-Host "[4.1] Enable Microsoft Places Features"
        Write-Host "[4.2] Validate Microsoft Places Configuration"
        Write-Host "[4.3] Validate Exchange Resource Setup"
        Write-Host "[4.4] Update Mailbox Types in Bulk"
        Write-Host "[4.5] Ensure Calendar Processing Settings"
        Write-Host "[4.6] Pin Places App in Teams"
        $sub = Read-Host "`nSelect an option"
        switch ($sub) {
            '4.1' {
                try {
                    . (Join-Path $env:OfficeSpaceManagerRoot 'Configuration/Enable-PlacesFeatures.ps1')
                }
                catch {
                    Write-Log -Message "Failed to run Enable-PlacesFeatures.ps1: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Enable-PlacesFeatures.ps1. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '4.2' {
                try {
                    . (Join-Path $env:OfficeSpaceManagerRoot 'Configuration/Validate-PlacesFeatures.ps1')
                }
                catch {
                    Write-Log -Message "Failed to run Validate-PlacesFeatures.ps1: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Validate-PlacesFeatures.ps1. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '4.3' {
                try {
                    . (Join-Path $env:OfficeSpaceManagerRoot 'Configuration/Validate-ExchangeSetup.ps1')
                }
                catch {
                    Write-Log -Message "Failed to run Validate-ExchangeSetup.ps1: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Validate-ExchangeSetup.ps1. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '4.4' {
                try {
                    . (Join-Path $env:OfficeSpaceManagerRoot 'EnvironmentSetup/Update-MailboxTypes.ps1')
                }
                catch {
                    Write-Log -Message "Failed to run Update-MailboxTypes.ps1: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Update-MailboxTypes.ps1. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '4.5' {
                try {
                    . (Join-Path $env:OfficeSpaceManagerRoot 'EnvironmentSetup/Ensure-CalendarProcessingSettings.ps1')
                }
                catch {
                    Write-Log -Message "Failed to run Ensure-CalendarProcessingSettings.ps1: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Ensure-CalendarProcessingSettings.ps1. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '4.6' {
                try {
                    . (Join-Path $env:OfficeSpaceManagerRoot 'EnvironmentSetup/Pin-PlacesAppInTeams.ps1')
                }
                catch {
                    Write-Log -Message "Failed to run Pin-PlacesAppInTeams.ps1: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Pin-PlacesAppInTeams.ps1. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
        }
    }
    '5' {
        Display-PanelHeader -Title "Backup & Restore"
        Write-Host "[5.1] Create Configuration Backup (.zip)"
        Write-Host "[5.2] Restore Configuration from Backup"
        Write-Host "[5.3] Return to Previous Menu"
        $sub = Read-Host "`nSelect an option"
        switch ($sub) {
            '5.1' {
                try {
                    . (Join-Path $env:OfficeSpaceManagerRoot 'Configuration/Create-ConfigBackup.ps1')
                }
                catch {
                    Write-Log -Message "Failed to run Create-ConfigBackup.ps1: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Create-ConfigBackup.ps1. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '5.2' {
                try {
                    . (Join-Path $env:OfficeSpaceManagerRoot 'Configuration/Restore-ConfigBackup.ps1')
                }
                catch {
                    Write-Log -Message "Failed to run Restore-ConfigBackup.ps1: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Restore-ConfigBackup.ps1. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '5.3' { return }
            default {
                Write-Host "Invalid option." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
        }
    }
    '6' {
        Display-PanelHeader -Title "Backup & Templates"
        Write-Host "     [6.1] Export All Templates (CSV)"
        Write-Host "     [6.2] Create Backup Archive (ZIP)"
        Write-Host "     [6.3] Restore from Backup Archive"
        Write-Host "     [6.4] Return to Previous Menu"

        $backupChoice = Read-Host "`nChoose an option"
        switch ($backupChoice) {
            '6.1' {
                try {
                    . (Join-Path $env:OfficeSpaceManagerRoot 'TemplateManagement/Export-AllTemplates.ps1')
                }
                catch {
                    Write-Log -Message "Failed to run Export-AllTemplates.ps1: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Export-AllTemplates.ps1. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '6.2' {
                try {
                    . (Join-Path $env:OfficeSpaceManagerRoot 'Configuration/Create-ConfigBackup.ps1')
                }
                catch {
                    Write-Log -Message "Failed to run Create-ConfigBackup.ps1: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Create-ConfigBackup.ps1. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '6.3' {
                try {
                    . (Join-Path $env:OfficeSpaceManagerRoot 'Configuration/Restore-ConfigBackup.ps1')
                }
                catch {
                    Write-Log -Message "Failed to run Restore-ConfigBackup.ps1: $($_.Exception.Message)" -Level 'ERROR'
                    Write-Host "\n❌ Error running Restore-ConfigBackup.ps1. See log for details." -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '6.4' { return }
        }
    }
    '7' {
        try {
            . (Join-Path $env:OfficeSpaceManagerRoot 'Configuration/Invoke-FirstTimeSetup.ps1')
        }
        catch {
            Write-Log -Message "Failed to run Invoke-FirstTimeSetup.ps1: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Error running Invoke-FirstTimeSetup.ps1. See log for details." -ForegroundColor Red
            Read-Host "Press Enter to return to menu..."
        }
    }
    '8' { return }
    default {
        Write-Log -Message "Invalid option." -Level 'WARN'
        Start-Sleep -Seconds 2
    }
}
