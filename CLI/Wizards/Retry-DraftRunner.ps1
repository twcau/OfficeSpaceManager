. "$PSScriptRoot/../../Shared/Global-ErrorHandling.ps1"
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
    Write-Host "🎉 No draft resources found to recover." -ForegroundColor Green
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

    # Password generator inline
    function New-SecurePassword {
        $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%^&*'
        do {
            $pwd = -join ((65..90)+(97..122)+(48..57)+33..47 | Get-Random -Count 14 | ForEach-Object {[char]$_})
        } while (
            $pwd -notmatch '[A-Z]' -or
            $pwd -notmatch '[a-z]' -or
            $pwd -notmatch '[0-9]' -or
            $pwd -notmatch '[\!\@\#\$\%\^\&\*]' -or
            $pwd -match '(.)\1{2,}' -or
            $pwd -match '(012|123|234|345|456|567|678|789)'
        )
        return $pwd
    }

    $securePwd = (New-SecurePassword) | ConvertTo-SecureString -AsPlainText -Force

    Write-Host "📦 Retrying Exchange provisioning for: $($resource.DisplayName)" -ForegroundColor Cyan

    # Check if already exists again
    $existing = Get-Mailbox -Identity $upn -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "⚠️ Mailbox already exists in Exchange. Skipping creation." -ForegroundColor Yellow
    } else {
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
        Identity     = $upn
        Building     = $resource.BuildingCode
        FloorLabel   = $resource.FloorName
        FloorNumber  = $resource.FloorNumber
    }

    if ($resourceType -eq 'desk') {
        if ($resource.IsAccessible -eq 'Y') { $placeParams['IsWheelChairAccessible'] = $true }
        if ($resource.IsHeightAdjustable -eq 'Y') { $placeParams['IsHeightAdjustable'] = $true }
        if ($resource.HasDockingStation -eq 'Y') { $placeParams['HasDockingStation'] = $true }
        $placeParams['DeskNumber'] = $resource.DeskNumber
    }

    Set-Place @placeParams

    Write-Host "✅ Retry successful. Updating metadata and cleaning up draft..." -ForegroundColor Green

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
    Write-Host "🧹 Draft cleaned up."

    # Optionally offer simulation test
    $runTest = Read-Host "Run booking simulation now? (Y/N)"
    if ($runTest -eq 'Y') {
        . "$PSScriptRoot\TestSuite\Simulate-BookingTest.ps1" -Alias $alias -Domain $domain
    }

} catch {
    Write-Warning "❌ Retry failed: $_"
    Write-Host "Draft preserved: $($selected.FullName)"
}

