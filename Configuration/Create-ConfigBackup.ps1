<#
.SYNOPSIS
    Creates a ZIP backup of key configuration, metadata, and log files for OfficeSpaceManager.
.DESCRIPTION
    Imports the Configuration module and calls New-ConfigBackup to generate a timestamped backup archive. All output uses EN-AU spelling and accessible language.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

# Import Configuration module
Import-Module "$PSScriptRoot/../Modules/Configuration/Configuration.psm1" -Force

# Call the main function
New-ConfigBackup
