<#
.SYNOPSIS
    Validates desk pool mappings in OfficeSpaceManager.
.DESCRIPTION
    Checks that all desk pool mappings are valid and consistent with metadata. Uses EN-AU spelling and accessible output.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>
Import-Module "$PSScriptRoot/../Modules/CLI/CLI.psm1"
Import-Module "$PSScriptRoot/../Modules/Logging/Logging.psm1"
function Validate-DeskPoolMappings {
    Display-PanelHeader -Title "Validate Desk Pool Mappings"

    $desks = Get-Content ".\Metadata\DeskDefinitions.json" | ConvertFrom-Json
    $pools = Get-Content ".\Metadata\DeskPools.json" | ConvertFrom-Json

    foreach ($pool in $pools) {
        foreach ($memberId in $pool.Members) {
            $match = $desks | Where-Object { $_.DeskId -eq $memberId }
            if (-not $match) {
                Write-Log -Message "Pool [$($pool.PoolName)] references non-existent desk: $memberId" -Level 'WARN'
            }
        }
    }

    Write-Log -Message "Desk pool mapping validation complete." -Level 'INFO'
    Write-Log "Validated desk pool mappings"
}
Validate-DeskPoolMappings
