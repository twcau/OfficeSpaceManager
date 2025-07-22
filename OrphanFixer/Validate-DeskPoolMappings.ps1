. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
function Validate-DeskPoolMappings {
    Render-PanelHeader -Title "Validate Desk Pool Mappings"

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
