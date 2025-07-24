<#
.SYNOPSIS
   Configuration module for OfficeSpaceManager: handles import/export, backup/restore, validation, and first-time setup.
.DESCRIPTION
   Provides functions for configuration backup/restore, validation of Exchange and Places features, and first-time setup for the OfficeSpaceManager environment. Ensures all configuration and metadata are managed in a modular, maintainable, and auditable way.
.FILECREATED (initial creation date)
   2023-12-01
.FILELASTUPDATED (last update date)
   2025-07-24
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
.DOCUMENTATION Connect-MicrosoftPlaces
   https://learn.microsoft.com/en-us/microsoft-365/places/powershell/connect-microsoftplaces
.DOCUMENTATION Get-PlacesSettings
   https://learn.microsoft.com/en-us/microsoft-365/places/powershell/get-placessettings
.DOCUMENTATION Set-PlacesSettings
   https://learn.microsoft.com/en-us/microsoft-365/places/powershell/set-placessettings
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
    function Test-LoadJson($filePath) {
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
        $confirm = Read-Host "Enable it now? (Y/N, default: Y)"
        if ([string]::IsNullOrWhiteSpace($confirm)) { $confirmTrimmed = 'Y' } else { $confirmTrimmed = $confirm.Trim().Substring(0, 1).ToUpper() }
        Write-Log -Message ("Prompted user to enable Places features. Response: '{0}'" -f $confirmTrimmed) -Level 'INFO'
        if ($confirmTrimmed -eq 'Y') {
            Enable-PlacesFeatures
        }
        else {
            Write-Log -Message "User declined to enable Places features from first-time setup." -Level 'WARN'
            Write-Host "No changes made. You can enable features later using this function." -ForegroundColor Cyan
            Read-Host "Press Enter to continue..."
        }
    }
    # ...existing code for resource sync and template export...
}

