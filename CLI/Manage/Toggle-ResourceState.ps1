Import-Module "$PSScriptRoot/../../Modules/CLI/CLI.psm1"
. "$PSScriptRoot/../../Shared/Global-ErrorHandling.ps1"
Display-PanelHeader -Title "Retire or Reactivate Resource"

$resourceType = Read-Host "What type of resource? (Desk, Room, Equipment)"
$resourceType = $resourceType.Trim().ToLower()

if ($resourceType -notin @('desk', 'room', 'equipment')) {
Write-Log -Message "Invalid type." -Level 'ERROR'
    return
}

$metadataPath = ".\Metadata"
switch ($resourceType) {
    'desk'      { $file = "$metadataPath\DeskDefinitions.json" }
    'room'      { $file = "$metadataPath\Rooms.json" }
    'equipment' { $file = "$metadataPath\Equipment.json" }
}

if (-not (Test-Path $file)) {
Write-Log -Message "No $resourceType data file found." -Level 'WARN'
    return
}

$data = Get-Content $file | ConvertFrom-Json
$selected = $data | Out-GridView -Title "Select $resourceType to retire/reactivate" -PassThru
if (-not $selected) { return }

$selected.IsRetired = -not ($selected.IsRetired -eq $true)
$status = $selected.IsRetired ? "retired" : "re-activated"

$data = $data | Where-Object { $_.Alias -ne $selected.Alias }
$data += $selected
$data | ConvertTo-Json -Depth 8 | Set-Content $file

Write-Log -Message "resourceType '$($selected.DisplayName)' is now $status." -Level 'INFO'
Write-Log "$resourceType '$($selected.DisplayName)' set to $status."
