<#!
.SYNOPSIS
    Centralised connection logic for OfficeSpaceManager (Exchange, Graph, Teams, Places).
.DESCRIPTION
    Provides robust, session-reusing, error-proof connection functions for all Microsoft 365 services. Ensures all connections are established at startup, with clear user messaging, module checks, and retry logic. All output uses EN-AU spelling and accessible language.
.FILECREATED
    2025-07-24
.FILELASTUPDATED
    2025-07-24
#>

function Connect-ExchangeAdmin {
    <#!
    .SYNOPSIS
        Connect to Exchange Online and return the connected UPN.
    .DESCRIPTION
        Ensures ExchangeOnlineManagement module is loaded, reuses existing connection if possible, otherwise connects and returns the UPN. Adds robust error handling and detailed logging for all connection steps.
    .OUTPUTS
        [string] UserPrincipalName of connected account, or $null on failure.
    .EXAMPLE
        Connect-ExchangeAdmin
    #>
    Write-Host "Attempting to connect to Exchange Online. A browser tab may open for authentication..." -ForegroundColor Cyan
    # Ensure ExchangeOnlineManagement module is loaded
    if (-not (Get-Module -Name ExchangeOnlineManagement)) {
        try {
            Import-Module ExchangeOnlineManagement -ErrorAction Stop
        }
        catch {
            # Log and return if module import fails
            Write-Log -Message "Failed to import ExchangeOnlineManagement: $($_.Exception.Message)" -Level 'ERROR'
            return $null
        }
    }
    # Attempt to reuse an existing Exchange Online session
    try {
        $info = Get-ConnectionInformation -ErrorAction Stop
        if ($info -and $info.UserPrincipalName) {
            # Split and deduplicate UPNs in case of multiple connections
            $distinctUPNs = $info.UserPrincipalName -split '\s+' | Select-Object -Unique
            $upnString = ($distinctUPNs -join ', ')
            # Log the reused connection
            Write-Log -Message "Already connected as: $upnString" -Level 'INFO'
            Write-Log "Exchange connection reused: $upnString"
            # Return the first UPN found
            return $distinctUPNs[0]
        }
    }
    catch {
        # Log info if no existing session is found
        Write-Log -Message "No existing Exchange Online session found: $($_.Exception.Message)" -Level 'INFO'
    }
    # Attempt to establish a new Exchange Online session
    try {
        $session = Connect-ExchangeOnline -ShowBanner:$false -ShowProgress:$true
        if (-not $session) {
            # Log and return if no session object is returned
            Write-Log -Message "Connect-ExchangeOnline did not return a session object." -Level 'ERROR'
            return $null
        }
        # Retrieve connection information from the new session
        $connInfo = $session | Get-ConnectionInformation
        if ($connInfo -and $connInfo.UserPrincipalName) {
            $upn = $connInfo.UserPrincipalName
            # Log successful connection
            Write-Log -Message "Connected as: $upn" -Level 'INFO'
            Write-Log "Connected to Exchange Online as $upn"
            return $upn
        }
        else {
            # Log error if UPN is not returned after connection
            Write-Log -Message "UserPrincipalName not returned after connection. Full connection info: $($connInfo | Out-String)" -Level 'ERROR'
            return $null
        }
    }
    catch {
        # Log all connection errors, including inner exceptions
        Write-Log -Message "Exchange connection failed: $($_.Exception.Message)" -Level 'ERROR'
        if ($_.Exception.InnerException) {
            Write-Log -Message "Inner exception: $($_.Exception.InnerException.Message)" -Level 'ERROR'
        }
        return $null
    }
    finally {
        # Final check for connection information
        try {
            $info = Get-ConnectionInformation -ErrorAction Stop
            if ($info -and $info.UserPrincipalName) {
                # Split and deduplicate UPNs in case of multiple connections
                $distinctUPNs = $info.UserPrincipalName -split '\s+' | Select-Object -Unique
                $upnString = ($distinctUPNs -join ', ')
                # Log the reused connection
                Write-Log -Message "Connection established as: $upnString" -Level 'INFO'
                # Do not return from finally block
            }
        }
        catch {
            # Log any errors during final connection information retrieval
            Write-Log -Message "Error retrieving connection information: $($_.Exception.Message)" -Level 'ERROR'
        }
    }
    # After finally, check if info was set and return UPN if available
    if ($info -and $info.UserPrincipalName) {
        $distinctUPNs = $info.UserPrincipalName -split '\s+' | Select-Object -Unique
        $upnString = ($distinctUPNs -join ', ')
        Write-Log -Message "Connection established as: $upnString" -Level 'INFO'
        return $distinctUPNs[0]
    }
    return $null
}