function Test-ExchangeSetup {
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

function Enable-PlacesFeatures {
    <#!
    .SYNOPSIS
        Enables all required Microsoft Places features for the tenant.
    .DESCRIPTION
        Prompts user to enable all required Places features, validates input robustly, and enables features if confirmed. Reuses existing Places and Teams sessions where possible. All output and comments use EN-AU spelling and accessible language.
    .FILECREATED
        2023-12-01
    .FILELASTUPDATED
        2025-07-24
    .OUTPUTS
        None. Writes status to log and console.
    .EXAMPLE
        Enable-PlacesFeatures
    #>
    # Step 1: Connect to Microsoft Places PowerShell
    Write-Log -Message "Connecting to Microsoft Places..." -Level 'INFO'
    try {
        Connect-MicrosoftPlaces
    }
    catch {
        Write-Log -Message "Failed to connect to Microsoft Places: $($_.Exception.Message)" -Level 'ERROR'
        Write-Host "\n❌ Failed to connect to Microsoft Places. Please check your permissions and network." -ForegroundColor Red
        Read-Host "Press Enter to continue..."
        return
    }
    # Step 2: Retrieve current Places feature settings from tenant
    Write-Log -Message "Retrieving current Places settings..." -Level 'INFO'
    $settings = Get-PlacesSettings -ReadFromPrimary
    # Step 3: Define all relevant feature flags to check and enable
    $featuresToEnable = @('EnableBuildings', 'SpaceAnalyticsEnabled', 'EnablePlacesWebApp', 'PlacesFinderEnabled', 'EnableHybridGuidance')
    $disabledFeatures = @()
    # Step 4: Identify which features are not enabled
    foreach ($feature in $featuresToEnable) {
        if ($settings.$feature -ne 'Default:true') {
            $disabledFeatures += $feature
        }
    }
    # Step 5: If all features are enabled, exit with success
    if ($disabledFeatures.Count -eq 0) {
        Write-Log -Message "All Microsoft Places features are already enabled." -Level 'INFO'
        Write-Host "\n✅ All Microsoft Places features are already enabled for your tenant." -ForegroundColor Green
        return
    }
    # Step 6: Inform user of disabled features and prompt for enablement
    Write-Log -Message "Disabled Places features detected: $($disabledFeatures -join ', ')" -Level 'WARN'
    Write-Host "\nThe following Microsoft Places features are not enabled for your tenant:" -ForegroundColor Yellow
    foreach ($feature in $disabledFeatures) {
        Write-Host ("- {0}" -f $feature) -ForegroundColor Yellow
    }
    $response = Get-YNInput "Do you want to enable all these features now? (Y/N, default: Y)"
    Write-Log -Message ("Prompted user to enable all Places features. Response: '{0}'" -f $response) -Level 'INFO'
    if ($response -eq 'Y') {
        $params = @{}
        foreach ($feature in $disabledFeatures) {
            $params[$feature] = 'Default:true'
            Write-Log -Message ("Enabling {0}..." -f $feature) -Level 'INFO'
        }
        try {
            Set-PlacesSettings @params
        }
        catch {
            $errorMsg = $_.Exception.Message
            Write-Log -Message ('Failed to enable Places features: {0}' -f $errorMsg) -Level 'ERROR'
            Write-Host ("\n❌ Failed to enable Places features: {0}" -f $errorMsg) -ForegroundColor Red
            Read-Host "Press Enter to continue..."
        }
    }
    else {
        Write-Log -Message "User declined to enable Places features." -Level 'WARN'
        Write-Host "No changes made. You can enable features later using this function." -ForegroundColor Yellow
        Read-Host "Press Enter to continue..."
        return
    }
    # Step 8: Re-check settings after enablement
    Write-Log -Message "Re-checking Places settings after enablement..." -Level 'INFO'
    $settings = Get-PlacesSettings -ReadFromPrimary
    $stillDisabled = @()
    foreach ($feature in $featuresToEnable) {
        if ($settings.${feature} -ne 'Default:true') {
            $stillDisabled += $feature
        }
    }
    # Step 9: If all features are now enabled, exit with success
    if ($stillDisabled.Count -eq 0) {
        Write-Log -Message "All Microsoft Places features successfully enabled." -Level 'INFO'
        Write-Host "\n✅ All Microsoft Places features are now enabled for your tenant." -ForegroundColor Green
        Read-Host "Press Enter to continue..."
        return
    }
    else {
        # Step 10: Inform user of any features still not enabled and offer retry
        Write-Log -Message "Some Places features remain disabled: $($stillDisabled -join ', ')" -Level 'ERROR'
        Write-Host "\n⚠️ The following features could not be enabled:" -ForegroundColor Red
        foreach ($feature in $stillDisabled) {
            Write-Host "- $feature" -ForegroundColor Red
        }
        $retry = Get-YNInput "Do you want to retry enabling these features? (Y/N, default: Y)"
        Write-Log -Message ("Prompted user to retry enabling Places features. Response: '{0}'" -f $retry) -Level 'INFO'
        if ($retry -eq 'Y') {
            $params = @{}
            foreach ($feature in $stillDisabled) {
                $params[$feature] = 'Default:true'
                Write-Log -Message ("Retrying enablement for {0}..." -f $feature) -Level 'INFO'
            }
            try {
                Set-PlacesSettings @params
            }
            catch {
                $errorMsg = $_.Exception.Message
                Write-Host ("`n❌ Retry failed for features: {0}" -f $errorMsg) -ForegroundColor Red
                Write-Log -Message ('Retry failed for features: {0}' -f $errorMsg) -Level 'ERROR'
                Read-Host "Press Enter to continue..."
            }
            Write-Log -Message "Final re-check after retry..." -Level 'INFO'
            $settings = Get-PlacesSettings -ReadFromPrimary
            $finalDisabled = @()
            foreach ($feature in $featuresToEnable) {
                if ($settings.${feature} -ne 'Default:true') {
                    $finalDisabled += $feature
                }
            }
            if ($finalDisabled.Count -eq 0) {
                Write-Log -Message "All Microsoft Places features successfully enabled after retry." -Level 'INFO'
                Write-Host "\n✅ All Microsoft Places features are now enabled for your tenant." -ForegroundColor Green
                Read-Host "Press Enter to continue..."
                return
            }
            else {
                Write-Log -Message "Some Places features remain disabled after retry: $($finalDisabled -join ', ')" -Level 'ERROR'
                Write-Host "\n❌ The following features could not be enabled after retry:" -ForegroundColor Red
                foreach ($feature in $finalDisabled) {
                    Write-Host "- $feature" -ForegroundColor Red
                }
                Write-Host "Please check your permissions, licensing, or contact Microsoft support for further assistance." -ForegroundColor Yellow
                Read-Host "Press Enter to continue..."
                return
            }
        }
        else {
            Write-Log -Message "User declined to retry enabling Places features." -Level 'WARN'
            Write-Host "No further changes made. You can retry later using this function." -ForegroundColor Cyan
            Read-Host "Press Enter to continue..."
            return
        }
    }
}

function Test-PlacesFeatures {
    <#!
    .SYNOPSIS
        Validates Microsoft Places configuration and Teams app pinning.
    .DESCRIPTION
        Checks Places features and Teams app pinning, reuses existing sessions, logs and reports all errors, prompts user for acknowledgement. All output and comments use EN-AU spelling and accessible language.
    .FILECREATED
        2023-12-01
    .FILELASTUPDATED
        2025-07-24
    .OUTPUTS
        None. Writes status to log and console.
    .EXAMPLE
        Test-PlacesFeatures
    #>
    # Step 1: Connect to Microsoft Places PowerShell
    Write-Log -Message "Connecting to Microsoft Places for validation..." -Level 'INFO'
    # Reuse existing Places session if available
    if (-not (Get-Module -Name MicrosoftPlaces)) {
        try {
            Import-Module MicrosoftPlaces -ErrorAction Stop
        }
        catch {
            Write-Log -Message "Microsoft Places PowerShell module is not available. Please install it." -Level 'ERROR'
            Write-Host "\n❌ Microsoft Places PowerShell module is not available. Please install it." -ForegroundColor Red
            Read-Host "Press Enter to continue..."
            return
        }
    }
    # Step 2: Retrieve current Places feature settings from tenant
    Write-Log -Message "Retrieving current Places settings for validation..." -Level 'INFO'
    $settings = Get-PlacesSettings -ReadFromPrimary
    $featureMap = @{
        EnableBuildings       = 'EnableBuildings'
        EnableHybridGuidance  = 'EnableHybridGuidance'
        EnablePlacesWebApp    = 'EnablePlacesWebApp'
        PlacesFinderEnabled   = 'PlacesFinderEnabled'
        SpaceAnalyticsEnabled = 'SpaceAnalyticsEnabled'
    }
    $disabledFeatures = @()
    # Step 3: Identify which features are not enabled
    foreach ($feature in $featureMap.Keys) {
        if ($settings.${feature} -ne 'Default:true') {
            $disabledFeatures += $feature
        }
    }
    # Step 4: Output validation results for Places features
    if ($disabledFeatures.Count -eq 0) {
        Write-Log -Message "All Microsoft Places features are enabled." -Level 'INFO'
        Write-Host "\n✅ All Microsoft Places features are enabled for your tenant." -ForegroundColor Green
    }
    else {
        Write-Log -Message "Some Places features are not enabled: $($disabledFeatures -join ', ')" -Level 'WARN'
        Write-Host "\n⚠️ The following Microsoft Places features are NOT enabled:" -ForegroundColor Yellow
        foreach ($feature in $disabledFeatures) {
            Write-Host "- $feature" -ForegroundColor Yellow
        }
        Write-Host "You can enable these features using Enable-PlacesFeatures." -ForegroundColor Cyan
    }
    # Step 5: Validate Teams app pinning for Places
    Write-Log -Message "Checking Teams app pinning for Places..." -Level 'INFO'
    if (-not (Get-Command Connect-MicrosoftTeams -ErrorAction SilentlyContinue)) {
        Write-Log -Message "Connect-MicrosoftTeams cmdlet not found." -Level 'ERROR'
        Write-Host "\n❌ Microsoft Teams PowerShell module is not available. Please install it." -ForegroundColor Red
        Read-Host "Press Enter to continue..."
        return
    }
    # Reuse Teams session if available
    $teamsSession = $null
    try {
        $teamsSession = Get-Module -Name MicrosoftTeams
        if ($teamsSession) {
            Write-Log -Message "Teams session reused: $($teamsSession.Session.UserPrincipalName)" -Level 'INFO'
        }
        else {
            Write-Log -Message "Connecting to Microsoft Teams..." -Level 'INFO'
            Connect-MicrosoftTeams -ErrorAction Stop
            Write-Log -Message "Teams session established." -Level 'INFO'
        }
    }
    catch {
        Write-Log -Message "Failed to connect to Microsoft Teams: $($_.Exception.Message)" -Level 'ERROR'
        Write-Host "\n❌ Failed to connect to Microsoft Teams. $($_.Exception.Message)" -ForegroundColor Red
        Read-Host "Press Enter to continue..."
        return
    }
    $apps = Get-CsTeamsAppSetupPolicy -Identity Global
    if ($apps.PinnedApps -contains "com.microsoft.places") {
        Write-Log -Message "Places App is pinned in Teams." -Level 'INFO'
        Write-Host "\n✅ Places App is pinned in Teams." -ForegroundColor Green
    }
    else {
        Write-Log -Message "Places App is not pinned in Teams." -Level 'WARN'
        Write-Host "\n⚠️ Places App is NOT pinned in Teams." -ForegroundColor Yellow
        Write-Host "You can pin the Places App in Teams using Teams admin centre or PowerShell." -ForegroundColor Cyan
    }
    Write-Log "Places features validated"
}

function Get-YNInput {
    param(
        [string]$Prompt
    )
    while ($true) {
        $inputRaw = Read-Host $Prompt
        if ([string]::IsNullOrWhiteSpace($inputRaw)) {
            $inputChar = 'Y'
        }
        else {
            $inputChar = $inputRaw.Trim().Substring(0, 1).ToUpper()
        }
        if ($inputChar -eq 'Y' -or $inputChar -eq 'N') {
            Write-Log -Message ("User input for prompt '{0}': '{1}'" -f $Prompt, $inputChar) -Level 'INFO'
            return $inputChar
        }
        Write-Host "Invalid input. Please enter 'Y' or 'N'." -ForegroundColor Red
    }
}

Export-ModuleMember -Function New-ConfigBackup, Restore-ConfigBackup, Invoke-FirstTimeSetup, Test-ExchangeSetup, Test-PlacesFeatures, Enable-PlacesFeatures
