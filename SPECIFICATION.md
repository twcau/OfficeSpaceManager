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
