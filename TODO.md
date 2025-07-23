<!-- omit from toc -->
# OfficeSpaceManager Improvement Opportunities

This document summarizes code review findings and improvement opportunities for the OfficeSpaceManager project. Each area in the summary table links to a detailed section below, including observations, opportunities, and where to apply them.

- [Summary Table](#summary-table)
- [Modularisation](#modularisation)
- [Logging and Error Handling](#logging-and-error-handling)
- [Parameter Validation and Consistency](#parameter-validation-and-consistency)
- [Code Reuse and Modularity](#code-reuse-and-modularity)
- [Naming Conventions](#naming-conventions)
- [Documentation and Comments](#documentation-and-comments)
- [Testing and Validation](#testing-and-validation)
- [Configuration Management](#configuration-management)
- [User Experience (CLI Menus)](#user-experience-cli-menus)
- [Bulk Operations and Data Validation](#bulk-operations-and-data-validation)
- [Module Packaging](#module-packaging)
- [Backup and Restore](#backup-and-restore)
- [Security](#security)
- [Performance](#performance)
- [Output Formatting](#output-formatting)
- [Error Recovery and Reporting](#error-recovery-and-reporting)
- [Specification Alignment](#specification-alignment)
- [Project Specification TODOs](#project-specification-todos)

---

## <a name='SummaryTable'></a>Summary Table

| Area                  | Opportunity                                 | Where                                      |
|-----------------------|---------------------------------------------|--------------------------------------------|
| [Modularisation](#modularisation)         | Centralize, standardize                     | All scripts, especially CLI, Shared        |
| [Logging/Error](#logging-and-error-handling)         | Centralize, standardize                     | All scripts, especially CLI, Shared        |
| [Parameter Validation](#parameter-validation-and-consistency)  | Add validation, consistency                 | All functions                              |
| [Code Reuse](#code-reuse-and-modularity)            | Refactor repeated logic                     | CLI, Shared, OrphanFixer, TestSuite        |
| [Naming](#naming-conventions)                | Standardize naming conventions              | All scripts/functions                      |
| [Documentation](#documentation-and-comments)         | Add help/comments                           | All scripts                                |
| [Testing](#testing-and-validation)               | Add/expand Pester tests                     | TestSuite, new Tests folder                |
| [Configuration](#configuration-management)         | Centralize config                           | Configuration, Shared                      |
| [User Experience](#user-experience-cli-menus)       | Standardize CLI menus                       | CLI                                        |
| [Data Validation](#bulk-operations-and-data-validation)       | Validate CSV/JSON before import             | TemplateManagement, SiteManagement         |
| [Module Packaging](#module-packaging)      | Create PowerShell module                    | Shared                                     |
| [Backup/Restore](#backup-and-restore)        | Add versioning, integrity checks            | Configuration\BackupRestore.ps1            |
| [Security](#security)              | Secure credential handling                  | Auth scripts                               |
| [Performance](#performance)           | Use parallel processing                     | Bulk scripts                               |
| [Output Formatting](#output-formatting)     | Standardize output                          | All user-facing scripts                    |
| [Error Reporting](#error-recovery-and-reporting)       | Aggregate/report errors in batch jobs        | Bulk scripts                               |
| [Specification Alignment](#specification-alignment) | Track and implement all specifications      | All relevant scripts and documentation     |

---


## <a name='modularisation'></a>Modularisation

**Status:**  
Complete  
// NOTE - Modularisation
- [X] TODO: Modularisation - First pass


**Observation:**  
As part of cleaning up the code, it becomes harder to understand where each function is located, and due to the size of the .ps1 files they're contained within, harder to navigate.

**Opportunities:**  
- Fully modularise all function code within the project

**Where:**  
- Whole project

---

## <a name='LoggingandErrorHandling'></a>Logging and Error Handling

**Status:**  
Complete
// NOTE -  Logging and Error Handling
- [X] TODO: Improve Logging and Error Handling


**Observation:**  
Some scripts use custom logging and error handling, while others use inline `Write-Host` or `Write-Error`. Not all scripts leverage shared logging utilities.

**Opportunities:**  
- [X] TODO: Refactor all scripts to use centralized logging functions from `Shared\Logging.ps1`.
- [X] TODO: Replace direct `Write-Host`/`Write-Error` with `Write-Log` or similar.
- [X] TODO: Ensure all try/catch blocks use a standard error reporting function.

**Where:**  
- `CLI\*`, `Configuration\*`, `OrphanFixer\*`, `SiteManagement\*`, and any script with direct output or error handling.

---

## <a name='ParameterValidationandConsistency'></a>Parameter Validation and Consistency

**Status:**  
Incomplete  
// FIXME - Parameter Validation and Consistency

**Observation:**  
Some functions/scripts use `[Parameter()]` attributes and validation, others accept parameters without validation.

**Opportunities:**  
- [ ] TODO: Add `[Parameter(Mandatory=$true)]` and `[ValidateNotNullOrEmpty()]` to all function parameters.
- [ ] TODO: Use consistent parameter naming and casing.

**Where:**  
- All function definitions, especially in `Shared\`, `SiteManagement\`, and `TemplateManagement\`.

---

## <a name='CodeReuseandModularity'></a>Code Reuse and Modularity

**Status:**  
Incomplete  
// FIXME - Code Reuse and Modularity

**Observation:**  
There is some duplication of logic (e.g., connecting to Exchange/Graph, reading/writing JSON).

**Opportunities:**  
- [X] TODO: Move all connection logic to `Shared\Connection.ps1`.
  > Mitigated by modularisation.
- [ ] TODO: Centralize JSON/CSV read/write functions.
- [ ] TODO: Refactor repeated code into reusable functions.

**Where:**  
- `CLI\*`, `Configuration\*`, `OrphanFixer\*`, `TestSuite\*`.

---

## <a name='NamingConventions'></a>Naming Conventions

**Status:**  
Incomplete  
// FIXME - Naming Conventions

**Observation:**  
Script and function names are mostly consistent, but some use different casing or abbreviations.

**Opportunities:**
- [ ] TODO: Standardize on `PascalCase` for functions and scripts.
- [ ] TODO: Prefix all public functions with `OSM-` (e.g., `OSM-ConnectToExchange`).

**Where:**  
- All scripts and function definitions.

---

## <a name='DocumentationandComments'></a>Documentation and Comments

**Status:**  
In progress  
// FIXME - Documentation and Comments
- [ ] TODO: Fix Documentation and Comments
    > Forms part of project instructions.
- [ ] TODO: Revisit resource and alias naming conventions, and look for ways to provide options within the CLI for constructing a naming convention, modifying a naming convention, and applying modified naming conventions to existing resources where needed (version 2 release feature)  

**Observation:**  
Some scripts have good comments, others lack parameter/function descriptions.

**Opportunities:**  
- [X] TODO: Add comment-based help to all functions (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`).
> Forms part of project instructions.
- [X] TODO: Ensure every script has a header comment describing its purpose.
> Forms part of project instructions.

**Where:**  
- All scripts, especially in `Shared\`, `CLI\`, and `TestSuite\`.

---

## <a name='TestingandValidation'></a>Testing and Validation

**Status:**  
Incomplete  
// FIXME - Testing and Validation

**Observation:**  
There is a `TestSuite`, but not all core functions are covered by tests.

**Opportunities:**  
- [ ] TODO: Add Pester tests for all critical functions (connection, provisioning, sync, orphan detection).
- [ ] TODO: Validate output and error scenarios.

**Where:**  
- `TestSuite\*`, and create a `Tests\` folder for unit tests.

---

## <a name='ConfigurationManagement'></a>Configuration Management

**Status:**  
Incomplete  
// FIXME - Configuration Management

**Observation:**  
Configuration is spread across scripts and JSON files.

**Opportunities:**  
- [ ] TODO: Centralize all configuration in a single JSON or PowerShell data file.
- [ ] TODO: Load configuration at startup and pass as needed.

**Where:**  
- `Configuration\*`, `Shared\*`.

---

## <a name='UserExperienceCLIMenus'></a>User Experience (CLI Menus)

**Status:**  
Incomplete  
// FIXME - User Experience (CLI Menus)

**Observation:**  
CLI menus are functional but could be more consistent in style and navigation.

**Opportunities:**  
- [ ] TODO: Standardize menu prompts, input validation, and navigation (e.g., always offer "Back" and "Exit").
- [ ] TODO: Use a shared menu rendering function.

**Where:**  
- `CLI\*`.

---

## <a name='BulkOperationsandDataValidation'></a>Bulk Operations and Data Validation

**Status:**  
Incomplete  
// FIXME - Bulk Operations and Data Validation

**Observation:**  
CSV import/export scripts do not always validate data before processing.

**Opportunities:**  
- [ ] TODO: Add schema validation for CSV/JSON before import.
- [ ] TODO: Provide clear error messages for invalid data.

**Where:**  
- `TemplateManagement\*`, `SiteManagement\*`.

---

## <a name='ModulePackaging'></a>Module Packaging

**Status:**  
Incomplete  
// FIXME - Module Packaging

**Observation:**  
Reusable functions are in `.ps1` files, not a PowerShell module.

**Opportunities:**  
- [ ] TODO: Package shared functions as a `.psm1` module with a manifest.
- [ ] TODO: Import the module in all scripts.

**Where:**  
- `Shared\*`.

---

## <a name='BackupandRestore'></a>Backup and Restore

**Status:**  
Incomplete  
// FIXME - Backup and Restore

**Observation:**  
Backup/restore scripts exist but could be more robust.

**Opportunities:**  
- [ ] TODO: Add versioning to backups.
- [ ] TODO: Validate backup integrity before restore.

**Where:**  
- `Configuration\BackupRestore.ps1`.

---

## <a name='Security'></a>Security

**Status:**  
Incomplete  
// FIXME - Security

**Observation:**  
Some scripts may store credentials or tokens in plain text.

**Opportunities:**  
- [ ] TODO: Use `Get-Credential` or secure vaults for sensitive data.
- [ ] TODO: Never write credentials to disk.

**Where:**  
- Any script handling authentication.

---

## <a name='Performance'></a>Performance

**Status:**  
Incomplete  
// FIXME - Performance

**Observation:**  
Some scripts process resources sequentially.

**Opportunities:**  
- [ ] TODO: Use parallel processing (`ForEach-Object -Parallel`) for large bulk operations.

**Where:**  
- Bulk provisioning, sync, and orphan detection scripts.

---

## <a name='OutputFormatting'></a>Output Formatting

**Status:**  
Incomplete  
// FIXME - Output Formatting

**Observation:**  
Output is sometimes raw, sometimes formatted.

**Opportunities:**  
- [ ] TODO: Standardize output formatting (tables, lists, JSON).
- [ ] TODO: Offer a `-Verbose` or `-Quiet` switch.

**Where:**  
- All user-facing scripts.

---

## <a name='ErrorRecoveryandReporting'></a>Error Recovery and Reporting

**Status:**  
Incomplete  
// FIXME - Error Recovery and Reporting

**Observation:**  
Batch operations may stop on first error.

**Opportunities:**  
- [ ] TODO: Implement error aggregation and summary reporting at the end of batch jobs.

**Where:**  
- Bulk import/export, sync, and other batch processing scripts.

---

## <a name='SpecificationAlignment'></a>Specification Alignment

**Status:**  
Incomplete  
// FIXME - Specification Alignment

**Observation:**  
Not all features and requirements from SPECIFICATION.md are clearly tracked or implemented.

**Opportunities:**  
- [ ] TODO: Review SPECIFICATION.md and ensure all items are addressed in the project.
- [ ] TODO: Create tasks or documentation for any missing features or requirements.

**Where:**  
- Review entire project against SPECIFICATION.md.

---

## <a name='ProjectSpecificationTODOs'></a>Project Specification TODOs

**Status:**  
Incomplete  
// FIXME - Project Specification TODOs

**Observation:**  
The following items from the project specification require implementation:

**Opportunities:**  
- [ ] TODO: Check and correct any absolute dot-sourcing in the project (for example C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\)
- [X] TODO: Implement a unified, menu-driven CLI entry point that covers all major operations (resource provisioning, metadata management, backup/restore, etc.).
- [X] TODO: Ensure all CLI menus use a consistent style, navigation, and input validation, with shared rendering functions.
- [X] TODO: Add a menu option and script for first-time setup and validation of Exchange/Teams/Places configuration.
- [X] TODO: Add/complete menu-driven flows for resource lifecycle management (create, rename, reassign, retire desks/rooms/equipment).
- [ ] TODO: Add/complete bulk import/export (CSV) for all resource types (sites, buildings, floors, desks, desk pools, etc.), with schema validation and error reporting.
- [ ] TODO: Ensure all metadata management scripts support local caching, offline storage, and synchronisation.
- [ ] TODO: Implement full and partial backup/restore for configuration and metadata, with versioning and integrity checks.
- [X] TODO: Ensure all scripts use centralised, timestamped logging and standardised error handling (via Logging module).
- [ ] TODO: Validate all user input, parameters, and imported data (CSV/JSON) before processing.
- [ ] TODO: Ensure native integration with ExchangeOnlineManagement, MicrosoftTeams, and Microsoft Graph modules, with robust connection logic.
- [ ] TODO: Expand the simulation test suite to cover all provisioning logic, with cleanup tools and test result logging.
- [ ] TODO: Refactor codebase to ensure all modules/scripts are easily extensible for future features/domains.
- [ ] TODO: Document all supported OS versions, PowerShell versions, and dependencies in README.md and script headers.
- [ ] TODO: Ensure all scripts are idempotent and safe to run multiple times without causing inconsistent state.
- [ ] TODO: Add/expand Pester tests for all critical functions and flows, and document how to run them.
- [X] TODO: Ensure all user-facing output and documentation uses inclusive, accessible language and formatting.
- [ ] TODO: Add/expand backup/restore versioning, integrity checks, and disaster recovery documentation.
- [ ] TODO: Review and update all scripts for secure credential handling (no hardcoded secrets, use secure vaults or managed identities).
- [ ] TODO: Add/expand error aggregation and summary reporting for all batch/bulk operations.
- [ ] TODO: Ensure all scripts/modules include a version number, changelog, and rollback/undo instructions.
- [ ] TODO: Add/expand support/escalation process and post-incident logging for production scripts.
- [ ] TODO: Ensure all scripts clean up after themselves (temp files, test data, connections) and document cleanup steps.
- [ ] TODO: Review and update README.md to ensure all specification requirements are documented and up to date.

---