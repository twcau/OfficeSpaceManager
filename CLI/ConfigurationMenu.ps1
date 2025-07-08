Render-PanelHeader -Title "Configuration & Setup"

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
        Render-PanelHeader -Title "Import / Export Templates"
        Write-Host "[1.1] Export All Templates"
        Write-Host "[1.2] Validate Templates"
        Write-Host "[1.3] Import Validated Templates"
        $sub = Read-Host "`nSelect an option"
        switch ($sub) {
            '1.1' { . "$PSScriptRoot\TemplateManagement\Export-AllTemplates.ps1" }
            '1.2' { . "$PSScriptRoot\TemplateManagement\Validate-CSVImport.ps1" }
            '1.3' { . "$PSScriptRoot\TemplateManagement\Import-FromCSV.ps1" }
        }
    }
    '2' {
        Render-PanelHeader -Title "Manage Site, Building & Floor Metadata"
	Write-Host "[2.1] Export Site/Building Templates"
	Write-Host "[2.2] Import Site/Building from CSV"
	Write-Host "[2.3] View Current Site/Building Structure"
	Write-Host "[2.4] Return to Previous Menu"
	$sub = Read-Host "`nSelect an option"
	switch ($sub) {
    		'2.1' { . "$PSScriptRoot\SiteManagement\Export-SiteStructureTemplates.ps1" }
    		'2.2' { . "$PSScriptRoot\SiteManagement\Import-SiteStructureFromCSV.ps1" }
    		'2.3' { . "$PSScriptRoot\SiteManagement\List-SiteStructure.ps1" }
    		'2.4' { return }
	}

    }
    '3' {
        Render-PanelHeader -Title "Sync Cloud Resources"
        . "$PSScriptRoot\SiteManagement\CachedResources\Refresh-CachedResources.ps1" -Force
        Write-Host "✔️ Cached metadata refreshed."
    }
    '4' {
        Render-PanelHeader -Title "Environment Setup & Validation"
        Write-Host "[4.1] Enable Microsoft Places Features"
        Write-Host "[4.2] Validate Microsoft Places Configuration"
        Write-Host "[4.3] Validate Exchange Resource Setup"
        Write-Host "[4.4] Update Mailbox Types in Bulk"
        Write-Host "[4.5] Ensure Calendar Processing Settings"
        Write-Host "[4.6] Pin Places App in Teams"
        $sub = Read-Host "`nSelect an option"
        switch ($sub) {
            '4.1' { . "$PSScriptRoot\Configuration\Enable-PlacesFeatures.ps1" }
            '4.2' { . "$PSScriptRoot\Configuration\Validate-PlacesFeatures.ps1" }
            '4.3' { . "$PSScriptRoot\Configuration\Validate-ExchangeSetup.ps1" }
            '4.4' { . "$PSScriptRoot\EnvironmentSetup\Update-MailboxTypes.ps1" }
            '4.5' { . "$PSScriptRoot\EnvironmentSetup\Ensure-CalendarProcessingSettings.ps1" }
            '4.6' { . "$PSScriptRoot\EnvironmentSetup\Pin-PlacesAppInTeams.ps1" }
        }
    }
    '5' {
    Render-PanelHeader -Title "Backup & Restore"
    Write-Host "[5.1] Create Configuration Backup (.zip)"
    Write-Host "[5.2] Restore Configuration from Backup"
    Write-Host "[5.3] Return to Previous Menu"
    $sub = Read-Host "`nSelect an option"
    switch ($sub) {
        '5.1' { . "$PSScriptRoot\Configuration\Create-ConfigBackup.ps1" }
        '5.2' { . "$PSScriptRoot\Configuration\Restore-ConfigBackup.ps1" }
        '5.3' { return }
        default {
            Write-Host "Invalid option." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
    '6' {
    	Render-PanelHeader -Title "Backup & Templates"
Write-Host "     [6.1] Export All Templates (CSV)"
Write-Host "     [6.2] Create Backup Archive (ZIP)"
Write-Host "     [6.3] Restore from Backup Archive"
Write-Host "     [6.4] Return to Previous Menu"

$backupChoice = Read-Host "`nChoose an option"
switch ($backupChoice) {
    '6.1' { . "$PSScriptRoot\TemplateManagement\Export-AllTemplates.ps1" }
    '6.2' { . "$PSScriptRoot\Configuration\Create-ConfigBackup.ps1" }
    '6.3' { . "$PSScriptRoot\Configuration\Restore-ConfigBackup.ps1" }
    '6.4' { return }
}
    }
    }
    '7' {
        . "$PSScriptRoot\Configuration\Run-FirstTimeSetup.ps1"
    }
    '8' { return }
    default {
        Write-Host "Invalid option." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}

