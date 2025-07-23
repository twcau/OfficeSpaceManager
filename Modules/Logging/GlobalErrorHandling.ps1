<#
.SYNOPSIS
    Global error handler for OfficeSpaceManager
.DESCRIPTION
    Ensures that consistent error handling, and associated logging, is implemented across all scripts.
#>

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
