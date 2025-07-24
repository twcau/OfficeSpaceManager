<#
.SYNOPSIS
    Finds orphaned resources in OfficeSpaceManager.
.DESCRIPTION
    Identifies resources that are not mapped or referenced in metadata. Uses EN-AU spelling and accessible output.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>
Import-Module "$PSScriptRoot/../Modules/CLI/CLI.psm1"
Import-Module "$PSScriptRoot/../Modules/Logging/Logging.psm1"
function Find-OrphanedResources {
    Get-PanelHeader -Title "Orphaned Resource Detection"

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
