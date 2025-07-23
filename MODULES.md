# OfficeSpaceManager Modules

This document describes all PowerShell modules in the OfficeSpaceManager project, their purposes, and the key functions or features they provide. This supports maintainability, discoverability, and onboarding for new contributors.

---

## Table of Contents

- [OfficeSpaceManager Modules](#officespacemanager-modules)
  - [Table of Contents](#table-of-contents)
  - [CLI](#cli)
  - [Configuration](#configuration)
  - [Logging](#logging)
  - [Reporting](#reporting)
  - [SiteManagement](#sitemanagement)
  - [UserManagement](#usermanagement)
  - [Utilities](#utilities)
  - [Modules](#modules)
  - [Notes](#notes)

---

## CLI

**Path:** `Modules/CLI/CLI.psm1`

- Provides all core CLI menu rendering, navigation, and user interaction logic.
- **Exported Functions:**
  - `Display-PanelHeader` — Renders a standard panel header for CLI menus.
  - `Show-ActionHistory` — Displays recent user or system actions.
  - `New-SecurePassword` — Generates a secure password for provisioning flows.
- Used by: All main CLI scripts and wizards.

---

## Configuration

**Path:** `Modules/Configuration/Configuration.psm1`

- Handles configuration loading, validation, and backup/restore logic.
- **Exported Functions:**
  - `Create-ConfigBackup` — Creates a backup of the current configuration.
  - `Restore-ConfigBackup` — Restores configuration from a backup.
  - `Try-LoadJson` — Helper to safely load JSON files.
  - `Run-FirstTimeSetup` — Runs initial setup and validation.
  - `Validate-ExchangeSetup` — Validates Exchange Online configuration.
  - `Validate-PlacesFeatures` — Validates Places features configuration.
  - `Enable-PlacesFeatures` — Enables Places features in the environment.
- Used by: Configuration scripts, backup/restore, and validation flows.

---

## Logging

**Path:** `Modules/Logging/Logging.psm1`

- Centralises all logging, transcript, and error reporting logic.
- **Exported Functions:**
  - `Write-Log` — Writes timestamped log entries to file and console.
- Used by: All scripts for consistent logging and diagnostics.

---

## Reporting

**Path:** `Modules/Reporting/Reporting.psm1`

- Provides reporting, export, and summary generation utilities.
- **Exported Functions:**
  - `Export-AllTemplates` — Exports all supported metadata templates.
  - `Export-MetadataTemplates` — Exports pathway and desk role templates.
  - `Generate-Report` — Generates a report (see module for details).
  - `Show-Report` — Displays a report (see module for details).
- Used by: Export, reporting, and summary scripts.

---

## SiteManagement

**Path:** `Modules/SiteManagement/SiteManagement.psm1`

- Manages site, building, floor, desk, and resource metadata.
- **Exported Functions:**
  - `Export-SiteStructureTemplates` — Exports site structure templates.
  - `Import-SiteStructureFromCSV` — Imports site structure from CSV.
  - `Get-SiteStructure` — Lists the current site structure.
  - `Sync-MetadataToCloud` — Syncs local metadata to the cloud.
- Used by: Site management, import/export, and sync scripts.

---

## UserManagement

**Path:** `Modules/UserManagement/UserManagement.psm1`

- Handles user provisioning, assignment, and user-related metadata.
- **Exported Functions:**
  - *(No implemented functions yet; placeholder for `Get-User`, `Add-User` as per TODO in module.)*
- Used by: User management and provisioning scripts.

---

## Utilities

**Path:** `Modules/Utilities/Utilities.psm1`

- Provides shared utility functions (validation, file I/O, connection helpers, etc.).
- **Exported Functions:**
  - `Get-StandardDeskName` — Returns a standardised desk name for a given resource.
  - `Connect-ExchangeAdmin` — Connects to Exchange Online as an admin.
  - `Connect-Graph` — Connects to Microsoft Graph.
  - `Connect-TeamsService` — Connects to Microsoft Teams service.
- **Special Utility:**
  - `Resolve-OfficeSpaceManagerRoot.ps1` — Robustly resolves the project root and sets `$env:OfficeSpaceManagerRoot` for all module imports. This script is dot-sourced at the top of every script that uses Import-Module, ensuring all module paths are absolute and error-proof regardless of working directory or invocation method.
- Used by: All scripts and modules for common logic.

---

## Modules

- CLI: User interface and menu logic
- Configuration: Handles configuration and validation
- Logging: Centralised logging and error handling
- Reporting: Generates reports and exports
- SiteManagement: Manages sites, buildings, floors, desks
- UserManagement: User and permissions management
- Utilities: Helper functions and root resolution

---

## Notes

- All modules follow the documentation and quality standards described in `CommonInstructions.instructions.md`.
- For detailed function lists, see the comment-based help in each `.psm1` file.
- This document should be updated whenever modules are added, removed, or significantly changed.
