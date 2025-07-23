. "$PSScriptRoot/../../Shared/Global-ErrorHandling.ps1"
<#
.SYNOPSIS
    Wizard for creating a new desk pool in OfficeSpaceManager.
.DESCRIPTION
    Guides the user through the process of creating a new desk pool, ensuring all required fields are captured and validated. Uses EN-AU spelling and accessible output.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Write-Log.ps1"

$tenantConfig = Get-Content ".\config\TenantConfig.json" | ConvertFrom-Json
$defaultDomain = $tenantConfig.DefaultDomain

$poolName = Read-Host "Enter Desk Pool Name"
$purpose = Read-Host "Purpose of the pool (optional)"
$siteCode = Read-Host "Site Code (e.g. FRE)"

$deskFile = ".\Metadata\desks.json"
if (-not (Test-Path $deskFile)) {
    Write-Log -Message "No desks available. Please create desks first." -Level 'WARN'
    return
}
$desks = Get-Content $deskFile | ConvertFrom-Json
$eligibleDesks = $desks | Where-Object { $_.SiteCode -eq $siteCode }

if ($eligibleDesks.Count -eq 0) {
    Write-Log -Message "No desks found for site '$siteCode'." -Level 'ERROR'
    return
}

$selectedDesks = $eligibleDesks | Out-GridView -PassThru -Title "Select desks for pool '$poolName'"
if (-not $selectedDesks) { return }

$pool = [PSCustomObject]@{
    PoolName    = $poolName
    Purpose     = $purpose
    SiteCode    = $siteCode
    Domain      = $defaultDomain
    DeskAliases = $selectedDesks.Alias
    Timestamp   = (Get-Date)
}

$poolsFile = ".\Metadata\DeskPools.json"
if (-not (Test-Path $poolsFile)) { @() | ConvertTo-Json | Set-Content $poolsFile }
$existingPools = Get-Content $poolsFile | ConvertFrom-Json
$existingPools += $pool
$existingPools | ConvertTo-Json -Depth 5 | Set-Content $poolsFile

Write-Log -Message "Desk Pool '$poolName' created with $($selectedDesks.Count) desks." -Level 'INFO'
Write-Log "Desk pool '$poolName' created."



