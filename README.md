<!-- omit from toc -->
# 🏢 OfficeSpaceManager

[![PowerShell 7+](https://img.shields.io/badge/PowerShell-7%2B-blue?logo=powershell)](https://learn.microsoft.com/en-au/powershell/scripting/overview?view=powershell-7.3)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](./)
[![Test Coverage](https://img.shields.io/badge/tests-passing-brightgreen)](./TestSuite)

A modular PowerShell CLI toolkit to establish a simple, and logical workflow from a single place to establish and manage Microsoft Places, Exchange Room Resources, and Metadata across Microsoft 365 environments.

> [!CAUTION]
> This repository is still under major initial development, and should be considered 'Extreme Alpha'. Any use of this repository is at your own risk knowing there will be continued and ongoing changes underway.

- [🏗️ Purpose](#️-purpose)
- [🛡 Design Philosophy](#-design-philosophy)
- [🚀 Features](#-features)
- [🔧 Requirements](#-requirements)
- [🧠 Usage](#-usage)
- [📁 Folder Structure](#-folder-structure)
  - [Key Documentation](#key-documentation)
  - [Folder tree](#folder-tree)
- [🧪 Running Tests](#-running-tests)
- [🔁 Backup \& Restore](#-backup--restore)
  - [Save current metadata snapshot](#save-current-metadata-snapshot)
  - [Restore from snapshot](#restore-from-snapshot)
- [🔗 Useful Microsoft Docs](#-useful-microsoft-docs)
- [🙋 Support](#-support)
- [🔐 Data Safety](#-data-safety)
- [🔧 TODO](#-todo)
- [📘 License \& Credits](#-license--credits)

---

## 🏗️ Purpose

This script is intended to help someone either setup, or manage, a Microsoft Exchange and Teams environment to:

- Removes the need to navigate across multiple Admin applications, scripts, blades, etc to setup and maintain
- Initial configuration (right settings configured so you can do this)
- Bulk upload and maintenance (by way of .csv file) of sites, buildings, floors, desk groups and desks
- Manage the bookable desk lifecycle (create, manage, rename, reassign, end of life)
- Ensure consistency of naming conventions for desks
- Provide disaster recovery for your environment, keeping offline backups of the environment for ease of restoration if and when needed
- Offline storage of data to increase speed of action
- Make your job as a Microsoft Modern Workplace analyist/engineer several times easier

A more detailed explaination to the working approach for this project can be found in [IDEA](IDEA.md) and [SPECIFICATION](SPECIFICATION.md).

---

## 🛡 Design Philosophy

- 💾 **Soft-deletion only** — desks and rooms are never fully deleted
- 💡 **Pre-validation of all inputs**
- 📦 **Reversible operations** — metadata snapshots, test cleanup
- 🔒 **Never destroys without confirmation**

---

## 🚀 Features

- ✅ Interactive CLI with modular submenus
- ✅ Automated first-time tenant setup (robustly enforced at launch)
- ✅ Resource provisioning (Desk / Room / Equipment)
- ✅ Metadata and site structure management, and local caching of information for speed
- ✅ CSV template export/import for bulk editing of sites, buildings, floors, desks, desk pools, etc.
- ✅ Logging, draft recovery, and error handling
- ✅ Simulation test suite with cleanup tools
- ✅ Auto-discovery of domains + validation of Exchange & Places configurations to support
- ✅ Exchange Online + Microsoft Graph Places + Microsoft Teams integration
- ✅ Uses native functions within existing PowerShell modules wherever possible
- ✅ Backup and restore features, to enable complete download and upload of your configuration
- ✅ **Verbose session logging and input capture via `-LogVerbose` flag**
- ✅ **Robust error handling and user acknowledgement for all critical failures**
- ✅ **Proactive Exchange Online connection and first-time setup enforcement**

---

## 🔧 Requirements

- PowerShell 7.0+
- Modules:

  - `ExchangeOnlineManagement`
  - `Microsoft.Graph`
  - `MicrosoftTeams`

> All required modules are validated as present, or user is prompted to install at runtime. Exchange Online connection and first-time setup are enforced at launch.

---

## 🧠 Usage

1. Open PowerShell 7+

2. Navigate to the folder

3. Run:

    ```powershell
    .\Invoke-MainMenu.ps1 [-LogVerbose]
    ```

    - The optional `-LogVerbose` flag enables full session transcript and input logging to `Logs/TerminalVerbose`.
    - On first run, you will be guided through robust first-time setup and Exchange Online connection. All errors require user acknowledgement and are logged.

---

## 📁 Folder Structure

WARNING: Due to continued development, this is subject to change.

### Key Documentation

- [README.md](./README.md) – Main documentation and usage guide (This file)
- [LICENSE](./LICENSE) – Project license
- [IDEA.md](./IDEA.md) – Project vision and rationale
- [SPECIFICATION.md](./SPECIFICATION.md) – Detailed project specification and requirements
- [MODULES.md](./MODULES.md) – Documentation of all modules and their functions
- [TODO.md](./TODO.md) – Outstanding tasks and improvement opportunities
- [KNOWNISSUES.md](./KNOWNISSUES.md) – Known issues and limitations

### Folder tree

```plaintext
OfficeSpaceManager/                  # Project root
│
│   All scripts and modules use robust root resolution for module imports:
│   - $env:OfficeSpaceManagerRoot is set at runtime using the Resolve-OfficeSpaceManagerRoot.ps1 helper.
│   - All Import-Module statements use this variable for absolute, error-proof paths.
│   - This prevents all fragile path errors regardless of working directory or invocation method.
│   - See Modules/Utilities/Resolve-OfficeSpaceManagerRoot.ps1 for implementation details.
│
├── Invoke-MainMenu.ps1              # Main CLI entry point for all operations
│                                    # Supports -LogVerbose for transcript and input logging.
│                                    # Robustly enforces first-time setup and Exchange Online connection │                                      at launch.
├── Backups/                         # Backups and backup scripts
│   ├── Restore-MetadataSnapshot.ps1 # Restore metadata snapshot
│   └── Save-MetadataSnapshot.ps1    # Save metadata snapshot
│
├── CLI/                             # CLI scripts and menu entry points
│   ├── ConfigurationMenu.ps1        # Configuration menu
│   ├── LogsMenu.ps1                 # Logs menu
│   ├── ManageResourcesMenu.ps1      # Resource management menu
│   ├── OrphanMetadatamenu.ps1       # Orphan metadata menu
│   ├── Display-PanelHeader.ps1      # (Obsolete) Use Display-PanelHeader from CLI module
│   ├── Show-ActionHistory.ps1       # (Obsolete) Use Display-ActionHistory from CLI module
│   ├── Logs/                        # CLI-specific logs
│   ├── Manage/                      # CLI-specific management scripts
│   └── Wizards/                     # Interactive CLI wizards for resource/desk pools
│
├── config/                          # Tenant config and first-run flags
│   ├── FirstRunComplete.json        # First-run completion flag
│   └── TenantConfig.json            # Tenant configuration
│
├── Configuration/                   # Config validation/setup flows (legacy scripts)
│   ├── Create-ConfigBackup.ps1      # Create config backup ZIP
│   ├── Enable-PlacesFeatures.ps1    # Enable Microsoft Places features
│   ├── Restore-ConfigBackup.ps1     # Restore config from backup
│   ├── Run-FirstTimeSetup.ps1       # First-time setup wizard
│   ├── Validate-ExchangeSetup.ps1   # Validate Exchange setup
│   └── Validate-PlacesFeatures.ps1  # Validate Places/Teams setup
│
├── EnvironmentSetup/                # M365 mailbox/calendar config scripts
│   ├── Ensure-CalendarProcessingSettings.ps1 # Ensure correct calendar processing
│   ├── Pin-PlacesAppInTeams.ps1              # Pin Places app in Teams
│   └── Update-MailboxTypes.ps1               # Update mailbox types
│
├── Logs/                            # Log files and log management scripts
│   ├── ActionHistory-*.txt          # Action history logs
│   ├── Archive/                     # Archived logs
│   ├── Clear-LogHistory.ps1         # Clear log history
│   ├── Compress-Logs.ps1            # Compress logs
│   ├── Export-ActionHistory.ps1     # Export action history
│   ├── Log_*.log                    # Log files
│   └── View-LogHistory.ps1          # View log history
│
├── Metadata/                        # Primary system metadata (JSON)
│   ├── .lastSync.json               # Last sync state
│   └── CachedResources.json         # Cached resources
│
├── Modules/                         # PowerShell modules (core logic, reusable functions)
│   ├── CLI/                         # CLI menu rendering and user interaction logic
│   ├── Configuration/               # Config import/export, backup/restore, validation
│   ├── Logging/                     # Centralised logging and error handling
│   ├── Reporting/                   # Reporting and summary generation
│   ├── SiteManagement/              # Site/building/floor/desk management logic
│   ├── UserManagement/              # User and permissions logic
│   └── Utilities/                   # Helper and utility functions (e.g., connections)
│
├── OrphanFixer/                     # Tools for resolving orphaned resources
│   ├── Detect-NonStandardResources.ps1     # Detect non-standard resources
│   ├── Find-OrphanedResources.ps1          # Find orphaned resources
│   ├── Fix-OrphanedResources.ps1           # Remediate orphaned resources
│   ├── Suggest-RenameResource.ps1          # Suggest resource renames
│   └── Validate-DeskPoolMappings.ps1       # Validate desk pool mappings
│
├── SiteManagement/                  # Metadata sync and site structure operations
│   ├── CachedResources/                     # Cached resource data/scripts
│   ├── Export-SiteStructureTemplates.ps1    # Export site structure templates
│   ├── Import-SiteStructureFromCSV.ps1      # Import site structure from CSV
│   ├── Get-SiteStructure.ps1                # Get site structure
│   └── Sync-MetadataToCloud.ps1             # Sync metadata to cloud
│
├── TemplateManagement/              # Import/export CSV metadata templates
│   ├── Export-AllTemplates.ps1      # Export all templates
│   ├── Export-MetadataTemplates.ps1 # Export metadata templates
│   ├── Import-FromCSV.ps1           # Import from CSV
│   ├── Import-MetadataFromCSV.ps1   # Import metadata from CSV
│   └── Validate-CSVImport.ps1       # Validate CSV import
│
├── Tests/                           # Unit and integration tests (Pester, etc.)
│
├── TestSuite/                       # Simulation and test suite scripts
│   ├── Cleanup-TestResources.ps1    # Remove test resources
│   ├── Run-BookingSimulation.ps1    # Simulate booking scenarios
│   ├── Run-TestSuite.ps1            # Run all tests
│   ├── Simulate-BookingTest.ps1     # Simulate a booking test
│   ├── Test-DeskProvisioning.ps1    # Test desk provisioning
│   ├── Test-MailboxSettings.ps1     # Test mailbox settings
│   └── Test-RoomProvisioning.ps1    # Test room provisioning
```

Each folder and file is annotated above with a short summary of its purpose and contents.

---

## 🧪 Running Tests

To simulate full provisioning and cleanup:

```powershell
.\TestSuite\Run-TestSuite.ps1
```

To remove all test resources:

```powershell
.\TestSuite\Cleanup-TestResources.ps1
```

Test results and logs are saved in:

```powershell
\TestResults\
```

---

## 🔁 Backup & Restore

### Save current metadata snapshot

From the menu:

```text
Main Menu > Metadata & Logs > Save Metadata Snapshot
```

Or run manually:

```powershell
.\Backups\Save-MetadataSnapshot.ps1
```

### Restore from snapshot

```powershell
.\Backups\Restore-MetadataSnapshot.ps1
```

You can also use:

```powershell
. (Join-Path $env:OfficeSpaceManagerRoot 'Configuration/Create-ConfigBackup.ps1')
. (Join-Path $env:OfficeSpaceManagerRoot 'Configuration/Restore-ConfigBackup.ps1')
```

To create/import a full `.zip` archive of your working config.

---

## 🔗 Useful Microsoft Docs

- [Microsoft Places Overview](https://learn.microsoft.com/microsoft-places/)
- [Microsoft Graph Places API](https://learn.microsoft.com/graph/api/resources/place?view=graph-rest-1.0)
- [Exchange Room Mailbox Docs](https://learn.microsoft.com/exchange/recipients/room-mailboxes)
- [Set-CalendarProcessing](https://learn.microsoft.com/powershell/module/exchange/set-calendarprocessing)

---

## 🙋 Support

If you're having trouble:

1. View the current log in `.\Logs\`
2. Use `Export Action History` in the CLI
3. Provide the export log when requesting help

---

## 🔐 Data Safety

All changes to Exchange/Graph are:

- Pre-validated
- Logged in `.Logs\`
- Cached locally for rollback
- Backed up with JSON snapshots

---

## 🔧 TODO

See [TODO](TODO.md).

---

## 📘 License & Credits

> OfficeSpaceManager – Internal Admin Toolkit
> © 2025 – Michael Harris. Use it well.
> Built with PowerShell for Microsoft 365 tenants

See [LICENSE](LICENSE) for further information.
