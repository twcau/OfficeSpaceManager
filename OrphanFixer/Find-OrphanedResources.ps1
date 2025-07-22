. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
function Find-OrphanedResources {
    Render-PanelHeader -Title "Orphaned Resource Detection"

    $cache = Get-Content ".\Metadata\CachedResources.json" | ConvertFrom-Json
    $metadataDesks = Get-Content ".\Metadata\DeskDefinitions.json" | ConvertFrom-Json

    $orphanedMailboxes = $cache.Desks | Where-Object {
        $mbId = $_.ExchangeObjectId
        -not ($metadataDesks | Where-Object { $_.ExchangeObjectId -eq $mbId })
    }

    $orphansMetadata = $metadataDesks | Where-Object {
        -not $_.ExchangeObjectId -or
        -not ($cache.Desks | Where-Object { $_.DeskId -eq $_.DeskId })
    }

    Write-Host "`n🔍 Orphaned Desks (in Metadata but not Exchange): $($orphansMetadata.Count)"
    $orphansMetadata | ForEach-Object {
Write-Log -Message "DeskId: $($_.DeskId) – Missing ExchangeObjectId" -Level 'INFO'
    }

    Write-Host "`n🔍 Orphaned Mailboxes (Exchange resources not in metadata): $($orphanedMailboxes.Count)"
    $orphanedMailboxes | ForEach-Object {
Write-Log -Message "Alias) – $($_.DisplayName)" -Level 'INFO'
    }

    Write-Log "Orphan detection completed"
}
Find-OrphanedResources
