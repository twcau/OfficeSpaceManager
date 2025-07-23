<!-- omit from toc -->
# PowerShell Project Modularisation Guide

- [0. Modularisation areas](#0-modularisation-areas)
  - [OA. Modularisation plan](#oa-modularisation-plan)
  - [OB. Modularisation question](#ob-modularisation-question)
- [1. Define Logical Areas (Domains)](#1-define-logical-areas-domains)
- [2. Proposed Folder Structure](#2-proposed-folder-structure)
- [3. How to Modularise](#3-how-to-modularise)
- [4. Example: Logging Module](#4-example-logging-module)
  - [Modules/Logging/Logging.psm1](#modulesloggingloggingpsm1)
  - [Usage in another script](#usage-in-another-script)
- [5. Refactoring Existing Scripts](#5-refactoring-existing-scripts)
- [6. Naming and Documentation](#6-naming-and-documentation)
- [7. Testing](#7-testing)
- [8. Automation](#8-automation)
- [9. .gitignore](#9-gitignore)
- [10. Summary Table](#10-summary-table)
- [Next Steps](#next-steps)

## 0. Modularisation areas

// NOTE - Modularisation

- [X] TODO: Logging (e.g., Write-Log, error handling)
- [X] TODO: Utilities (helper functions, shared logic)
- [X] TODO: CLI (menu rendering, prompts, CLI output)
- [X] TODO: SiteManagement (building, floor, site, desk management)
- [X] TODO: Configuration (import/export, backup/restore, validation)  
  > All Configuration .ps1 scripts now import and call the module version. No duplicate logic remains in scripts.
- [X] TODO: UserManagement (user and permissions logic)
  > Nothing was found needing user attention.
- [X] TODO: Reporting (report and summary generation)
  > All Configuration .ps1 scripts now import and call the module version. No duplicate logic remains in scripts.

### OA. Modularisation plan

1. Identify all logging-related functions and scripts
For example - Locate all instances of Write-Log and any related logging/error handling functions (e.g., in Write-Log.ps1, Global-ErrorHandling.ps1, or similar).
2. Move these functions into Modules\*
Consolidate all logging and error handling logic into this file.
3. Update *Logging*.psm1
Ensure it dot-sources *.ps1 and exports all public functions.
4. Update all scripts that use logging
Remove any direct dot-sourcing of the old scripts.
And where needed, Add Import-Module *.psm1 (or the correct relative path) at the top of scripts that use*.
5. Replace any duplicate or now-centralised logging function definitions.
6. Clean up
Remove the old *.ps1 and any other now-obsolete logging scripts after confirming all references are updated.
7. Test
Run scripts and flows that use * to ensure no regressions.

### OB. Modularisation question

Still sticking with the earlier Option 1, let's move onto modularising X/ now, and ensuring that:

Proper clean-up is done, to ensure no duplicated code for anything migrated into a module is left anywhere across the project;
All required updates performed to scripts that ensure the modularised code works properly, and can be correctly called at the right point when used and needed;
Done in a way which doesn't cause an operational or functional regression in the project, project functionality, codebase, or any other part which impacts what the code does.
You alert me to any concerns, and seek my input if needed - providing appropriate explaination, so an informed decision or choice can be taken before you proceed.
Provide, in raw, all progress and updates as you work through this. Do not make me ask for updates, make sure I can see exactly what you are working on and making progress towards.
Make sure that the resulting actions are appropriately documented, in a file along the lines of _README-Area-Migration.txt, similar to those files already in Shared/

---

Please continue with the remaining folders (Configuration, OrphanFixer, EnvironmentSetup, Shared, and TestSuite) to ensure all scripts are updated for modular logging and error handling; remembering my earlier instructions on expcectations, behaviours, cleanliness, housekeeping, anti-regression, and notifying of any concerns before proceeding with a change.

---

Thanks, and please proceed with final clean-up and validation of your actions.

---

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

```text
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

### Modules/Logging/Logging.psm1

```powershell
function Write-Log { ... }
function Get-LogLevel { ... }
Export-ModuleMember -Function Write-Log, Get-LogLevel
```

### Usage in another script

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
- Test each module in isolation, then as part of whatever.
