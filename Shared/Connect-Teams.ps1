. "$PSScriptRoot/Global-ErrorHandling.ps1"
function Connect-TeamsService {
    if (-not (Get-Module MicrosoftTeams)) {
        Import-Module MicrosoftTeams -ErrorAction Stop
    }

    # Check existing session
    try {
        $details = Get-CsTenant -ErrorAction Stop
        Write-Host "🔐 Already connected to Microsoft Teams." -ForegroundColor Green
        Write-Log "Reused Teams session."
        return $true
    } catch {
        # Fall through to fresh login
    }

    # New connection
    try {
        Connect-MicrosoftTeams
        Write-Host "🔐 Connected to Microsoft Teams." -ForegroundColor Green
        Write-Log "Connected to Microsoft Teams."
        return $true
    } catch {
        Write-Warning "❌ Microsoft Teams connection failed: $($_.Exception.Message)"
        return $false
    }
}
