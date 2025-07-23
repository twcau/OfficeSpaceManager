<#
.SYNOPSIS
   Configuration module for OfficeSpaceManager: handles import/export, backup/restore, validation, and first-time setup.
.DESCRIPTION
   Provides functions for configuration backup/restore, validation of Exchange and Places features, and first-time setup for the OfficeSpaceManager environment. Ensures all configuration and metadata are managed in a modular, maintainable, and auditable way.
.FILECREATED (initial creation date)
   2023-12-01
.FILELASTUPDATED (last update date)
   2025-07-23
.DOCUMENTATION Compress-Archive
   https://learn.microsoft.com/en-au/powershell/module/microsoft.powershell.archive/compress-archive?view=powershell-7.3
.DOCUMENTATION Expand-Archive
   https://learn.microsoft.com/en-au/powershell/module/microsoft.powershell.archive/expand-archive?view=powershell-7.3
.DOCUMENTATION Get-OrganizationConfig
   https://learn.microsoft.com/en-au/powershell/module/exchange/get-organizationconfig?view=exchange-ps
.DOCUMENTATION Get-Mailbox
   https://learn.microsoft.com/en-au/powershell/module/exchange/get-mailbox?view=exchange-ps
.DOCUMENTATION Get-Place
   https://learn.microsoft.com/en-au/powershell/module/exchange/get-place?view=exchange-ps
.DOCUMENTATION Get-CsTeamsAppSetupPolicy
   https://learn.microsoft.com/en-au/powershell/module/teams/get-csteamsappsetuppolicy?view=teams-ps
.DOCUMENTATION Set-OrganizationConfig
   https://learn.microsoft.com/en-au/powershell/module/exchange/set-organizationconfig?view=exchange-ps
#>
# Configuration.psm1
# Configuration: import/export, backup/restore, validation

function New-ConfigBackup {
    <#
    .SYNOPSIS
        Creates a ZIP backup of key configuration, metadata, and log files.
    .DESCRIPTION
        Collects all relevant configuration, metadata, and log files, and compresses them into a timestamped ZIP archive in the Backups folder. Skips missing paths and logs warnings. Aborts if nothing to back up.
    .OUTPUTS
        [string] Path to the created ZIP file, or null if backup was skipped.
    #>
    # Display a header in the CLI for user context
    Display-PanelHeader -Title "Creating Configuration Backup"
    $timestamp = Get-Date -Format 'yyyy-MM-dd-HHmm'
    $zipPath = ".\Backups\ConfigBackup-$timestamp.zip"
    # Ensure the Backups directory exists
    if (!(Test-Path ".\Backups")) {
        New-Item -Path ".\Backups" -ItemType Directory | Out-Null
    }
    $itemsToBackup = @()
    $paths = @(".\Metadata", ".\Logs", ".\config")
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $itemsToBackup += $p
        }
        else {
            Write-Log -Message "Skipping missing path: $p" -Level 'WARN'
        }
    }
    # Add any JSON files in Backups to the backup set
    $jsonFiles = Get-ChildItem ".\Backups" -Filter *.json -ErrorAction SilentlyContinue
    if ($jsonFiles) {
        $itemsToBackup += $jsonFiles.FullName
    }
    if ($itemsToBackup.Count -eq 0) {
        Write-Log -Message "No valid content found to back up. Backup aborted." -Level 'WARN'
        Write-Log "Backup skipped — no items found."
        return
    }
    # Compress the collected items into a ZIP archive
    Compress-Archive -Path $itemsToBackup -DestinationPath $zipPath -Force
    Write-Host "`n📦 Backup created: $zipPath" -ForegroundColor Green
    Write-Log "Created config backup ZIP: $zipPath"
}

function Restore-ConfigBackup {
    <#
    .SYNOPSIS
        Restores configuration and metadata from a selected backup ZIP.
    .DESCRIPTION
        Allows the user to select a backup ZIP archive and restores its contents to a temporary folder. Validates the presence of required files before proceeding. Logs all actions and aborts if required files are missing.
    .OUTPUTS
        [void]
    #>
    Display-PanelHeader -Title "Restore Metadata from Backup Archive"
    $backups = Get-ChildItem ".\Backups" -Filter *.zip -ErrorAction SilentlyContinue
    if (-not $backups) {
        Write-Log -Message "No backup archives found in .\Backups" -Level 'WARN'
        return
    }
    try {
        $file = $backups | Out-GridView -Title "Select Backup to Restore" -PassThru
    }
    catch {
        $file = $backups | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        Write-Log -Message "Out-GridView unavailable. Using most recent backup: $($file.Name)" -Level 'WARN'
    }
    if (-not $file) { return }
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $restoreFolder = ".\Temp\Restore_$timestamp"
    if (!(Test-Path $restoreFolder)) {
        New-Item -Path $restoreFolder -ItemType Directory | Out-Null
    }
    # Expand the selected backup archive
    Expand-Archive -Path $file.FullName -DestinationPath $restoreFolder -Force
    Write-Log "Expanded backup to $restoreFolder"
    $requiredFiles = @(
        "DeskDefinitions.json",
        "DeskPools.json",
        "SiteDefinitions.json",
        "BuildingDefinitions.json"
    )
    $missing = @()
    foreach ($f in $requiredFiles) {
        $path = Join-Path $restoreFolder $f
        if (-not (Test-Path $path)) {
            $missing += $f
        }
    }
    if ($missing.Count -gt 0) {
        Write-Log -Message "n❒ The following required files were missing from the archive:" -Level 'WARN'
        $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
        Write-Log "Restore aborted. Missing files: $($missing -join ', ')"
        return
    }
    # Helper function to load JSON safely
    function Try-LoadJson($filePath) {
        try {
            return Get-Content $filePath -Raw | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            Write-Log -Message "Failed to load JSON: $filePath" -Level 'ERROR'
            return $null
        }
    }
    # ...existing code for restore logic...
}

