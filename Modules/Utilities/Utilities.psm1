<#
.SYNOPSIS
    Shared utility and connection functions for OfficeSpaceManager.
.DESCRIPTION
    Provides helper functions for naming, and connection logic for Exchange, Graph, and Teams. Used by multiple modules and scripts. Ensures all utility logic is modular, maintainable, and auditable.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

# Utilities.psm1
# Shared utility and connection functions for OfficeSpaceManager

function Get-StandardDeskName {
    <#
    .SYNOPSIS
        Generate a standardised desk name string.
    .DESCRIPTION
        Returns a formatted desk name using site, building, floor, and desk number.
    .PARAMETER SiteCode
        [string] Site code (e.g., "SYD").
    .PARAMETER Building
        [string] Building name or code.
    .PARAMETER Floor
        [string] Floor identifier.
    .PARAMETER DeskNumber
        [int] Desk number.
    .EXAMPLE
        Get-StandardDeskName -SiteCode "SYD" -Building "A" -Floor "3" -DeskNumber 12
    .OUTPUTS
        [string] Standardised desk name.
    #>
    param (
        [Parameter(Mandatory)][string]$SiteCode,
        [Parameter(Mandatory)][string]$Building,
        [Parameter(Mandatory)][string]$Floor,
        [Parameter(Mandatory)][int]$DeskNumber
    )
    $formatted = "{0}-{1}-L{2}-D{3:000}" -f $SiteCode.ToUpper(), $Building.ToUpper(), $Floor, $DeskNumber
    return $formatted
}

Export-ModuleMember -Function Get-StandardDeskName
