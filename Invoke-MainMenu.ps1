<#
.SYNOPSIS
    CLI Terminal Navigation Shell for OfficeSpaceManager
.DESCRIPTION
    Root launcher that governs CLI flow, validates setup, syncs resources,
    and routes to all submenus.
.LASTUPDATED
    2025-07-08
#>

# region ⚠️ Global Error Handling
$ErrorActionPreference = 'Stop'
# endregion

try {
    # region 🔧 PowerShell 7+ Check
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Warning "This tool requires PowerShell 7 or higher."
        if (Get-Command "pwsh" -ErrorAction SilentlyContinue) {
            Write-Host "Launching in PowerShell 7..."
            Start-Process "pwsh.exe" "-File `"$PSCommandPath`""
            exit
        } else {
            Write-Host "Please install PowerShell 7: https://learn.microsoft.com/powershell/scripting/install/installing-powershell"
            exit
        }
    }
    # endregion

    # region 🔧 Required Modules Check
    $requiredModules = @(
        'ExchangeOnlineManagement',
        'Microsoft.Graph',
        'MicrosoftTeams'
    )

    foreach ($mod in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $mod)) {
            Write-Warning "Required module '$mod' is missing."
            $choice = Read-Host "Do you want to install $mod now? (Y/N)"
            if ($choice -eq 'Y') {
                try {
                    Install-Module -Name $mod -Scope CurrentUser -Force -ErrorAction Stop
                    Write-Host "✔️ Installed $mod successfully." -ForegroundColor Green
                } catch {
                    Write-Error "❌ Failed to install ${mod}: $($_.Exception.Message)"
                    Read-Host "Press Enter to continue or Ctrl+C to exit"
                }
            } else {
                Write-Error "Cannot continue without $mod. Please install it manually."
                Read-Host "Press Enter to exit..."
                exit
            }
        }
    }
    # endregion

    # region 🌐 Init Logging
    $Global:ActionLog = @()
    $LogDate = Get-Date -Format 'yyyy-MM-dd'
    $Global:LogFile = ".\Logs\$LogDate.log"
    if (!(Test-Path ".\Logs")) { New-Item ".\Logs" -ItemType Directory | Out-Null }

    function Write-Log {
        $timestamp = Get-Date -Format "HH:mm:ss"
        $entry = "[$timestamp] $Message"
        Add-Content -Path $Global:LogFile -Value $entry
        $Global:ActionLog += $entry
    }
    Write-Log "Session started."
    # endregion

    # region 🧰 First-Time Setup Check
    $configPath = ".\config\FirstRunComplete.json"
    if (-not (Test-Path $configPath)) {
        if (!(Test-Path ".\config")) { New-Item ".\config" -ItemType Directory | Out-Null }
        . "$PSScriptRoot\Configuration\Run-FirstTimeSetup.ps1"
    }
    # endregion

    # region 🔁 Load Global UI Utilities
    . "$PSScriptRoot\CLI\Show-ActionHistory.ps1"
    . "$PSScriptRoot\CLI\Render-PanelHeader.ps1"
    # endregion

    # region 🧼 Check Cached Metadata Freshness
    $syncAgeDays = 3
    $lastSyncPath = ".\Metadata\.lastSync.json"
    if (Test-Path $lastSyncPath) {
        $lastSync = (Get-Content $lastSyncPath | ConvertFrom-Json).LastRefreshed
        $lastSyncDate = Get-Date $lastSync
        $daysOld = (New-TimeSpan -Start $lastSyncDate -End (Get-Date)).Days
        if ($daysOld -ge $syncAgeDays) {
            Write-Warning "⚠️ Cached metadata is $daysOld days old."
            $doBackup = Read-Host "Backup metadata before syncing? (Y/N)"
            if ($doBackup -eq 'Y') {
                . "$PSScriptRoot\Configuration\Create-ConfigBackup.ps1"
            }
            $doSync = Read-Host "Sync cloud metadata now? (Y/N)"
            if ($doSync -eq 'Y') {
                . "$PSScriptRoot\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
            }
        }
    }
    # endregion

    # region 🧼 Preload Cached Metadata (Always)
    . "$PSScriptRoot\SiteManagement\CachedResources\Refresh-CachedResources.ps1"
    # endregion

    # region 🧭 Main Menu Navigation
    do {
        Clear-Host
        Render-PanelHeader -Title "OfficeSpaceManager - Main Menu"

        Write-Host "[1] Manage Resources"
        Write-Host "[2] Orphan & Metadata Management"
        Write-Host "[3] Configuration & Setup"
        Write-Host "[4] Metadata & Logs"
        Write-Host "[5] Run First-Time Setup Wizard"
        Write-Host "[6] Exit"

        Show-ActionHistory
        $selection = Read-Host "`nSelect an option"

        switch ($selection) {
            '1' { . "$PSScriptRoot\ManageResourcesMenu.ps1" }
            '2' { . "$PSScriptRoot\OrphanMetadataMenu.ps1" }
            '3' { . "$PSScriptRoot\ConfigurationMenu.ps1" }
            '4' { . "$PSScriptRoot\LogsMenu.ps1" }
            '5' { . "$PSScriptRoot\Configuration\Run-FirstTimeSetup.ps1" }
            '6' {
                Write-Host "`nExiting..." -ForegroundColor Cyan
                . "$PSScriptRoot\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
                Write-Log "User exited the script."
                exit
            }
            default {
                Write-Host "Invalid option." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
        }
    } while ($true)
    # endregion

} catch {
    Write-Host "`n❌ A critical error occurred while running the CLI:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Log "‼️ Script-level exception: $($_.Exception.Message)"
    Read-Host "`nPress Enter to exit..."
    exit
}

# region 🧼 Exit Cleanup
. "$PSScriptRoot\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
Write-Log "Exited session and refreshed cache"
Write-Host "`nSession ended. Cache refreshed. Goodbye!" -ForegroundColor Green
# endregion

