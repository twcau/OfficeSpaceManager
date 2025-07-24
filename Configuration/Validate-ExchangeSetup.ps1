<#
.SYNOPSIS
    Validates Exchange resource setup and metadata for OfficeSpaceManager.
.DESCRIPTION
    Imports the Configuration module and calls Validate-ExchangeSetup to check Exchange resources. All output uses EN-AU spelling and accessible language.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

# Load Shared Connection Logic
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Logging/Logging.psm1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Utilities/Utilities.psm1')
# Import Connections module for robust service connections
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Connections/Connections.psm1') -Force

$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    return
}

# Import Configuration module
Import-Module "$PSScriptRoot/../Modules/Configuration/Configuration.psm1" -Force

# Call the main function
Validate-ExchangeSetup




