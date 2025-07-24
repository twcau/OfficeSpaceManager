<#
.SYNOPSIS
    Fixes orphaned resources in OfficeSpaceManager.
.DESCRIPTION
    Attempts to remediate or reassign orphaned resources to restore metadata integrity. Uses EN-AU spelling and accessible output.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>
Import-Module "$PSScriptRoot/../Modules/CLI/CLI.psm1"
Import-Module "$PSScriptRoot/../Modules/Logging/Logging.psm1"
function Repair-OrphanedResources {
    Get-PanelHeader -Title "Fix Orphaned Desks and Mailboxes"

    $metadataDesks = Get-Content ".\Metadata\DeskDefinitions.json" | ConvertFrom-Json
    $cache = Get-Content ".\Metadata\CachedResources.json" | ConvertFrom-Json

    $fixCandidates = $cache.Desks | Where-Object {
        -not ($metadataDesks | Where-Object { $_.ExchangeObjectId -eq $_.ExchangeObjectId })
    }

    if ($fixCandidates.Count -eq 0) {
        Write-Log -Message "No orphaned mailboxes to fix." -Level 'INFO'
        return
    }

    foreach ($orphan in $fixCandidates) {
        Write-Host "`n📬 [$($orphan.Alias)] - $($orphan.DisplayName)"
        $site = Read-Host "Assign Site Code"
        $building = Read-Host "Assign Building Code"
        $floor = Read-Host "Assign Floor Number"
        $deskNumber = Read-Host "Assign Desk Number"
        $deskId = "$site-$building-$floor-$deskNumber"

        $newDesk = @{
            DeskId           = $deskId
            DisplayName      = $orphan.DisplayName
            ExchangeObjectId = $orphan.ExchangeObjectId
            Email            = $orphan.Email
            SiteCode         = $site
            BuildingCode     = $building
            FloorNumber      = [int]$floor
            DeskNumber       = [int]$deskNumber
            Retired          = $false
        }

        $metadataDesks += $newDesk
        Write-Log -Message "Added new desk to metadata: $deskId" -Level 'INFO'
        Write-Log "Orphaned mailbox $($orphan.Alias) linked to $deskId"
    }

    $metadataDesks | ConvertTo-Json -Depth 5 | Set-Content ".\Metadata\DeskDefinitions.json"
    Write-Host "`n✅ Metadata updated with fixed orphans."
}
Repair-OrphanedResources
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host "Press Enter to continue..."
}
