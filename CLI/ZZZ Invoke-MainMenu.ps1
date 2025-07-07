<# 
    Script: Invoke-MainMenu.ps1
    Purpose: CLI Terminal Navigation Shell for OfficeSpaceManager
    Author: Your Team
    LastUpdated: 2025-07-07
#>

# region 🔁 PowerShell 7+ Check
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

# region 🔧 Module Validation
$requiredModules = @(
    'ExchangeOnlineManagement',
    'Microsoft.Graph.Places',
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
                Write-Error "❌ Failed to install $mod: $_"
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

# region 🌐 Init Logging and State
$Global:ActionLog = @()
$LogDate = Get-Date -Format 'yyyy-MM-dd'
$Global:LogFile = ".\Logs\$LogDate.log"
if (!(Test-Path ".\Logs")) { New-Item ".\Logs" -ItemType Directory | Out-Null }

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $entry = "[$timestamp] $Message"
    Add-Content -Path $Global:LogFile -Value $entry
    $Global:ActionLog += $entry
}
# endregion

# region 🔄 First-Time Setup
$configPath = ".\config\FirstRunComplete.json"
if (-not (Test-Path $configPath)) {
    if (!(Test-Path ".\config")) { New-Item ".\config" -ItemType Directory | Out-Null }
    . "$PSScriptRoot\..\Configuration\Run-FirstTimeSetup.ps1"
}
# endregion

# region 🔁 Load Global UI Utilities
. "$PSScriptRoot\Show-ActionHistory.ps1"
. "$PSScriptRoot\Render-PanelHeader.ps1"
# endregion

# region 🧼 Refresh Local Cache
. "$PSScriptRoot\..\SiteManagement\CachedResources\Refresh-CachedResources.ps1"
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
	'5' { . "$PSScriptRoot\..\Configuration\Run-FirstTimeSetup.ps1" }
        '6' {
        Write-Host "`nExiting..." -ForegroundColor Cyan
        . "$PSScriptRoot\..\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
        Write-Log "User exited the script."
        exit
	}

    }

} while ($true)
# endregion

# region 🧼 Exit Cleanup
. "$PSScriptRoot\..\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
Write-Log "Exited session and refreshed cache"
Write-Host "`nSession ended. Cache refreshed. Goodbye!" -ForegroundColor Green
# endregion
