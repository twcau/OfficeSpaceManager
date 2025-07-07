Render-PanelHeader -Title "Orphan & Metadata Management"

Write-Host "[1] Find Orphaned Resources"
Write-Host "[2] Fix Orphaned Resources"
Write-Host "[3] Validate Desk Pool Mappings"
Write-Host "[4] Detect Non-Standard Resource Names"
Write-Host "[5] Suggest and Apply Renames"
Write-Host "[6] Return to Main Menu"

$choice = Read-Host "`nSelect an option"

switch ($choice) {
    '1' { . "$PSScriptRoot\..\OrphanFixer\Find-OrphanedResources.ps1" }
    '2' { . "$PSScriptRoot\..\OrphanFixer\Fix-OrphanedResources.ps1" }
    '3' { . "$PSScriptRoot\..\OrphanFixer\Validate-DeskPoolMappings.ps1" }
    '4' { . "$PSScriptRoot\..\OrphanFixer\Detect-NonStandardResources.ps1" }
    '5' { . "$PSScriptRoot\..\OrphanFixer\Suggest-RenameResource.ps1" }
    '6' { return }
}