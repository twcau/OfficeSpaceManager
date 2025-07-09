. "$PSScriptRoot/Global-ErrorHandling.ps1"
<#
.SYNOPSIS
    Generates a standardized desk name using site/building/floor/numbering.
.DESCRIPTION
    Helps enforce naming conventions across automated provisioning.
#>

function Get-StandardDeskName {
    param (
        [Parameter(Mandatory)][string]$SiteCode,
        [Parameter(Mandatory)][string]$Building,
        [Parameter(Mandatory)][string]$Floor,
        [Parameter(Mandatory)][int]$DeskNumber
    )

    $formatted = "{0}-{1}-L{2}-D{3:000}" -f $SiteCode.ToUpper(), $Building.ToUpper(), $Floor, $DeskNumber
    return $formatted
}
