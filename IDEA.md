# 💡 Project Idea: OfficeSpaceManager

OfficeSpaceManager is a modular, production-grade PowerShell CLI toolkit designed to simplify and centralise the management of Microsoft Places, Exchange Room Resources, and associated metadata across Microsoft 365 environments. The project aims to provide a single, logical workflow for administrators to set up, maintain, and recover their environment, reducing the need to navigate multiple admin portals or scripts.

## Vision & Rationale

- **Centralised Management:** Eliminate fragmented admin experiences by providing a unified CLI for all resource and metadata operations.
- **Automation & Consistency:** Enable bulk operations (import/export), enforce naming conventions, and automate repetitive tasks to reduce errors and manual effort.
- **Disaster Recovery:** Provide robust backup and restore capabilities for both configuration and metadata, ensuring business continuity.
- **Extensibility:** Use a modular structure to allow easy addition of new features, domains, and integrations as Microsoft 365 evolves.
- **User Experience:** Make the job of a Microsoft Modern Workplace analyst/engineer easier, faster, and less error-prone.

## Why This Project?

- Manual management of Microsoft Places, Exchange resources, and metadata is time-consuming and error-prone.
- Existing tools are fragmented, lack bulk/batch features, and often require deep technical knowledge.
- There is a need for a repeatable, auditable, and recoverable workflow for resource management in Microsoft 365 environments.

## Intended Audience

- Microsoft 365 administrators, Modern Workplace engineers, and IT professionals responsible for resource and metadata management.

## Key Technical Principles and Recent Improvements

- **Robust Connection Logic:**
  Connection routines are designed to be resilient, with session reuse, robust error handling, and clear diagnostic output for all Microsoft 365 services (Exchange, Teams, Places).
- **Approved Verb Compliance:**
  All cmdlets and scripts use approved PowerShell verbs, ensuring best practice, discoverability, and compatibility with PowerShell tooling.
- **Linting and Static Analysis:**
  Linting and static analysis are integrated into the workflow, with PSScriptAnalyzer used to ensure code quality and prevent regressions.
- **Refactor Hygiene:**
  All refactors and renames are performed project-wide, with automated updates to all references and documentation to prevent legacy issues.
- **Accessible and Inclusive Output:**
  All output and documentation use EN-AU spelling and accessible, inclusive language for clarity and compliance.
- **Error Handling and User Experience:**
  Error handling is standardised, with actionable messages and prompts that remain visible until acknowledged, ensuring no errors are missed.

## Project Ideas

- Automated resource provisioning for Microsoft Places
- Bulk import/export of metadata
- Robust backup and restore
- Modular CLI for all operations