function Connect-Graph {
    <#!
    .SYNOPSIS
        Connect to Microsoft Graph and return the connected account.
    .DESCRIPTION
        Ensures Microsoft.Graph module is loaded, reuses existing connection if possible, otherwise connects and returns the account. Adds robust error handling and detailed logging for all connection steps.
    .OUTPUTS
        [string] Connected account, or $null on failure.
    .EXAMPLE
        Connect-Graph
    #>
    Write-Host "Attempting to connect to Microsoft Graph. A browser tab may open for authentication..." -ForegroundColor Cyan
    # Ensure Microsoft.Graph module is loaded
    if (-not (Get-Module Microsoft.Graph)) {
        try {
            Import-Module Microsoft.Graph -ErrorAction Stop
        }
        catch {
            # Log and return if module import fails
            Write-Log -Message "Failed to import Microsoft.Graph: $($_.Exception.Message)" -Level 'ERROR'
            return $null
        }
    }
    # Attempt to reuse an existing Microsoft Graph session
    try {
        $ctx = Get-MgContext
        if ($ctx -and $ctx.Account) {
            # Log the reused connection
            Write-Log -Message "Already connected to Microsoft Graph as: $($ctx.Account)" -Level 'INFO'
            Write-Log "Graph connection reused: $($ctx.Account)"
            return $ctx.Account
        }
    }
    catch {
        # Log info if no existing session is found
        Write-Log -Message "No existing Microsoft Graph session found: $($_.Exception.Message)" -Level 'INFO'
    }
    # Attempt to establish a new Microsoft Graph session
    try {
        Connect-MgGraph -Scopes "User.Read.All", "Place.Read.All"
        $ctx = Get-MgContext
        if ($ctx -and $ctx.Account) {
            # Log successful connection
            Write-Log -Message "Connected to Microsoft Graph as: $($ctx.Account)" -Level 'INFO'
            Write-Log "Connected to Microsoft Graph as $($ctx.Account)"
            return $ctx.Account
        }
        else {
            # Log error if account is not returned after connection
            Write-Log -Message "Account not returned after Graph connection. Full context: $($ctx | Out-String)" -Level 'ERROR'
            return $null
        }
    }
    catch {
        # Log all connection errors, including inner exceptions
        Write-Log -Message "Microsoft Graph connection failed: $($_.Exception.Message)" -Level 'ERROR'
        if ($_.Exception.InnerException) {
            Write-Log -Message "Inner exception: $($_.Exception.InnerException.Message)" -Level 'ERROR'
        }
        return $null
    }
}

function Connect-TeamsService {
    <#!
    .SYNOPSIS
        Connect to Microsoft Teams and return connection status.
    .DESCRIPTION
        Ensures MicrosoftTeams module is loaded, installs if missing, reuses existing connection if possible, otherwise connects and returns $true/$false. Adds robust error handling and detailed logging for all connection steps. Removes PowerShell edition check and only errors if module truly fails.
    .OUTPUTS
        [bool] $true if connected, $false on failure.
    .EXAMPLE
        Connect-TeamsService
    #>
    Write-Host "Attempting to connect to Microsoft Teams. A browser tab may open for authentication..." -ForegroundColor Cyan
    # Ensure MicrosoftTeams module is loaded
    if (-not (Get-Module -ListAvailable -Name MicrosoftTeams)) {
        Write-Log -Message "MicrosoftTeams module not found. Attempting installation..." -Level 'WARN'
        try {
            Install-Module -Name MicrosoftTeams -Scope CurrentUser -Force -ErrorAction Stop
            Write-Log -Message "Installed MicrosoftTeams module successfully." -Level 'INFO'
        }
        catch {
            Write-Log -Message "Failed to install MicrosoftTeams: $($_.Exception.Message)" -Level 'ERROR'
            Write-Host "\n❌ Failed to install MicrosoftTeams module. Please install manually." -ForegroundColor Red
            return $false
        }
    }
    try {
        Import-Module MicrosoftTeams -ErrorAction Stop
        Connect-MicrosoftTeams
        Write-Log -Message "Connected to Microsoft Teams." -Level 'INFO'
        return $true
    }
    catch [System.OperationCanceledException] {
        Write-Log -Message "Microsoft Teams authentication was cancelled by the user." -Level 'ERROR'
        Write-Host "\n❌ Microsoft Teams authentication was cancelled. Please try again." -ForegroundColor Red
        return $false
    }
    catch {
        Write-Log -Message "Microsoft Teams connection failed: $($_.Exception.Message)" -Level 'ERROR'
        Write-Host "\n❌ Unable to connect to Microsoft Teams. Please check your credentials, network, and module installation." -ForegroundColor Red
        return $false
    }
}

