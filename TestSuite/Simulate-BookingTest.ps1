# Load Shared Connection Logic
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\..\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Warning "âš ï¸ Skipping resource sync: unable to authenticate with Exchange Online."
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
    Write-Host "Ã°Å¸â€œâ€¦ Simulating booking for $upn..."
    $start = (Get-Date).AddHours(2)
    $end = $start.AddMinutes(30)

    New-TestMessage -Recipient $upn -Start $start -End $end -Subject "Test Booking" -ErrorAction Stop
    Write-Host "Ã¢Å“â€¦ Test booking sent." -ForegroundColor Green
} catch {
    Write-Warning "Ã¢ÂÅ’ Booking test failed: $_"
}





