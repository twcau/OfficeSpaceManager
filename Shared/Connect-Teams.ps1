. "$PSScriptRoot/Global-ErrorHandling.ps1"
function Connect-TeamsService {
    if (-not (Get-Module MicrosoftTeams)) {
        Import-Module MicrosoftTeams -ErrorAction Stop
    }

    # Check existing session
    try {
        $details = Get-CsTenant -ErrorAction Stop
Write-Log -Message "Already connected to Microsoft Teams." -Level 'INFO'
        Write-Log "Reused Teams session."
        return $true
    } catch {
        # Fall through to fresh login
    }

    # New connection
    try {
        Connect-MicrosoftTeams
Write-Log -Message "Connected to Microsoft Teams." -Level 'INFO'
        Write-Log "Connected to Microsoft Teams."
        return $true
    } catch {
Write-Log -Message "Microsoft Teams connection failed: $($_.Exception.Message)" -Level 'WARN'
        return $false
    }
}
