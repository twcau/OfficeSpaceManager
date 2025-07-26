## Invoke-MainMenu.ps1

// TESTING: Invoke-MainMenu.ps1
// [X] TESTING: Main CLI entry point launches and displays menu
// [X] TESTING: -LogVerbose flag enables transcript and input logging
// [ ] TESTING: First-time setup enforced on first run
// [ ] TESTING: Exchange Online connection required and validated

## Backups

// TESTING: Backups
// [ ] TESTING: Save-MetadataSnapshot.ps1 creates valid metadata backup
// [ ] TESTING: Restore-MetadataSnapshot.ps1 restores backup correctly
// [ ] TESTING: Backups/ConfigBackups/ and Backups/Snapshots/ are populated and managed

## CLI

// TESTING: CLI
// [ ] TESTING: ConfigurationMenu.ps1 launches and updates config
// [ ] TESTING: LogsMenu.ps1 displays and manages logs
// [ ] TESTING: ManageResourcesMenu.ps1 manages resources as expected
// [ ] TESTING: OrphanMetadatamenu.ps1 identifies and manages orphaned metadata
// [ ] TESTING: Wizards/ interactive flows function correctly

## config

// TESTING: config
// [ ] TESTING: FirstRunComplete.json is set after first run
// [ ] TESTING: TenantConfig.json is loaded and validated

## Configuration

// TESTING: Configuration
// [ ] TESTING: Create-ConfigBackup.ps1 creates config backup ZIP
// [ ] TESTING: Enable-PlacesFeatures.ps1 enables Places features
// [ ] TESTING: Restore-ConfigBackup.ps1 restores config from backup
// [ ] TESTING: Run-FirstTimeSetup.ps1 completes setup
// [ ] TESTING: Validate-ExchangeSetup.ps1 validates Exchange setup
// [ ] TESTING: Validate-PlacesFeatures.ps1 validates Places/Teams setup

## EnvironmentSetup

// TESTING: EnvironmentSetup
// [ ] TESTING: Ensure-CalendarProcessingSettings.ps1 applies correct settings
// [ ] TESTING: Pin-PlacesAppInTeams.ps1 pins app in Teams
// [ ] TESTING: Update-MailboxTypes.ps1 updates mailbox types

## Logs

// TESTING: Logs
// [ ] TESTING: Log files are created and rotated
// [ ] TESTING: Clear-LogHistory.ps1 clears logs
// [ ] TESTING: Compress-Logs.ps1 compresses logs
// [ ] TESTING: Export-ActionHistory.ps1 exports action history
// [ ] TESTING: View-LogHistory.ps1 displays logs

## Metadata

// TESTING: Metadata
// [ ] TESTING: .lastSync.json is updated after sync
// [ ] TESTING: CachedResources.json is updated and valid

## Modules

// TESTING: Modules
// [ ] TESTING: CLI/ menu rendering and user interaction logic
// [ ] TESTING: Configuration/ import/export, backup/restore, validation
// [ ] TESTING: Logging/ centralised logging and error handling
// [ ] TESTING: Reporting/ summary generation
// [ ] TESTING: SiteManagement/ site/building/floor/desk management
// [ ] TESTING: UserManagement/ user and permissions logic
// [ ] TESTING: Utilities/ helper and utility functions

## OrphanFixer

// TESTING: OrphanFixer
// [ ] TESTING: Detect-NonStandardResources.ps1 detects non-standard resources
// [ ] TESTING: Find-OrphanedResources.ps1 finds orphaned resources
// [ ] TESTING: Fix-OrphanedResources.ps1 remediates orphaned resources
// [ ] TESTING: Suggest-RenameResource.ps1 suggests resource renames
// [ ] TESTING: Validate-DeskPoolMappings.ps1 validates desk pool mappings

## SiteManagement

// TESTING: SiteManagement
// [ ] TESTING: Export-SiteStructureTemplates.ps1 exports templates
// [ ] TESTING: Import-SiteStructureFromCSV.ps1 imports from CSV
// [ ] TESTING: Get-SiteStructure.ps1 retrieves site structure
// [ ] TESTING: Sync-MetadataToCloud.ps1 syncs metadata to cloud

## TemplateManagement

// TESTING: TemplateManagement
// [ ] TESTING: Export-AllTemplates.ps1 exports all templates
// [ ] TESTING: Export-MetadataTemplates.ps1 exports metadata templates
// [ ] TESTING: Import-FromCSV.ps1 imports from CSV
// [ ] TESTING: Import-MetadataFromCSV.ps1 imports metadata from CSV
// [ ] TESTING: Validate-CSVImport.ps1 validates CSV import

## Tests

// TESTING: Tests
// [ ] TESTING: Unit and integration tests exist and pass

## TestSuite

// TESTING: TestSuite
// [ ] TESTING: Cleanup-TestResources.ps1 removes test resources
// [ ] TESTING: Run-BookingSimulation.ps1 simulates booking scenarios
// [ ] TESTING: Run-TestSuite.ps1 runs all tests
// [ ] TESTING: Simulate-BookingTest.ps1 simulates booking test
// [ ] TESTING: Test-DeskProvisioning.ps1 tests desk provisioning
// [ ] TESTING: Test-MailboxSettings.ps1 tests mailbox settings
// [ ] TESTING: Test-RoomProvisioning.ps1 tests room provisioning
