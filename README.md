# 🏢 OfficeSpaceManager

A modular PowerShell CLI toolkit to establish a simple, and logical workflow from a single place to establish and manage Microsoft Places, Exchange Room Resources, and Metadata across Microsoft 365 environments.

WARNING: This repository is still under major initial development, and should be considered 'Extreme Alpha'. Any use of this repository is at your own risk knowing there will be continued and ongoing changes underway.

---

## 🚀 Features

- ✅ Interactive CLI with modular submenus
- ✅ Automated first-time tenant setup
- ✅ Resource provisioning (Desk / Room / Equipment)
- ✅ Metadata and site structure management, and local caching of information for speed
- ✅ CSV template export/import for bulk editing of sites, buildings, floors, desks, desk pools, etc.
- ✅ Logging, draft recovery, and error handling
- ✅ Simulation test suite with cleanup tools
- ✅ Auto-discovery of domains + validation of Exchange & Places configurations to support
- ✅ Exchange Online + Microsoft Graph Places + Microsoft Teams integration
- ✅ Uses native functions within existing PowerShell modules wherever possible
- ✅ Backup and restore features, to enable complete download and upload of your configuration

---

## 🔧 Requirements

- PowerShell 7.0+
- Modules:
  - `ExchangeOnlineManagement`
  - `Microsoft.Graph`
  - `MicrosoftTeams`

> All required modules are validated as present, or installed at runtime.

---

## 🧠 Usage

1. Open PowerShell 7+

2. Navigate to the folder

3. Run:

```powershell
.\Invoke-MainMenu.ps1
```

You’ll be guided through first-time setup if it's your first run.

---

## 📁 Folder Structure

WARNING: Due to the continued development, this is subject to change.

```plaintext
OfficeSpaceManager\
│
├── Invoke-MainMenu.ps1           # 🔧 Entry point to CLI
├── README.md                     # 📘 This file
│
├── CLI\                           # Menus and UI entry points
│   ├── ConfigurationMenu.ps1
│   ├── LogsMenu.ps1
│   ├── ManageResourcesMenu.ps1
│   ├── OrphanMetadataMenu.ps1
│   ├── Render-PanelHeader.ps1
│   ├── Show-ActionHistory.ps1
│   ├── Wizards\
│   │   ├── Create-DeskPoolWizard.ps1
│   │   ├── Manage-DeskPools.ps1
│   │   ├── Manage-ResourceWizard.ps1
│   │   ├── Retry-DraftRunner.ps1
│
├── Configuration\                # Config validation and setup flows
│   ├── Create-ConfigBackup.ps1
│   ├── Enable-PlacesFeatures.ps1
│   ├── Restore-ConfigBackup.ps1
│   ├── Run-FirstTimeSetup.ps1
│   ├── Validate-ExchangeSetup.ps1
│   ├── Validate-PlacesFeatures.ps1
│
├── EnvironmentSetup\             # Microsoft 365 mailbox and calendar config
│   ├── Ensure-CalendarProcessingSettings.ps1
│   ├── Pin-PlacesAppInTeams.ps1
│   ├── Update-MailboxTypes.ps1
│
├── Imports\                      # Post-CSV import handling
│   ├── Import-SiteStructureFromCSV.ps1
│   ├── Import-DeskPoolsFromCSV.ps1
│   ├── Import-ResourcesFromCSV.ps1
│
├── Logs\                         # Logging history, export, cleanup
│   ├── Clear-LogHistory.ps1
│   ├── Compress-Logs.ps1
│   ├── Export-ActionHistory.ps1
│   ├── View-LogHistory.ps1
│
├── Metadata\                     # Primary system metadata
│   ├── BuildingDefinitions.json
│   ├── CachedResources.json
│   ├── DeskDefinitions.json
│   ├── DeskPools.json
│   ├── Floors.json
│   ├── Pathways.json
│   ├── SiteDefinitions.json
│
├── OrphanFixer\                  # Tools for resolving orphan objects
│   ├── Detect-NonStandardResources.ps1
│   ├── Identify-OrphanedDesks.ps1
│   ├── Reconcile-OrphanedDesks.ps1
│
├── Shared\                       # Reusable logic functions
│   ├── Get-StandardDeskName.ps1
│   ├── Render-PanelHeader.ps1
│   ├── Write-Log.ps1
│
├── SiteManagement\               # Metadata sync + site structure ops
│   ├── CachedResources\
│   │   └── Refresh-CachedResources.ps1
│   ├── Export-SiteStructureTemplates.ps1
│   ├── Import-SiteStructureFromCSV.ps1
│   ├── List-SiteStructure.ps1
│   ├── Sync-MetadataToCloud.ps1
│
├── TemplateManagement\           # Import/export CSV metadata templates
│   ├── Export-AllTemplates.ps1
│   ├── Import-FromCSV.ps1
│   ├── Validate-CSVImport.ps1
│
├── TestSuite\                    # Safe simulation of provisioning logic
│   ├── Cleanup-TestResources.ps1
│   ├── Run-BookingSimulation.ps1
│   ├── Run-TestSuite.ps1
│   ├── Simulate-BookingTest.ps1
│   ├── Test-DeskProvisioning.ps1
│   ├── Test-MailboxSettings.ps1
│   ├── Test-RoomProvisioning.ps1
│
├── .Drafts\                      # Stored failed/draft resource objects
│
├── config\                       # TenantConfig.json + first-run flags
    ├── FirstRunComplete.json
    ├── TenantConfig.json

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

```
\TestResults\
```

---

## 🔁 Backup & Restore

### Save current metadata snapshot:

From the menu:

```
Main Menu > Metadata & Logs > Save Metadata Snapshot
```

Or run manually:

```powershell
.\Backups\Save-MetadataSnapshot.ps1
```

### Restore from snapshot:

```powershell
.\Backups\Restore-MetadataSnapshot.ps1
```

You can also use:

```powershell
.\Configuration\Create-ConfigBackup.ps1
.\Configuration\Restore-ConfigBackup.ps1
```

To create/import a full `.zip` archive of your working config.

---

## 🔗 Useful Microsoft Docs

- [Microsoft Places Overview](https://learn.microsoft.com/microsoft-places/)
- [Microsoft Graph Places API](https://learn.microsoft.com/graph/api/resources/place?view=graph-rest-1.0)
- [Exchange Room Mailbox Docs](https://learn.microsoft.com/exchange/recipients/room-mailboxes)
- [Set-CalendarProcessing](https://learn.microsoft.com/powershell/module/exchange/set-calendarprocessing)

---

## 🛡 Design Philosophy

- 💾 **Soft-deletion only** — desks and rooms are never fully deleted
- 💡 **Pre-validation of all inputs**
- 📦 **Reversible operations** — metadata snapshots, test cleanup
- 🔒 **Never destroys without confirmation**

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

## 📘 License & Credits

> OfficeSpaceManager – Internal Admin Toolkit  
> Built with PowerShell for Microsoft 365 tenants

© 2025 – Michael Harris. Use it well.