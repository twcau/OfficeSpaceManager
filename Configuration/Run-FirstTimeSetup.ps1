<#
.SYNOPSIS
    Runs the first-time setup wizard for OfficeSpaceManager.
.DESCRIPTION
    Imports the Configuration module and calls Invoke-FirstTimeSetup to guide the user through initial environment setup. All output uses EN-AU spelling and accessible language.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

# Load Shared Connection Logic
Import-Module "$PSScriptRoot/../Modules/Logging/Logging.psm1"
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    return
}

Import-Module "$PSScriptRoot/../Modules/CLI/CLI.psm1"

# Import Configuration module
Import-Module "$PSScriptRoot/../Modules/Configuration/Configuration.psm1" -Force

# Call the main function
Invoke-FirstTimeSetup




