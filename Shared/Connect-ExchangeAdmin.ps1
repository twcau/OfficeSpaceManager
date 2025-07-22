. "$PSScriptRoot/Global-ErrorHandling.ps1"
function Connect-ExchangeAdmin {
    # Ensure ExchangeOnlineManagement module is loaded
    if (-not (Get-Module -Name ExchangeOnlineManagement)) {
        Import-Module ExchangeOnlineManagement -ErrorAction Stop
    }

    # Check existing connection
    try {
        $info = Get-ConnectionInformation -ErrorAction Stop
        if ($info.UserPrincipalName) {
            # Handle repeated or malformed UPNs
            $distinctUPNs = $info.UserPrincipalName -split '\s+' | Select-Object -Unique
            $upnString = ($distinctUPNs -join ', ')

Write-Log -Message "Already connected as: $upnString" -Level 'INFO'
            Write-Log "Exchange connection reused: $upnString"
            return $distinctUPNs[0]  # Return primary UPN for downstream logic
        }
    }
    catch {
        # Ignore - fall through to connect
    }

    # Attempt new connection
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
