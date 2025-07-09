<#
.SYNOPSIS
    Global error handler for OfficeSpaceManager
.DESCRIPTION
    Ensures that consistent error handling, and associated logging, is implimented across all scripts.
.LASTUPDATED
    2025-07-09
#>

# region ⚠️ Global Error Handling
# Dot-source the logging function
. "$PSScriptRoot\Write-Log.ps1"

if (-not $Global:OSM_ErrorTrapLoaded) {
    $Global:OSM_ErrorTrapLoaded = $true

    $ErrorActionPreference = 'Stop'

    trap {
        $scriptName = $MyInvocation.MyCommand.Path
        Write-Host "`n⚠️ Non-fatal error in ${scriptName}: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Log -Message "Non-fatal error in ${scriptName}: $($_.Exception.Message)"
        Read-Host "Press Enter to continue..."
        continue
    }
}
# endregion