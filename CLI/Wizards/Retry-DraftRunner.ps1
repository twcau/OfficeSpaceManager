<#
.SYNOPSIS
    Wizard for recovering failed or draft resource objects in OfficeSpaceManager.
.DESCRIPTION
    Guides the user through the process of retrying or recovering failed/draft resource objects. Uses EN-AU spelling and accessible output.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

Import-Module "$PSScriptRoot/../../Modules/CLI/CLI.psm1"
. (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Logging/GlobalErrorHandling.ps1')
<#
.SYNOPSIS
    Retry creation of failed resources saved as JSON drafts.
.DESCRIPTION
    Lists all failed draft files from .\Drafts\ folder, lets the user select one, 
    re-attempts Exchange and Places creation, and cleans up on success.
#>

$draftFolder = ".\.Drafts"
$files = Get-ChildItem -Path $draftFolder -Filter *.json -ErrorAction SilentlyContinue

if (-not $files) {
    Write-Log -Message "No draft resources found to recover." -Level 'INFO'
    return
}

$selected = $files | Out-GridView -Title "Select Draft to Retry" -PassThru
if (-not $selected) { return }

try {
    $resource = Get-Content $selected.FullName | ConvertFrom-Json
    $alias = $resource.Alias
    $domain = $resource.Domain
    $upn = "$alias@$domain"
    $resourceType = $resource.ObjectType

    # Use module version of New-SecurePassword
    $securePwd = (New-SecurePassword) | ConvertTo-SecureString -AsPlainText -Force

    Write-Log -Message "Retrying Exchange provisioning for: $($resource.DisplayName)" -Level 'INFO'

    # Check if already exists again
    $existing = Get-Mailbox -Identity $upn -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Log -Message "Mailbox already exists in Exchange. Skipping creation." -Level 'WARN'
    }
    else {
        New-Mailbox -Name $resource.DisplayName `
            -Alias $resource.Alias `
            -DisplayName $resource.DisplayName `
            -MicrosoftOnlineServicesID $upn `
            -Room `
            -EnableRoomMailboxAccount $true `
            -RoomMailboxPassword $securePwd

        Set-Mailbox -Identity $upn -Type Room
    }

    # Set Places attributes
    $placeParams = @{
        Identity    = $upn
        Building    = $resource.BuildingCode
        FloorLabel  = $resource.FloorName
        FloorNumber = $resource.FloorNumber
    }

    if ($resourceType -eq 'desk') {
        if ($resource.IsAccessible -eq 'Y') { $placeParams['IsWheelChairAccessible'] = $true }
        if ($resource.IsHeightAdjustable -eq 'Y') { $placeParams['IsHeightAdjustable'] = $true }
        if ($resource.HasDockingStation -eq 'Y') { $placeParams['HasDockingStation'] = $true }
        $placeParams['DeskNumber'] = $resource.DeskNumber
    }

    Set-Place @placeParams

    Write-Log -Message "Retry successful. Updating metadata and cleaning up draft..." -Level 'INFO'

    # Save into metadata
    $metadataPath = ".\Metadata\$($resourceType)s.json"
    $existingData = @()
    if (Test-Path $metadataPath) {
        $existingData = Get-Content $metadataPath | ConvertFrom-Json
    }
    $existingData = $existingData | Where-Object { $_.Alias -ne $alias }
    $existingData += $resource
    $existingData | ConvertTo-Json -Depth 8 | Set-Content $metadataPath

    # Remove draft
    Remove-Item $selected.FullName -Force
    Write-Log -Message "Draft cleaned up." -Level 'INFO'

    # Optionally offer simulation test
    $runTest = Read-Host "Run booking simulation now? (Y/N)"
    if ($runTest -eq 'Y') {
        . (Join-Path $env:OfficeSpaceManagerRoot 'TestSuite/Simulate-BookingTest.ps1') -Alias $alias -Domain $domain
    }

}
catch {
    Write-Log -Message "Retry failed: $_" -Level 'WARN'
    Write-Log -Message "Draft preserved: $($selected.FullName)" -Level 'INFO'
}

