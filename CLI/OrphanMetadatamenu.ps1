<#
.SYNOPSIS
    Orphan and metadata management menu for OfficeSpaceManager CLI.
.DESCRIPTION
    Provides interactive options for finding/fixing orphaned resources, validating desk pool mappings, detecting non-standard resource names, and suggesting renames. All output uses inclusive, accessible language and EN-AU spelling.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

. (Join-Path $PSScriptRoot '..\Modules\Utilities\Resolve-OfficeSpaceManagerRoot.ps1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\CLI\CLI.psm1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\Logging\Logging.psm1')
Display-PanelHeader -Title "Orphan & Metadata Management"

Write-Host "[1] Find Orphaned Resources"
Write-Host "[2] Fix Orphaned Resources"
Write-Host "[3] Validate Desk Pool Mappings"
Write-Host "[4] Detect Non-Standard Resource Names"
Write-Host "[5] Suggest and Apply Renames"
Write-Host "[6] Return to Main Menu"

$choice = Read-Host "`nSelect an option"

switch ($choice) {
    '1' { . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\OrphanFixer\Find-OrphanedResources.ps1" }
    '2' { . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\OrphanFixer\Fix-OrphanedResources.ps1" }
    '3' { . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\OrphanFixer\Validate-DeskPoolMappings.ps1" }
    '4' { . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\OrphanFixer\Detect-NonStandardResources.ps1" }
    '5' { . "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\OrphanFixer\Suggest-RenameResource.ps1" }
    '6' { return }
}
