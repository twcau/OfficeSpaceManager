. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
function Fix-OrphanedResources {
    Render-PanelHeader -Title "Fix Orphaned Desks and Mailboxes"

    $metadataDesks = Get-Content ".\Metadata\DeskDefinitions.json" | ConvertFrom-Json
    $cache = Get-Content ".\Metadata\CachedResources.json" | ConvertFrom-Json

    $fixCandidates = $cache.Desks | Where-Object {
        -not ($metadataDesks | Where-Object { $_.ExchangeObjectId -eq $_.ExchangeObjectId })
    }

    if ($fixCandidates.Count -eq 0) {
        Write-Host "✅ No orphaned mailboxes to fix."
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
            DeskId             = $deskId
            DisplayName        = $orphan.DisplayName
            ExchangeObjectId   = $orphan.ExchangeObjectId
            Email              = $orphan.Email
            SiteCode           = $site
            BuildingCode       = $building
            FloorNumber        = [int]$floor
            DeskNumber         = [int]$deskNumber
            Retired            = $false
        }

        $metadataDesks += $newDesk
        Write-Host "✔️ Added new desk to metadata: $deskId"
        Write-Log "Orphaned mailbox $($orphan.Alias) linked to $deskId"
    }

    $metadataDesks | ConvertTo-Json -Depth 5 | Set-Content ".\Metadata\DeskDefinitions.json"
    Write-Host "`n✅ Metadata updated with fixed orphans."
}
Fix-OrphanedResources
