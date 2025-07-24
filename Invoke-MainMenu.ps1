<#
.SYNOPSIS
    CLI Terminal Navigation Shell for OfficeSpaceManager.
.DESCRIPTION
    Root launcher that governs CLI flow, validates setup, syncs resources, and routes to all submenus. Ensures all required modules are present, validates PowerShell version, and provides a robust entry point for all CLI operations. All output and prompts use inclusive, accessible language and EN-AU spelling.
.PARAMETER LogVerbose
    If specified, enables full session transcript and input logging to Logs\TerminalVerbose.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
.OUTPUTS
    None. Launches CLI and routes to submenus.
.EXAMPLE
    .\Invoke-MainMenu.ps1 -LogVerbose
    # Launches the main CLI menu and logs all input/output to a transcript file.
#>

param(
    [switch]$LogVerbose
)

# Set project root for robust module referencing
$env:OfficeSpaceManagerRoot = $PSScriptRoot

# Robustly resolve project root for all module imports
. (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Utilities/Resolve-OfficeSpaceManagerRoot.ps1')

# Import Logging module for Write-Log function
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\Logging\Logging.psm1') -Force
# Import CLI module for Get-PanelHeader and Get-ActionHistory
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\CLI\CLI.psm1') -Force
# Import Configuration module for New-ConfigBackup and related functions
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\Configuration\Configuration.psm1') -Force
# Import Utilities module for connection and helper functions
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Utilities/Utilities.psm1') -Force
# Import Connections module for robust service connections
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Connections/Connections.psm1') -Force

# region Verbose Transcript & Input Logging
if ($LogVerbose) {
    $logDir = Join-Path $env:OfficeSpaceManagerRoot 'Logs/TerminalVerbose'
    if (-not (Test-Path -Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir | Out-Null
    }
    $timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm"
    $logFile = Join-Path $logDir "verboselog-invoke-mainmenu-ps1-$timestamp.txt"
    # Override Read-Host for input logging (if not already overridden)
    if (-not (Get-Command global:Read-Host -ErrorAction SilentlyContinue)) {
        function global:Read-Host {
            param([string]$prompt)
            $userInput = Microsoft.PowerShell.Utility\Read-Host $prompt
            Write-Log -Message ("[{0}] User input for '{1}': {2}" -f (Get-Date -Format 'HH:mm:ss'), $prompt, $userInput) -Level 'INFO'
            $global:LastUserInput = $userInput
            return $userInput
        }
    }
    Start-Transcript -Path $logFile -Append
}
# endregion

try {
    # region 6e0 PowerShell 7+ Check
    # Ensure script is running in PowerShell 7 or higher
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Log -Message "This tool requires PowerShell 7 or higher." -Level 'WARN'
        if (Get-Command "pwsh" -ErrorAction SilentlyContinue) {
            Write-Log -Message "Launching in PowerShell 7..." -Level 'INFO'
            Start-Process "pwsh.exe" "-File `"$PSCommandPath`""
            exit
        }
        else {
            Write-Log -Message "Please install PowerShell 7: https://learn.microsoft.com/powershell/scripting/install/installing-powershell" -Level 'INFO'
            exit
        }
    }
    # endregion

    # region 6e0 Required Modules Check
    # Check for required modules and prompt to install if missing
    $requiredModules = @(
        'ExchangeOnlineManagement',
        'MicrosoftTeams',
        #'Microsoft.Graph', Removing as takes ages to import
        'MicrosoftPlaces'
    )
    foreach ($mod in $requiredModules) {
        if (-not (Get-Module -ListAvailable -Name $mod)) {
            Write-Log -Message "Required module '$mod' is missing." -Level 'WARN'
            $choice = Read-Host ("Do you want to install {0} now? (Y/N, default: Y)" -f $mod)
            if ([string]::IsNullOrWhiteSpace($choice)) { $choice = 'Y' }
            $choice = $choice.Trim().ToUpper()
            if ($choice -eq 'Y') {
                try {
                    Install-Module -Name $mod -Scope CurrentUser -Force -ErrorAction Stop
                    Write-Log -Message ("Installed {0} successfully." -f $mod) -Level 'INFO'
                }
                catch {
                    Write-Log -Message ("Failed to install {0}: {1}" -f $mod, $_.Exception.Message) -Level 'ERROR'
                    Read-Host "Press Enter to continue or Ctrl+C to exit"
                }
            }
            else {
                Write-Log -Message ("Cannot continue without {0}. Please install it manually." -f $mod) -Level 'ERROR'
                Read-Host "Press Enter to exit..."
                exit
            }
        }
        else {
            Write-Log -Message ("Required module '{0}' is already installed and available." -f $mod) -Level 'INFO'
            try {
                Import-Module -Name $mod -Force -ErrorAction Stop
                Write-Log -Message ("Module '{0}' imported successfully." -f $mod) -Level 'INFO'
                Write-Host ("✅ Module '{0}' is installed and imported." -f $mod) -ForegroundColor Green
            }
            catch {
                Write-Log -Message ("Module '{0}' is installed but failed to import: {1}" -f $mod, $_.Exception.Message) -Level 'ERROR'
                Write-Host ("❌ Module '{0}' is installed but failed to import. See logs for details." -f $mod) -ForegroundColor Red
                Read-Host "Press Enter to continue or Ctrl+C to exit"
            }
        }
    }
    # endregion

    # region Exchange Connection
    try {
        Connect-ExchangeAdmin
        $exoConn = Get-ConnectionInformation | Where-Object { $_.State -eq 'Connected' -and $_.Name -like 'ExchangeOnline*' }
        if (-not $exoConn) {
            Write-Log -Message "Unable to connect to Exchange Online. Exiting." -Level 'ERROR'
            Write-Host "`n❌ Unable to connect to Exchange Online. Please check your credentials and network." -ForegroundColor Red
            Read-Host "Press Enter to exit..."
            exit
        }
        else {
            Write-Log -Message ("Exchange Online connection established for: {0}" -f $exoConn.UserPrincipalName) -Level 'INFO'
        }
    }
    catch [System.OperationCanceledException] {
        Write-Log -Message "Exchange Online authentication was cancelled by the user." -Level 'ERROR'
        Write-Host "`n❌ Exchange Online authentication was cancelled. Please try again." -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        exit
    }
    catch {
        Write-Log -Message ("Exchange Online connection failed: {0}" -f $_.Exception.Message) -Level 'ERROR'
        Write-Host "`n❌ Unable to connect to Exchange Online. Please check your credentials and network." -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        exit
    }
    # endregion

    # region Graph Connection
    <#
    // NOTE: Ignoring connections to Microsoft Graph at this time, due to the length of time needed for this, and the delays it causes running the script.
    $graphAccount = Connect-Graph
    if (-not $graphAccount) {
        Write-Log -Message "Unable to connect to Microsoft Graph. Exiting." -Level 'ERROR'
        Write-Host "`n❌ Unable to connect to Microsoft Graph. Please check your credentials and network." -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        exit
    }
    #>
    # endregion

    # region Teams Connection
    $teamsConnected = Connect-TeamsService
    if (-not $teamsConnected) {
        Write-Log -Message "Unable to connect to Microsoft Teams. Exiting." -Level 'ERROR'
        Write-Host "`n❌ Unable to connect to Microsoft Teams. Please check your credentials and network." -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        exit
    }
    # endregion

    # region Places Connection
    $placesConnected = Connect-PlacesService
    if (-not $placesConnected) {
        Write-Log -Message "Unable to connect to Microsoft Places. Exiting." -Level 'ERROR'
        Write-Host "`n❌ Unable to connect to Microsoft Places. Please check your credentials and network." -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        exit
    }
    # endregion

    # region 310 Init Logging
    # Initialize logging for the session
    $Global:ActionLog = @()
    $LogDate = Get-Date -Format 'yyyy-MM-dd'
    $Global:LogFile = ".\Logs\$LogDate.log"
    if (!(Test-Path ".\Logs")) { New-Item ".\Logs" -ItemType Directory | Out-Null }

    # Write your first log for this session
    Write-Log -Message "Session started."
    # endregion

    # region 👾 First-Time Setup Check
    # Check if first-time setup has been completed
    $configPath = ".\config\FirstRunComplete.json"
    $firstTimeSetupScript = Join-Path $env:OfficeSpaceManagerRoot 'Configuration/Run-FirstTimeSetup.ps1'
    if (-not (Test-Path $configPath)) {
        if (!(Test-Path ".\config")) { New-Item ".\config" -ItemType Directory | Out-Null }
        Write-Log -Message "Importing Configuration/Run-FirstTimeSetup.ps1"
        if (Test-Path $firstTimeSetupScript) {
            . $firstTimeSetupScript
        }
        else {
            Write-Log -Message "First-time setup script not found at $firstTimeSetupScript" -Level 'ERROR'
            Write-Host "\n❌ First-time setup script not found at $firstTimeSetupScript" -ForegroundColor Red
            Read-Host "Press Enter to exit..."
            exit
        }
    }
    Write-Log -Message "First time setup script imported."
    # endregion

    # region 🛠 Load Global UI Utilities
    # Import global UI utilities for the CLI
    Write-Log -Message "Importing Global UI Utilities"
    Write-Log -Message "Global UI Utilities imported and loaded"
    # endregion

    # region 🧼 Check Cached Metadata Freshness
    # Check the freshness of cached metadata and sync if stale
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
            Write-Log -Message "Cached metadata is $daysOld days old." -Level 'WARN'
            Write-Log -Message "Metadata cache is stale (>$syncAgeDays days)."

            $doBackup = Read-Host "Backup metadata before syncing? (Y/N, default: Y)"
            if ([string]::IsNullOrWhiteSpace($doBackup)) { $doBackup = 'Y' }
            $doBackup = $doBackup.Trim().ToUpper()
            if ($doBackup -eq 'Y') {
                Write-Log -Message "User opted to back up config before sync."
                New-ConfigBackup
            }

            $doSync = Read-Host "Sync cloud metadata now? (Y/N, default: N)"
            if ([string]::IsNullOrWhiteSpace($doSync)) { $doSync = 'N' }
            $doSync = $doSync.Trim().ToUpper()
            if ($doSync -eq 'Y') {
                Write-Log -Message "User opted to sync metadata (manual confirmation)."
                Write-Log -Message "Importing CachedResources\Refresh-CachedResources.ps1"
                . (Join-Path $env:OfficeSpaceManagerRoot 'SiteManagement/CachedResources/Refresh-CachedResources.ps1') -Force
            }
            else {
                Write-Log -Message "User skipped metadata sync despite stale cache."
            }
        }
        elseif ($minutesOld -le 15) {
            Write-Log -Message "Last metadata sync was just $minutesOld minutes ago." -Level 'INFO'
            Write-Log -Message "Recent metadata cache detected (<15 mins)."

            try {
                $quickDecision = Read-Host "Skip sync and use recent cache? (Y/N, default: Y)"
                if ([string]::IsNullOrWhiteSpace($quickDecision)) { $quickDecision = 'Y' }
                $quickDecision = $quickDecision.Trim().ToUpper()
                if ($quickDecision -ne 'Y') {
                    Write-Log -Message "User chose to refresh metadata despite recent sync."
                    Write-Log -Message "Importing CachedResources\Refresh-CachedResources.ps1"
                    . (Join-Path $env:OfficeSpaceManagerRoot 'SiteManagement/CachedResources/Refresh-CachedResources.ps1') -Force
                }
                else {
                    Write-Log -Message "User skipped metadata sync (recent cache accepted)."
                    Write-Log -Message "Skipping sync and using recent cached data." -Level 'INFO'
                }
            }
            catch {
                Write-Log -Message ("Error during recent cache decision: {0}" -f $_.Exception.Message) -Level 'ERROR'
                Write-Host "❌ Error during recent cache decision. See logs for details." -ForegroundColor Red
            }
        }
    }
    else {
        Write-Log -Message "No metadata sync file found. Performing initial sync..." -Level 'WARN'
        Write-Log -Message "No existing .lastSync.json found. Initiating first-time sync."
        Write-Log -Message "Importing CachedResources\Refresh-CachedResources.ps1"
        . (Join-Path $env:OfficeSpaceManagerRoot 'SiteManagement/CachedResources/Refresh-CachedResources.ps1') -Force
    }
    # endregion

    # region 🧩 Preload Cached Metadata (Always)
    # Preload cached metadata on every script start
    Write-Log -Message "Importing CachedResources\Refresh-CachedResources.ps1"
    . (Join-Path $env:OfficeSpaceManagerRoot 'SiteManagement/CachedResources/Refresh-CachedResources.ps1')
    # endregion

    # region Service Connections
    Connect-AllServices
    # endregion

    Write-Log -Message "Invoke-MainMenu script started successfully. Loading menu."

    # region 🗂 Main Menu Navigation
    do {
        Clear-Host
        Get-PanelHeader -Title "OfficeSpaceManager - Main Menu"

        Write-Host "[1] Manage Resources"
        Write-Host "[2] Orphan & Metadata Management"
        Write-Host "[3] Configuration & Setup"
        Write-Host "[4] Metadata & Logs"
        Write-Host "[5] Run First-Time Setup Wizard"
        Write-Host "[6] Exit"

        Get-ActionHistory
        $selection = Read-Host "`nSelect an option"
        if ($LogVerbose) {
            $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            Write-Log -Message "[$timestamp] User selected menu option: $selection" -Level 'INFO'
        }

        switch ($selection) {
            '1' { . (Join-Path $env:OfficeSpaceManagerRoot 'CLI/ManageResourcesMenu.ps1') }
            '2' { . (Join-Path $env:OfficeSpaceManagerRoot 'CLI/OrphanMetadatamenu.ps1') }
            '3' { . (Join-Path $env:OfficeSpaceManagerRoot 'CLI/ConfigurationMenu.ps1') }
            '4' { . (Join-Path $env:OfficeSpaceManagerRoot 'CLI/LogsMenu.ps1') }
            '5' {
                if (Test-Path $firstTimeSetupScript) {
                    . $firstTimeSetupScript
                }
                else {
                    Write-Log -Message "First-time setup script not found at $firstTimeSetupScript" -Level 'ERROR'
                    Write-Host "\n❌ First-time setup script not found at $firstTimeSetupScript" -ForegroundColor Red
                    Read-Host "Press Enter to return to menu..."
                }
            }
            '6' {
                Write-Host "`nExiting..." -ForegroundColor Cyan
                . (Join-Path $env:OfficeSpaceManagerRoot 'SiteManagement/CachedResources/Refresh-CachedResources.ps1') -Force
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
    Write-Host "\n❌ A critical error occurred while running the CLI:" -ForegroundColor Red
    Write-Log -Message "Exception.Message" -Level 'WARN'
    Write-Log -Message "⚠️ Script-level exception: $($_.Exception.Message)"
    Read-Host "\nPress Enter to exit..."
    exit
}
finally {
    if ($LogVerbose) {
        Stop-Transcript | Out-Null
        Write-Host ("`nSession transcript saved to: $logFile") -ForegroundColor Green
        Read-Host "Press Enter to close and exit..."
    }
}

# region 🧩 Exit Cleanup
. (Join-Path $env:OfficeSpaceManagerRoot 'SiteManagement/CachedResources/Refresh-CachedResources.ps1') -Force
Write-Log -Message "Exited session and refreshed cache"
Write-Host "\nSession ended. Cache refreshed. Goodbye!" -ForegroundColor Green
# endregion