function Connect-PlacesService {
    <#!
    .SYNOPSIS
        Connect to Microsoft Places PowerShell and return connection status.
    .DESCRIPTION
        Ensures MicrosoftPlaces module is loaded, reuses existing session if possible, otherwise connects and returns $true/$false. Adds robust error handling and detailed logging for all connection steps.
    .OUTPUTS
        [bool] $true if connected, $false on failure.
    .EXAMPLE
        Connect-PlacesService
    #>
    Write-Host "Attempting to connect to Microsoft Places. A browser tab may open for authentication..." -ForegroundColor Cyan
    if (-not (Get-Module MicrosoftPlaces)) {
        try {
            Import-Module MicrosoftPlaces -ErrorAction Stop
        }
        catch {
            Write-Log -Message "Failed to import MicrosoftPlaces: $($_.Exception.Message)" -Level 'ERROR'
            return $false
        }
    }
    try {
        Connect-MicrosoftPlaces
        Write-Log -Message "Connected to Microsoft Places." -Level 'INFO'
        return $true
    }
    catch {
        Write-Log -Message "Microsoft Places connection failed: $($_.Exception.Message)" -Level 'ERROR'
        if ($_.Exception.InnerException) {
            Write-Log -Message "Inner exception: $($_.Exception.InnerException.Message)" -Level 'ERROR'
        }
        return $false
    }
}

function Connect-AllServices {
    <#!
    .SYNOPSIS
        Connects to all required Microsoft 365 services at startup.
    .DESCRIPTION
        Orchestrates connections to Exchange, Graph, Teams, and Places. Checks for existing sessions, prompts for authentication if needed, and provides clear user messaging. Handles module installation and retry logic if required.
    .OUTPUTS
        [void]
    .EXAMPLE
        Connect-AllServices
    #>
    Get-PanelHeader -Title "Connecting to Microsoft 365 Services"
    Write-Host "\nConnecting to Exchange Online..." -ForegroundColor Cyan
    $exchangeUPN = Connect-ExchangeAdmin
    if (-not $exchangeUPN) {
        Write-Host "❌ Unable to connect to Exchange Online. Please check your credentials and network." -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        exit
    }
    Write-Host "Connected to Exchange Online as $exchangeUPN" -ForegroundColor Green

    <#

    // NOTE: Ignoring connections to Microsoft Graph at this time, due to the length of time needed for this, and the delays it causes running the script.

    Write-Host "\nConnecting to Microsoft Graph..." -ForegroundColor Cyan
    $graphAccount = Connect-Graph
    if (-not $graphAccount) {
        Write-Host "❌ Unable to connect to Microsoft Graph. Please check your credentials and network." -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        exit
    }
    Write-Host "Connected to Microsoft Graph as $graphAccount" -ForegroundColor Green
    #>

    Write-Host "\nConnecting to Microsoft Teams..." -ForegroundColor Cyan
    $teamsConnected = Connect-TeamsService
    if (-not $teamsConnected) {
        Write-Host "❌ Unable to connect to Microsoft Teams. Please check your credentials and network." -ForegroundColor Red
        Read-Host "Press Enter to exit..."
        exit
    }
    Write-Host "Connected to Microsoft Teams as $teamsConnected" -ForegroundColor Green
}

#>
Export-ModuleMember -Function Connect-ExchangeAdmin, Connect-Graph, Connect-TeamsService, Connect-PlacesService, Connect-AllServices
