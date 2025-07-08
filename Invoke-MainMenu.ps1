<#
.SYNOPSIS
    CLI Terminal Navigation Shell for OfficeSpaceManager
.DESCRIPTION
    Root launcher that governs CLI flow, validates setup, syncs resources,
    and routes to all submenus.
.LASTUPDATED
    2025-07-08
#>

# region âš ï¸ Global Error Handling
$ErrorActionPreference = 'Stop'
# endregion

try {
    # region ðŸ”§ PowerShell 7+ Check
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

    # region ðŸ”§ Required Modules Check
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
                    Write-Host "Installed $mod successfully." -ForegroundColor Green
                } catch {
                    Write-Error "âŒ Failed to install ${mod}: $($_.Exception.Message)"
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

    # region ðŸŒ Init Logging
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

    # region ðŸ§° First-Time Setup Check
    $configPath = ".\config\FirstRunComplete.json"
    if (-not (Test-Path $configPath)) {
        if (!(Test-Path ".\config")) { New-Item ".\config" -ItemType Directory | Out-Null }
. "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\Configuration\Run-FirstTimeSetup.ps1"
    }
    # endregion

    # region ðŸ” Load Global UI Utilities
. "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\CLI\Show-ActionHistory.ps1"
. "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\CLI\Render-PanelHeader.ps1"
    # endregion

    # region 🧼 Check Cached Metadata Freshness
$syncAgeDays = 3
$lastSyncPath = ".\Metadata\.lastSync.json"
if (Test-Path $lastSyncPath) {
    $lastSync = (Get-Content $lastSyncPath | ConvertFrom-Json).LastRefreshed
    $lastSyncDate = Get-Date $lastSync
    $timeSinceSync = New-TimeSpan -Start $lastSyncDate -End (Get-Date)
    $daysOld = $timeSinceSync.Days
    $minutesOld = [int]$timeSinceSync.TotalMinutes

    Write-Log "Last metadata sync was $minutesOld minutes ago ($daysOld days)."

    if ($daysOld -ge $syncAgeDays) {
        Write-Warning "⚠️ Cached metadata is $daysOld days old."
        Write-Log "Metadata cache is stale (>$syncAgeDays days)."

        $doBackup = Read-Host "Backup metadata before syncing? (Y/N)"
        if ($doBackup -eq 'Y') {
            Write-Log "User opted to back up config before sync."
            . "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\Configuration\Create-ConfigBackup.ps1"
        }

        $doSync = Read-Host "Sync cloud metadata now? (Y/N)"
        if ($doSync -eq 'Y') {
            Write-Log "User opted to sync metadata (manual confirmation)."
            . "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
        } else {
            Write-Log "User skipped metadata sync despite stale cache."
        }
    }
    elseif ($minutesOld -le 15) {
        Write-Host "🕒 Last metadata sync was just $minutesOld minutes ago."
        Write-Log "Recent metadata cache detected (<15 mins)."

        $quickDecision = Read-Host "Skip sync and use recent cache? (Y/N)"
        if ($quickDecision -ne 'Y') {
            Write-Log "User chose to refresh metadata despite recent sync."
            . "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
        }
        else {
            Write-Log "User skipped metadata sync (recent cache accepted)."
            Write-Host "⏩ Skipping sync and using recent cached data."
        }
    }
}
else {
    Write-Warning "❌ No metadata sync file found. Performing initial sync..."
    Write-Log "No existing .lastSync.json found. Initiating first-time sync."
    . "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
}
# endregion


    # region ðŸ§¼ Preload Cached Metadata (Always)
. "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\SiteManagement\CachedResources\Refresh-CachedResources.ps1"
    # endregion

    # region ðŸ§­ Main Menu Navigation
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
            '1' { . "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\CLI\ManageResourcesMenu.ps1" }
            '2' { . "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\CLI\OrphanMetadataMenu.ps1" }
            '3' { . "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\CLI\ConfigurationMenu.ps1" }
            '4' { . "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\CLI\LogsMenu.ps1" }
            '5' { . "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\CLI\Configuration\Run-FirstTimeSetup.ps1" }
            '6' {
                Write-Host "`nExiting..." -ForegroundColor Cyan
                . "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
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
    Write-Host "`nâŒ A critical error occurred while running the CLI:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Log "â€¼ï¸ Script-level exception: $($_.Exception.Message)"
    Read-Host "`nPress Enter to exit..."
    exit
}

# region ðŸ§¼ Exit Cleanup
. "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
Write-Log "Exited session and refreshed cache"
Write-Host "`nSession ended. Cache refreshed. Goodbye!" -ForegroundColor Green
# endregion
