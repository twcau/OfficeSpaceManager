function Connect-Graph {
    if (-not (Get-Module Microsoft.Graph)) {
        Import-Module Microsoft.Graph -ErrorAction Stop
    }

    # Reuse session if already connected
    try {
        $ctx = Get-MgContext
        if ($ctx.Account) {
            Write-Host "🔐 Already connected to Microsoft Graph as: $($ctx.Account)" -ForegroundColor Green
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
        Write-Host "🔐 Connected to Microsoft Graph as: $($ctx.Account)" -ForegroundColor Green
        Write-Log "Connected to Microsoft Graph as $($ctx.Account)"
        return $ctx.Account
    } catch {
        Write-Warning "❌ Microsoft Graph connection failed: $($_.Exception.Message)"
        return $null
    }
}
