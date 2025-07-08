function Connect-ExchangeAdmin {
    # Ensure ExchangeOnlineManagement module is loaded
    if (-not (Get-Module -Name ExchangeOnlineManagement)) {
        Import-Module ExchangeOnlineManagement -ErrorAction Stop
    }

    # Check existing connection
    try {
        $info = Get-ConnectionInformation -ErrorAction Stop
        if ($info.UserPrincipalName) {
            Write-Host "🔐 Already connected as: $($info.UserPrincipalName)" -ForegroundColor Green
            Write-Log "Exchange connection reused: $($info.UserPrincipalName)"
            return $info.UserPrincipalName
        }
    } catch {
        # Ignore - fall through
    }

    # Attempt new connection
    try {
        $session = Connect-ExchangeOnline -ShowBanner:$false -ShowProgress:$true -LoadCmdletHelp:$false
        $upn = ($session | Get-ConnectionInformation).UserPrincipalName

        if ([string]::IsNullOrEmpty($upn)) {
            throw "UserPrincipalName not returned after connection"
        }

        Write-Host "🔐 Connected as: $upn" -ForegroundColor Green
        Write-Log "Connected to Exchange Online as $upn"
        return $upn
    } catch {
        Write-Warning "❌ Exchange connection failed: $($_.Exception.Message)"
        return $null
    }
}
