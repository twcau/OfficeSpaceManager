<#
.SYNOPSIS
    Shared utility and connection functions for OfficeSpaceManager.
.DESCRIPTION
    Provides helper functions for naming, and connection logic for Exchange, Graph, and Teams. Used by multiple modules and scripts. Ensures all utility logic is modular, maintainable, and auditable.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

# Utilities.psm1
# Shared utility and connection functions for OfficeSpaceManager

function Get-StandardDeskName {
    <#
    .SYNOPSIS
        Generate a standardised desk name string.
    .DESCRIPTION
        Returns a formatted desk name using site, building, floor, and desk number.
    .PARAMETER SiteCode
        [string] Site code (e.g., "SYD").
    .PARAMETER Building
        [string] Building name or code.
    .PARAMETER Floor
        [string] Floor identifier.
    .PARAMETER DeskNumber
        [int] Desk number.
    .EXAMPLE
        Get-StandardDeskName -SiteCode "SYD" -Building "A" -Floor "3" -DeskNumber 12
    .OUTPUTS
        [string] Standardised desk name.
    #>
    param (
        [Parameter(Mandatory)][string]$SiteCode,
        [Parameter(Mandatory)][string]$Building,
        [Parameter(Mandatory)][string]$Floor,
        [Parameter(Mandatory)][int]$DeskNumber
    )
    $formatted = "{0}-{1}-L{2}-D{3:000}" -f $SiteCode.ToUpper(), $Building.ToUpper(), $Floor, $DeskNumber
    return $formatted
}

function Connect-ExchangeAdmin {
    <#
    .SYNOPSIS
        Connect to Exchange Online and return the connected UPN.
    .DESCRIPTION
        Ensures ExchangeOnlineManagement module is loaded, reuses existing connection if possible, otherwise connects and returns the UPN.
    .OUTPUTS
        [string] UserPrincipalName of connected account, or $null on failure.
    .EXAMPLE
        Connect-ExchangeAdmin
    #>
    if (-not (Get-Module -Name ExchangeOnlineManagement)) {
        Import-Module ExchangeOnlineManagement -ErrorAction Stop
    }
    try {
        $info = Get-ConnectionInformation -ErrorAction Stop
        if ($info.UserPrincipalName) {
            $distinctUPNs = $info.UserPrincipalName -split '\s+' | Select-Object -Unique
            $upnString = ($distinctUPNs -join ', ')
            Write-Log -Message "Already connected as: $upnString" -Level 'INFO'
            Write-Log "Exchange connection reused: $upnString"
            return $distinctUPNs[0]
        }
    }
    catch {}
    try {
        $session = Connect-ExchangeOnline -ShowBanner:$false -ShowProgress:$true
        $upn = ($session | Get-ConnectionInformation).UserPrincipalName
        if ([string]::IsNullOrEmpty($upn)) {
            throw "UserPrincipalName not returned after connection"
        }
        Write-Log -Message "Connected as: $upn" -Level 'INFO'
        Write-Log "Connected to Exchange Online as $upn"
        return $upn
    }
    catch {
        Write-Log -Message "Exchange connection failed: $($_.Exception.Message)" -Level 'WARN'
        return $null
    }
}

function Connect-Graph {
    <#
    .SYNOPSIS
        Connect to Microsoft Graph and return the connected account.
    .DESCRIPTION
        Ensures Microsoft.Graph module is loaded, reuses existing connection if possible, otherwise connects and returns the account.
    .OUTPUTS
        [string] Connected account, or $null on failure.
    .EXAMPLE
        Connect-Graph
    #>
    if (-not (Get-Module Microsoft.Graph)) {
        Import-Module Microsoft.Graph -ErrorAction Stop
    }
    try {
        $ctx = Get-MgContext
        if ($ctx.Account) {
            Write-Log -Message "Already connected to Microsoft Graph as: $($ctx.Account)" -Level 'INFO'
            Write-Log "Graph connection reused: $($ctx.Account)"
            return $ctx.Account
        }
    }
    catch {}
    try {
        Connect-MgGraph -Scopes "User.Read.All", "Place.Read.All"
        $ctx = Get-MgContext
        Write-Log -Message "Connected to Microsoft Graph as: $($ctx.Account)" -Level 'INFO'
        Write-Log "Connected to Microsoft Graph as $($ctx.Account)"
        return $ctx.Account
    }
    catch {
        Write-Log -Message "Microsoft Graph connection failed: $($_.Exception.Message)" -Level 'WARN'
        return $null
    }
}

function Connect-TeamsService {
    <#
    .SYNOPSIS
        Connect to Microsoft Teams and return connection status.
    .DESCRIPTION
        Ensures MicrosoftTeams module is loaded, reuses existing connection if possible, otherwise connects and returns $true/$false.
    .OUTPUTS
        [bool] $true if connected, $false on failure.
    .EXAMPLE
        Connect-TeamsService
    #>
    if (-not (Get-Module MicrosoftTeams)) {
        Import-Module MicrosoftTeams -ErrorAction Stop
    }
    try {
        $details = Get-CsTenant -ErrorAction Stop
        Write-Log -Message "Already connected to Microsoft Teams." -Level 'INFO'
        Write-Log "Reused Teams session."
        return $true
    }
    catch {}
    try {
        Connect-MicrosoftTeams
        Write-Log -Message "Connected to Microsoft Teams." -Level 'INFO'
        Write-Log "Connected to Microsoft Teams."
        return $true
    }
    catch {
        Write-Log -Message "Microsoft Teams connection failed: $($_.Exception.Message)" -Level 'WARN'
        return $false
    }
}

Export-ModuleMember -Function Get-StandardDeskName, Connect-ExchangeAdmin, Connect-Graph, Connect-TeamsService
