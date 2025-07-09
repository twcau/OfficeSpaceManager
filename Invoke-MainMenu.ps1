<#
.SYNOPSIS
    CLI Terminal Navigation Shell for OfficeSpaceManager
.DESCRIPTION
    Root launcher that governs CLI flow, validates setup, syncs resources,
    and routes to all submenus.
.LASTUPDATED
    2025-07-08
#>

. "$PSScriptRoot/Shared/Global-ErrorHandling.ps1"

try {
    # region ðŸ”§ PowerShell 7+ Check
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Warning "This tool requires PowerShell 7 or higher."
        if (Get-Command "pwsh" -ErrorAction SilentlyContinue) {
            Write-Host "Launching in PowerShell 7..."
            Start-Process "pwsh.exe" "-File `"$PSCommandPath`""
            exit
        }
        else {
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
                }
                catch {
                    Write-Error "âŒ Failed to install ${mod}: $($_.Exception.Message)"
                    Read-Host "Press Enter to continue or Ctrl+C to exit"
                }
            }
            else {
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

    # Write your first log for this session
    Write-Log -Message "Session started."
    # endregion

    # region ðŸ§° First-Time Setup Check
    $configPath = ".\config\FirstRunComplete.json"
    if (-not (Test-Path $configPath)) {
        if (!(Test-Path ".\config")) { New-Item ".\config" -ItemType Directory | Out-Null }
        Write-Log -Message "Importing Configuration\Run-FirstTimeSetup.ps1"
        . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Configuration\Run-FirstTimeSetup.ps1"
    }
    Write-Log -Message "First time setup script imported."
    # endregion

    # region ðŸ” Load Global UI Utilities
    Write-Log -Message "Importing Global UI Utilities"
    Write-Log -Message "Importing CLI\Show-ActionHistory.ps1"
    . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\CLI\Show-ActionHistory.ps1"
    Write-Log -Message "Importing CLI\Render-PanelHeader.ps1"
    . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\CLI\Render-PanelHeader.ps1"
    Write-Log -Message "Global UI Utilities imported and loaded"
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

        Write-Log -Message "Last metadata sync was $minutesOld minutes ago ($daysOld days)."

        if ($daysOld -ge $syncAgeDays) {
            Write-Warning "⚠️ Cached metadata is $daysOld days old."
            Write-Log -Message "Metadata cache is stale (>$syncAgeDays days)."

            $doBackup = Read-Host "Backup metadata before syncing? (Y/N)"
            if ($doBackup -eq 'Y') {
                Write-Log -Message "User opted to back up config before sync."
                Write-Log -Message "Importing Configuration\Create-ConfigBackup.ps1"
                . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Configuration\Create-ConfigBackup.ps1"
            }

            $doSync = Read-Host "Sync cloud metadata now? (Y/N)"
            if ($doSync -eq 'Y') {
                Write-Log -Message "User opted to sync metadata (manual confirmation)."
                Write-Log -Message "Importing CachedResources\Refresh-CachedResources.ps1"
                . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
            }
            else {
                Write-Log -Message "User skipped metadata sync despite stale cache."
            }
        }
        elseif ($minutesOld -le 15) {
            Write-Host "🕒 Last metadata sync was just $minutesOld minutes ago."
            Write-Log -Message "Recent metadata cache detected (<15 mins)."

            $quickDecision = Read-Host "Skip sync and use recent cache? (Y/N)"
            if ($quickDecision -ne 'Y') {
                Write-Log -Message "User chose to refresh metadata despite recent sync."
                Write-Log -Message "Importing CachedResources\Refresh-CachedResources.ps1"
                . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
            }
            else {
                Write-Log -Message "User skipped metadata sync (recent cache accepted)."
                Write-Host "⏩ Skipping sync and using recent cached data."
            }
        }
    }
    else {
        Write-Warning "❌ No metadata sync file found. Performing initial sync..."
        Write-Log -Message "No existing .lastSync.json found. Initiating first-time sync."
        Write-Log -Message "Importing CachedResources\Refresh-CachedResources.ps1"
        . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
    }
    # endregion


    # region ðŸ§¼ Preload Cached Metadata (Always)
    Write-Log -Message "Importing CachedResources\Refresh-CachedResources.ps1"
    . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\SiteManagement\CachedResources\Refresh-CachedResources.ps1"
    # endregion

    Write-Log -Message "Invoke-MainMenu script started successfully. Loading menu."

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
            '1' { . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\CLI\ManageResourcesMenu.ps1" }
            '2' { . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\CLI\OrphanMetadataMenu.ps1" }
            '3' { . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\CLI\ConfigurationMenu.ps1" }
            '4' { . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\CLI\LogsMenu.ps1" }
            '5' { . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\CLI\Configuration\Run-FirstTimeSetup.ps1" }
            '6' {
                Write-Host "`nExiting..." -ForegroundColor Cyan
                . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
                Write-Log -Message "User exited the script."
                exit
            }
            default {
                Write-Host "Invalid option." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
        }
    } while ($true)
    # endregion

}
catch {
    Write-Host "`nâŒ A critical error occurred while running the CLI:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Log -Message "â€¼ï¸ Script-level exception: $($_.Exception.Message)"
    Read-Host "`nPress Enter to exit..."
    exit
}

# region ðŸ§¼ Exit Cleanup
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
Write-Log -Message "Exited session and refreshed cache"
Write-Host "`nSession ended. Cache refreshed. Goodbye!" -ForegroundColor Green
# endregion