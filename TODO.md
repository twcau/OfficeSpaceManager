<!-- omit from toc -->
# OfficeSpaceManager Improvement Opportunities

This document summarizes code review findings and improvement opportunities for the OfficeSpaceManager project. Each area in the summary table links to a detailed section below, including observations, opportunities, and where to apply them.

- [Summary Table](#summary-table)
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

---

## <a name='SummaryTable'></a>Summary Table

| Area                  | Opportunity                                 | Where                                      |
|-----------------------|---------------------------------------------|--------------------------------------------|
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

---

## <a name='LoggingandErrorHandling'></a>Logging and Error Handling

**Status:**  
Incomplete  
// FIXME - Logging and Error Handling

**Observation:**  
Some scripts use custom logging and error handling, while others use inline `Write-Host` or `Write-Error`. Not all scripts leverage shared logging utilities.

**Opportunities:**  
- Refactor all scripts to use centralized logging functions from `Shared\Logging.ps1`.
- Replace direct `Write-Host`/`Write-Error` with `Write-Log` or similar.
- Ensure all try/catch blocks use a standard error reporting function.

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
- Add `[Parameter(Mandatory=$true)]` and `[ValidateNotNullOrEmpty()]` to all function parameters.
- Use consistent parameter naming and casing.

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
- Move all connection logic to `Shared\Connection.ps1`.
- Centralize JSON/CSV read/write functions.
- Refactor repeated code into reusable functions.

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
- Standardize on `PascalCase` for functions and scripts.
- Prefix all public functions with `OSM-` (e.g., `OSM-ConnectToExchange`).

**Where:**  
- All scripts and function definitions.

---

## <a name='DocumentationandComments'></a>Documentation and Comments

**Status:**  
Incomplete  
// FIXME - Documentation and Comments

**Observation:**  
Some scripts have good comments, others lack parameter/function descriptions.

**Opportunities:**  
- Add comment-based help to all functions (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`).
- Ensure every script has a header comment describing its purpose.

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
- Add Pester tests for all critical functions (connection, provisioning, sync, orphan detection).
- Validate output and error scenarios.

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
- Centralize all configuration in a single JSON or PowerShell data file.
- Load configuration at startup and pass as needed.

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
- Standardize menu prompts, input validation, and navigation (e.g., always offer "Back" and "Exit").
- Use a shared menu rendering function.

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
- Add schema validation for CSV/JSON before import.
- Provide clear error messages for invalid data.

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
- Package shared functions as a `.psm1` module with a manifest.
- Import the module in all scripts.

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
- Add versioning to backups.
- Validate backup integrity before restore.

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
- Use `Get-Credential` or secure vaults for sensitive data.
- Never write credentials to disk.

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
- Use parallel processing (`ForEach-Object -Parallel`) for large bulk operations.

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
- Standardize output formatting (tables, lists, JSON).
- Offer a `-Verbose` or `-Quiet` switch.

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
- Implement error aggregation and summary reporting at the end of batch jobs.

**Where:**  
- Bulk import/export, sync,