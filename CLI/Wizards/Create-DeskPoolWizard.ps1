<#
.SYNOPSIS
    Wizard to create a Desk Pool and assign desks.
#>

. "V:\Scripts\Saved Scripts\TESTING\OfficeSpaceManager\Shared\Write-Log.ps1"

$tenantConfig = Get-Content ".\config\TenantConfig.json" | ConvertFrom-Json
$defaultDomain = $tenantConfig.DefaultDomain

$poolName = Read-Host "Enter Desk Pool Name"
$purpose = Read-Host "Purpose of the pool (optional)"
$siteCode = Read-Host "Site Code (e.g. FRE)"

$deskFile = ".\Metadata\desks.json"
if (-not (Test-Path $deskFile)) {
    Write-Host "No desks available. Please create desks first." -ForegroundColor Yellow
    return
}
$desks = Get-Content $deskFile | ConvertFrom-Json
$eligibleDesks = $desks | Where-Object { $_.SiteCode -eq $siteCode }

if ($eligibleDesks.Count -eq 0) {
    Write-Host "❌ No desks found for site '$siteCode'." -ForegroundColor Red
    return
}

$selectedDesks = $eligibleDesks | Out-GridView -PassThru -Title "Select desks for pool '$poolName'"
if (-not $selectedDesks) { return }

$pool = [PSCustomObject]@{
    PoolName     = $poolName
    Purpose      = $purpose
    SiteCode     = $siteCode
    Domain       = $defaultDomain
    DeskAliases  = $selectedDesks.Alias
    Timestamp    = (Get-Date)
}

$poolsFile = ".\Metadata\DeskPools.json"
if (-not (Test-Path $poolsFile)) { @() | ConvertTo-Json | Set-Content $poolsFile }
$existingPools = Get-Content $poolsFile | ConvertFrom-Json
$existingPools += $pool
$existingPools | ConvertTo-Json -Depth 5 | Set-Content $poolsFile

Write-Host "✔️ Desk Pool '$poolName' created with $($selectedDesks.Count) desks." -ForegroundColor Green
Write-Log "Desk pool '$poolName' created."


