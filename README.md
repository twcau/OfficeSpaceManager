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
- [🧪 Running Tests](#-running-tests)
- [🔁 Backup \& Restore](#-backup--restore)
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

A more detailed explaination to the working approach for this project can be found in [IDEA](https://twcau.github.io/OfficeSpaceManager/project-overview/idea/) and [SPECIFICATION](https://twcau.github.io/OfficeSpaceManager/project-overview/specification/).

---

## 🛡 Design Philosophy

See [Design Philosophy](https://twcau.github.io/OfficeSpaceManager/project-overview/design-philosophy/).

---

## 🚀 Features

For full list, see [Features](https://twcau.github.io/OfficeSpaceManager/#features).

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
- ✅ **All connection routines are robust, session-reusing, and provide clear diagnostic output for Exchange, Teams, and Places.**
- ✅ **All cmdlets and scripts use approved PowerShell verbs for discoverability and linter compliance.**
- ✅ **Project is fully linted with PSScriptAnalyzer; all code changes validated for compliance.**

---

## 🔧 Requirements

See [Requirements](https://twcau.github.io/OfficeSpaceManager/user-guides/getting-started/requirements/).

---

## 🧠 Usage

1. Clone the repo:

    ```terminal
    git clone https://github.com/twcau/OfficeSpaceManager
    cd OfficeSpaceManager
    ```

2. Open PowerShell 7+

3. Navigate to the folder

4. Run:

    ```powershell
    .\Invoke-MainMenu.ps1 [-LogVerbose]
    ```

   - The optional `-LogVerbose` flag enables full session transcript and input logging to `Logs/TerminalVerbose`.
   - On first run, you will be guided through robust first-time setup and Exchange Online connection. All errors require user acknowledgement and are logged.

---

## 📁 Folder Structure

WARNING: Due to continued development, this is subject to change.

See [Folder Structure](https://twcau.github.io/OfficeSpaceManager/project-overview/folder-structure/).

---

## 🧪 Running Tests

See [Running Tests](https://twcau.github.io/OfficeSpaceManager/user-guides/testing/).

---

## 🔁 Backup & Restore

For more infomation, see [Running Tests](https://twcau.github.io/OfficeSpaceManager/user-guides/testing/).

---

## 🔗 Useful Microsoft Docs

- [Microsoft Places Overview](https://learn.microsoft.com/microsoft-places/)
- [Microsoft Graph Places API](https://learn.microsoft.com/graph/api/resources/place?view=graph-rest-1.0)
- [Exchange Room Mailbox Docs](https://learn.microsoft.com/exchange/recipients/room-mailboxes)
- [Set-CalendarProcessing](https://learn.microsoft.com/powershell/module/exchange/set-calendarprocessing)

---

## 🙋 Support

See [Support](https://twcau.github.io/OfficeSpaceManager/support/).

---

## 🔐 Data Safety

See [Data Safety](https://twcau.github.io/OfficeSpaceManager/project-overview/data-safety/)

---

## 🔧 TODO

See [TODO](https://twcau.github.io/OfficeSpaceManager/issues/todo/) and [Known Issues](https://twcau.github.io/OfficeSpaceManager/issues/knownissues/).

---

## 📘 License & Credits

> OfficeSpaceManager – Internal Admin Toolkit
> © 2025 – Michael Harris. Use it well.
> Built with PowerShell for Microsoft 365 tenants

See [LICENSE](LICENSE) for further information.
