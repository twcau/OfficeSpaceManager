# Load Shared Connection Logic
. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    return
}

    [string]$Alias,
    [string]$Domain
)

if (-not $Alias) {
    $Alias = Read-Host "Enter alias (e.g. FREFRE01SD17ICT)"
}
if (-not $Domain) {
    $tenantConfigPath = ".\config\TenantConfig.json"
    if (Test-Path $tenantConfigPath) {
        $config = Get-Content $tenantConfigPath | ConvertFrom-Json
        $Domain = $config.DefaultDomain
    } else {
        $Domain = Read-Host "Domain (e.g. yourdomain.com)"
    }
}

$upn = "$Alias@$Domain"

try {
Write-Log -Message "Simulating booking for $upn..." -Level 'INFO'
    $start = (Get-Date).AddHours(2)
    $end = $start.AddMinutes(30)

    New-TestMessage -Recipient $upn -Start $start -End $end -Subject "Test Booking" -ErrorAction Stop
Write-Log -Message "Test booking sent." -Level 'INFO'
} catch {
Write-Log -Message "Booking test failed: $_" -Level 'WARN'
}





