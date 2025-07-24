<!-- omit from toc -->
# CLI Menu Tree

The following is a visual overview of all CLI menus and options within the tool, showing their relationships and purpose.

```plaintext
Main Menu
│
├─ 1. Manage Resources           # Create, edit, retire, simulate, and manage resources
│  │
│  ├─ 1. Create/Edit Resource    # Desk, Room, Equipment creation or editing
│  ├─ 2. Recover Failed Draft(s) # Recover incomplete resource drafts
│  ├─ 3. Retire/Reactivate       # Change resource state (active/retired)
│  ├─ 4. Booking Simulation      # Run booking simulation tests
│  ├─ 5. Create Desk Pool        # Create a new desk pool
│  ├─ 6. Manage Desk Pools       # Edit or manage desk pools
│  └─ 7. Return to Main Menu     # Go back to main menu
│
├─ 2. Orphan & Metadata Mgmt     # Find/fix orphaned resources, validate mappings, naming
│  │
│  ├─ 1. Find Orphaned Resources    # Detect resources not linked to metadata
│  ├─ 2. Fix Orphaned Resources     # Repair orphaned resources
│  ├─ 3. Validate Desk Pools        # Check desk pool mappings
│  ├─ 4. Detect Non-Standard Names  # Find resources with non-standard names
│  ├─ 5. Suggest/Apply Renames      # Suggest and apply resource renames
│  └─ 6. Return to Main Menu        # Go back to main menu
│
├─ 3. Configuration & Setup      # Import/export templates, manage sites/buildings/floors
│  │
│  ├─ 1. Import/Export Templates # Template operations
│  │  │
│  │  ├─ 1.1 Export All Templates   # Export all templates
│  │  ├─ 1.2 Validate Templates     # Validate template files
│  │  └─ 1.3 Import Templates       # Import validated templates
│  │
│  ├─ 2. Manage Sites/Buildings/Floors # Site/building/floor management
│  │  │
│  │  ├─ 2.1 Export Site/Building Templates # Export site/building templates
│  │  ├─ 2.2 Import Site/Building from CSV  # Import site/building from CSV
│  │  ├─ 2.3 View Structure                 # View current site/building structure
│  │  └─ 2.4 Return to Previous             # Go back to previous menu
│  │
│  ├─ 3. Sync Cloud Resources           # Sync cloud resources to local metadata
│  ├─ 4. Environment Setup & Validation # Setup and validate environment
│  ├─ 5. Config Backup/Restore          # Backup and restore configuration
│  ├─ 6. Backup & Templates             # Additional backup/template options
│  ├─ 7. First-Time Setup Wizard        # Run initial setup wizard
│  └─ 8. Return to Main Menu            # Go back to main menu
│
├─ 4. Metadata & Logs            # Manage metadata snapshots, logs, action history
│  │
│  ├─ 1. Save Metadata Snapshot     # Save current metadata state
│  ├─ 2. Restore Metadata Snapshot  # Restore metadata from snapshot
│  ├─ 3. View Today's Log           # Open today's log file
│  ├─ 4. View Previous Logs         # Open previous log files
│  ├─ 5. View Action History        # Show summary of recent actions
│  ├─ 6. Compress Old Logs          # Compress old log files
│  ├─ 7. Clear Old Logs             # Delete old logs (with caution)
│  └─ 8. Return to Main Menu        # Go back to main menu
│
├─ 5. First-Time Setup Wizard    # Run initial setup and validation
│
├─ 6. About, Help & Instructions # View help, documentation, and project info
│  │
│  ├─ 1. Project License         # View project license
│  ├─ 2. Documentation & Manual  # Open documentation site
│  ├─ 3. Project README.md       # View README on GitHub
│  ├─ 4. GitHub Repository       # Open GitHub repo
│  └─ X. Return to Main Menu     # Return to Main Menu
│
├─ 7. Exit                       # Exit the CLI, and perform backups of data and update local metadata.
```

> Each menu option is annotated with a brief description for clarity.
