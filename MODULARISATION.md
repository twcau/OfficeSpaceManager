<!-- omit from toc -->
# PowerShell Project Modularisation Guide

- [1. Define Logical Areas (Domains)](#1-define-logical-areas-domains)
- [2. Proposed Folder Structure](#2-proposed-folder-structure)
- [3. How to Modularise](#3-how-to-modularise)
- [4. Example: Logging Module](#4-example-logging-module)
- [5. Refactoring Existing Scripts](#5-refactoring-existing-scripts)
- [6. Naming and Documentation](#6-naming-and-documentation)
- [7. Testing](#7-testing)
- [8. Automation](#8-automation)
- [9. .gitignore](#9-gitignore)
- [10. Summary Table](#10-summary-table)
- [Next Steps](#next-steps)


## 1. Define Logical Areas (Domains)

Think about the main “areas” or “domains” of your project. For example:

- **Logging & Utilities**: Logging, error handling, helpers.
- **CLI/Presentation**: Menu rendering, user prompts, CLI output.
- **Site Management**: Building, floor, site, and desk management.
- **Configuration**: Import/export, backup/restore, validation.
- **User Management**: User and permissions handling.
- **Reporting**: Generating and displaying reports.

---

## 2. Proposed Folder Structure

```
OfficeSpaceManager/
│
├── Modules/
│   ├── Logging/
│   │   └── Logging.psm1
│   ├── Utilities/
│   │   └── Utilities.psm1
│   ├── CLI/
│   │   └── CLI.psm1
│   ├── SiteManagement/
│   │   └── SiteManagement.psm1
│   ├── Configuration/
│   │   └── Configuration.psm1
│   ├── UserManagement/
│   │   └── UserManagement.psm1
│   └── Reporting/
│       └── Reporting.psm1
│
├── Scripts/
│   └── (Entry-point scripts, e.g. Start-OfficeSpaceManager.ps1)
│
├── Shared/
│   └── (Shared scripts or data files)
│
├── Backups/
│
├── Tests/
│   └── (Pester or other test scripts)
│
└── .gitignore
```

---

## 3. How to Modularise

- **Group related functions** into `.psm1` module files (e.g., all logging functions in `Logging.psm1`).
- **Export only public functions** from each module (using `Export-ModuleMember`).
- **Use `Import-Module`** in your entry-point scripts or in other modules as needed.
- **Keep entry-point scripts** (the ones users run directly) in the `Scripts/` folder. These scripts should mostly call functions from your modules.

---

## 4. Example: Logging Module

**Modules/Logging/Logging.psm1**
```powershell
function Write-Log { ... }
function Get-LogLevel { ... }
Export-ModuleMember -Function Write-Log, Get-LogLevel
```

**Usage in another script:**
```powershell
Import-Module "$PSScriptRoot/../Modules/Logging/Logging.psm1"
Write-Log -Message "Hello" -Level "INFO"
```

---

## 5. Refactoring Existing Scripts

- **Move functions** from your `.ps1` scripts into the appropriate `.psm1` module.
- **Replace duplicate helpers** with shared functions in `Utilities.psm1`.
- **Update scripts** to import and use these modules, rather than duplicating code.

---

## 6. Naming and Documentation

- **Name modules and folders** for their domain/purpose.
- **Add comment-based help** to each function for discoverability.
- **Document module purpose** at the top of each `.psm1`.

---

## 7. Testing

- Place Pester or other test scripts in the `Tests/` folder, mirroring your module structure.

---

## 8. Automation

- Consider a bootstrap script (e.g., `Scripts/Start-OfficeSpaceManager.ps1`) that imports all needed modules and starts the CLI or main workflow.

---

## 9. .gitignore

- Ensure `Backups/`, `*.zip`, and any secrets/configs are ignored.

---

## 10. Summary Table

| Folder                | Purpose                                 |
|-----------------------|-----------------------------------------|
| Modules/Logging       | Logging, error handling                 |
| Modules/CLI           | CLI menus, prompts, output formatting   |
| Modules/SiteManagement| Building/floor/site/desk logic          |
| Modules/Configuration | Import/export, backup/restore           |
| Modules/UserManagement| User and permissions logic              |
| Modules/Reporting     | Reports and summaries                   |
| Modules/Utilities     | Shared helpers                          |
| Scripts/              | Entry-point scripts                     |
| Shared/               | Shared data/scripts                     |
| Backups/              | Backups (gitignored)                    |
| Tests/                | Unit/integration tests                  |

---

## Next Steps

- Start by creating the `Modules/` structure and moving functions into logical `.psm1` files.
- Update your entry scripts to use `Import-Module`.
- Test each module in isolation, then as part of