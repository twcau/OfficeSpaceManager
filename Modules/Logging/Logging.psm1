<#
.SYNOPSIS
    Logging module for OfficeSpaceManager: centralised logging and error handling utilities.
.DESCRIPTION
    Provides Write-Log and global error handling for all modules and scripts. Ensures consistent, timestamped logging and error capture across the project.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>
# Logging.psm1
. $PSScriptRoot\Logging.ps1
. $PSScriptRoot\GlobalErrorHandling.ps1
Export-ModuleMember -Function Write-Log
