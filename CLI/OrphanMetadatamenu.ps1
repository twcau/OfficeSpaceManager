Render-PanelHeader -Title "Orphan & Metadata Management"

Write-Host "[1] Find Orphaned Resources"
Write-Host "[2] Fix Orphaned Resources"
Write-Host "[3] Validate Desk Pool Mappings"
Write-Host "[4] Detect Non-Standard Resource Names"
Write-Host "[5] Suggest and Apply Renames"
Write-Host "[6] Return to Main Menu"

$choice = Read-Host "`nSelect an option"

switch ($choice) {
    '1' { . "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\OrphanFixer\Find-OrphanedResources.ps1" }
    '2' { . "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\OrphanFixer\Fix-OrphanedResources.ps1" }
    '3' { . "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\OrphanFixer\Validate-DeskPoolMappings.ps1" }
    '4' { . "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\OrphanFixer\Detect-NonStandardResources.ps1" }
    '5' { . "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\OrphanFixer\Suggest-RenameResource.ps1" }
    '6' { return }
}
