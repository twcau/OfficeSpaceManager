<#
.SYNOPSIS
    Validates Microsoft Places features and Teams app pinning for OfficeSpaceManager.
.DESCRIPTION
    Imports the Configuration module and calls Validate-PlacesFeatures to check Places features and Teams app pinning. All output uses EN-AU spelling and accessible language.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

# Import Configuration module
Import-Module "$PSScriptRoot/../Modules/Configuration/Configuration.psm1" -Force

# Call the main function
Validate-PlacesFeatures
