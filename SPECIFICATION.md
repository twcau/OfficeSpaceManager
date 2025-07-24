# 📋 Project Specification: OfficeSpaceManager

## 1. Scope

OfficeSpaceManager manages the lifecycle of Microsoft Places, Exchange Room Resources, and related metadata (sites, buildings, floors, desk groups, desks, desk pools) in Microsoft 365 environments.

## 2. Features

- **Interactive CLI:** Modular, menu-driven interface for all operations.
- **Automated Setup:** First-time setup and validation of Exchange/Teams/Places configuration.
- **Resource Provisioning:** Create, manage, rename, reassign, and retire desks, rooms, and equipment.
- **Bulk Operations:** Import/export via CSV for sites, buildings, floors, desks, desk pools, etc.
- **Metadata Management:** Local caching, offline storage, and synchronisation of metadata.
- **Backup & Restore:** Full and partial backup/restore of configuration and metadata, with versioning and integrity checks.
- **Logging & Error Handling:** Centralised, timestamped logging and standardised error handling across all scripts.
- **Validation:** Pre-import validation of CSV/JSON data, parameter validation, and configuration checks.
- **Integration:** Native use of ExchangeOnlineManagement, MicrosoftTeams, and Microsoft Graph modules.
- **Testing:** Simulation test suite for provisioning logic, with cleanup tools and test result logging.
- **Extensibility:** Modular codebase for easy addition of new features and domains.
- **Robust Connection Logic:** All service connection functions (Exchange, Teams, Places) use resilient, session-reusing logic with authoritative session validation and clear diagnostic output.
- **Approved Verb Usage:** All functions, scripts, and modules use approved PowerShell verbs for discoverability and linter compliance. Refactors and renames update all references project-wide.
- **Linting and Static Analysis:** All code must pass PSScriptAnalyzer linting with no critical errors. Linting and static analysis are required before every major commit or release.
- **Refactor Hygiene:** Any rename or modularisation includes a project-wide update of all references and documentation. No legacy or obsolete references are permitted after refactor.
- **Error Handling and User Experience:** All error messages are clear, actionable, and remain visible until acknowledged by the user. All catch blocks end with a user acknowledgement prompt unless handled globally. Error handling includes context (script name, operation, error details).
- **Accessible Output and Documentation:** All user-facing output and documentation use EN-AU spelling and accessible, inclusive language.
- **Session Validation:** After any connection attempt, session validity is confirmed before proceeding with operations. If session is not valid, operations are skipped with clear messaging.

## 3. Requirements

- PowerShell 7.0+
- Modules: ExchangeOnlineManagement, MicrosoftTeams
- Supported OS: Windows (cross-platform support planned)
- All dependencies validated or installed at runtime

## 4. Constraints

- Must follow modularisation and code quality standards (see project instructions)
- All scripts must be idempotent, robust, and production-ready
- No hardcoded credentials; secure handling of secrets
- All user-facing output and documentation must use inclusive, accessible language
- Must support backup/restore and disaster recovery scenarios

## 5. Intended Outcomes

- Streamlined, reliable admin workflows for Microsoft 365 resource management
- Consistent, auditable, and recoverable environment configuration
- Reduced manual effort and error rates
- Improved reporting, logging, and troubleshooting
- Foundation for future extensibility and automation

## 6. Architecture: Robust Module Resolution

- All scripts and modules must use robust, error-proof module importing:
  - The project root is resolved at runtime using the `Resolve-OfficeSpaceManagerRoot.ps1` helper (searches upwards for README.md or .git).
  - `$env:OfficeSpaceManagerRoot` is set and used for all Import-Module statements, ensuring absolute, reliable paths.
  - No script or module should use fragile relative navigation (e.g., `$PSScriptRoot/..`).
  - This approach guarantees module imports work regardless of working directory, invocation method, or platform.
  - See `Modules/Utilities/Resolve-OfficeSpaceManagerRoot.ps1` for implementation details.

## 7. Architecture: Microsoft Cloud Connection Robustness Standards

All functions that connect to Microsoft Cloud services (Exchange Online, Microsoft Graph, Microsoft Teams, etc.) must:

- Ensure the required module is loaded, with robust error handling and logging for import failures.
- Attempt to reuse an existing session, logging the outcome and returning the connected account if available.
- If no session exists, attempt a new connection, logging all connection steps and outcomes.
- Log and handle all errors, including inner exceptions, with clear, actionable diagnostic information.
- Provide comprehensive inline comments at every stage explaining the logic and error handling.
- Return a clear status or account identifier, or $null/$false on failure, with all failures logged.
- Match the robustness, documentation, and maintainability standards demonstrated in the revised utility module functions (Connect-ExchangeAdmin, Connect-Graph, Connect-TeamsService).
- These standards must be enforced for all future and existing connection logic across the project.

## 8. Architecture: PowerShell String Interpolation and Linter Compliance

- Always use the PowerShell format operator (-f) for string interpolation when a variable is immediately followed by a colon, special character, or property accessor in double-quoted strings. This enres robust, linter-compliant, and maintainable code.
- Example:

```powershell
Write-Log -Message ('Failed to enable {0}: {1}' -f $feature, $errorMsg) -Level 'ERROR'
Write-Host ("`n❌ Failed to enable {0}: {1}" -f $feature, $errorMsg) -ForegroundColor Red
```

- If the linter flags a false positive for valid code using the format operator or string concatenation, document the issue and proceed with the format operator approach, as it is the most robust and idiomatic for PowerShell.
- Report any persistent false positives to the linter maintainers and include a comment in the code referencing the issue.
- Do not attempt to workaround the linter by using less robust or less readable code. Prioritise code correctness and maintainability.

## 9. Approved Verb Usage

All functions, scripts, and modules must use approved PowerShell verbs. This ensures discoverability and compliance with linter rules. Any refactor or rename must update all references throughout the project.

## 10. Linting and Static Analysis

All code must pass PSScriptAnalyzer linting with no critical errors. Linting and static analysis are mandatory before every major commit or release to maintain code quality and consistency.

## 11. Refactor Hygiene

Any rename or modularisation must include a project-wide update of all references and documentation. No legacy or obsolete references are permitted after a refactor to ensure clarity and maintainability.

## 12. Error Handling and User Experience

All error messages must be clear, actionable, and remain visible until acknowledged by the user. All catch blocks must end with a user acknowledgement prompt unless handled globally. Error handling must include context such as script name, operation, and error details.

## 13. Accessible Output and Documentation

All user-facing output and documentation must use EN-AU spelling and accessible, inclusive language to ensure understanding and usability for all users.

## 14. Session Validation

After any connection attempt, session validity must be confirmed before proceeding with operations. If the session is not valid, operations must be skipped with clear messaging to avoid confusion and ensure proper error handling.
