<#
.SYNOPSIS
    Enables Microsoft Places features in the tenant for OfficeSpaceManager.
.DESCRIPTION
    Imports the Configuration module and calls Enable-PlacesFeatures to enable Places features. All output uses EN-AU spelling and accessible language.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>
. (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Logging/GlobalErrorHandling.ps1')
# Import Configuration module
Import-Module "$PSScriptRoot/../Modules/Configuration/Configuration.psm1" -Force

# Call the main function
Enable-PlacesFeatures
