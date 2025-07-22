. "$PSScriptRoot/Global-ErrorHandling.ps1"
function Connect-Graph {
    if (-not (Get-Module Microsoft.Graph)) {
        Import-Module Microsoft.Graph -ErrorAction Stop
    }

    # Reuse session if already connected
    try {
        $ctx = Get-MgContext
        if ($ctx.Account) {
Write-Log -Message "Already connected to Microsoft Graph as: $($ctx.Account)" -Level 'INFO'
            Write-Log "Graph connection reused: $($ctx.Account)"
            return $ctx.Account
        }
    } catch {
        # Fall through
    }

    # Fresh login
    try {
        Connect-MgGraph -Scopes "User.Read.All", "Place.Read.All"
        $ctx = Get-MgContext
Write-Log -Message "Connected to Microsoft Graph as: $($ctx.Account)" -Level 'INFO'
        Write-Log "Connected to Microsoft Graph as $($ctx.Account)"
        return $ctx.Account
    } catch {
Write-Log -Message "Microsoft Graph connection failed: $($_.Exception.Message)" -Level 'WARN'
        return $null
    }
}
