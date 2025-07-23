<#
.SYNOPSIS
    Displays recent action history from the log file in OfficeSpaceManager CLI.
.DESCRIPTION
    Reads and displays the last 5 actions from today's log file in a formatted box. Uses EN-AU spelling and accessible output.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

. (Join-Path $PSScriptRoot '..\Modules\Utilities\Resolve-OfficeSpaceManagerRoot.ps1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\CLI\CLI.psm1')