function Invoke-FirstTimeSetup {
    <#
    .SYNOPSIS
        Runs the first-time setup wizard for the environment.
    .DESCRIPTION
        Collects tenant domain information, checks for Microsoft Places enablement, and offers to enable it if not already enabled. Logs all actions and provides user prompts as needed.
    .OUTPUTS
        [void]
    #>
    Display-PanelHeader -Title "First-Time Setup Wizard"
    Write-Log -Message "Collecting tenant domain info..." -Level 'INFO'
    $org = Get-OrganizationConfig
    $defaultDomain = $org.DefaultDomain
    Write-Log -Message "Detected default domain: $defaultDomain" -Level 'INFO'
    $placesEnabled = $org.PlacesEnabled
    if (-not $placesEnabled) {
        Write-Host "`nMicrosoft Places is not enabled."
        $confirm = Read-Host "Enable it now? (Y/N)"
        if ($confirm -eq 'Y') {
            Enable-PlacesFeatures
        }
    }
    # ...existing code for resource sync and template export...
}

function Validate-ExchangeSetup {
    <#
    .SYNOPSIS
        Validates Exchange resource setup and metadata.
    .DESCRIPTION
        Checks all room mailboxes for Place metadata and GAL visibility. Logs warnings for missing metadata or hidden mailboxes. Summarises validation results.
    .OUTPUTS
        [void]
    #>
    Display-PanelHeader -Title "Validating Exchange Setup"
    $resources = Get-Mailbox -RecipientTypeDetails RoomMailbox -ResultSize Unlimited
    foreach ($r in $resources) {
        $place = Get-Place -Identity $r.Alias -ErrorAction SilentlyContinue
        if (-not $place) {
            Write-Log -Message "r.Alias): No Place metadata" -Level 'WARN'
        }
        if ($r.HiddenFromAddressListsEnabled) {
            Write-Log -Message "r.Alias): Hidden from GAL" -Level 'WARN'
        }
    }
    Write-Log -Message "Exchange resource validation completed" -Level 'INFO'
    Write-Log "Exchange validation completed"
}

function Validate-PlacesFeatures {
    <#
    .SYNOPSIS
        Validates Microsoft Places features and Teams app pinning.
    .DESCRIPTION
        Checks if Microsoft Places is enabled and if the Places app is pinned in Teams. Logs results and warnings as appropriate.
    .OUTPUTS
        [void]
    #>
    Display-PanelHeader -Title "Validating Microsoft Places Setup"
    $org = Get-OrganizationConfig
    if ($org.PlacesEnabled) {
        Write-Log -Message "Places feature is ENABLED." -Level 'INFO'
    }
    else {
        Write-Log -Message "Places feature is DISABLED." -Level 'WARN'
    }
    $apps = Get-CsTeamsAppSetupPolicy -Identity Global
    if ($apps.PinnedApps -contains "com.microsoft.places") {
        Write-Log -Message "Places App is pinned in Teams." -Level 'INFO'
    }
    else {
        Write-Log -Message "Places App is not pinned." -Level 'WARN'
    }
    Write-Log "Places features validated"
}

function Enable-PlacesFeatures {
    <#
    .SYNOPSIS
        Enables Microsoft Places features in the tenant.
    .DESCRIPTION
        Sets the PlacesEnabled property to true in the organisation configuration. Logs all actions.
    .OUTPUTS
        [void]
    #>
    Write-Log -Message "Enabling Microsoft Places features..." -Level 'INFO'
    Set-OrganizationConfig -PlacesEnabled $true
    Write-Log -Message "Microsoft Places enabled." -Level 'INFO'
    Write-Log "Enabled Microsoft Places"
}

Export-ModuleMember -Function New-ConfigBackup, Restore-ConfigBackup, Invoke-FirstTimeSetup, Validate-ExchangeSetup, Validate-PlacesFeatures, Enable-PlacesFeatures
