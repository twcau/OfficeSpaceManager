<#
.SYNOPSIS
    Interactive wizard for creating or editing a Desk, Room, or Equipment resource
    with Exchange and Microsoft Places provisioning, validation, retry, and recovery.
#>

#region 🔧 Load Helper Functions
. "$PSScriptRoot\Shared\Get-StandardDeskName.ps1"
. "$PSScriptRoot\Shared\Write-Log.ps1"
. "$PSScriptRoot\TestSuite\Simulate-BookingTest.ps1"
#endregion

#region 📂 Load Metadata
$resourceType = Read-Host "What type of resource are you creating/editing? [desk / room / equipment]"
$resourceType = $resourceType.ToLower()
if ($resourceType -notin @('desk', 'room', 'equipment')) {
    Write-Host "❌ Invalid resource type." -ForegroundColor Red
    return
}
$resourceFile = ".\Metadata\$($resourceType)s.json"
if (-not (Test-Path $resourceFile)) {
    @() | ConvertTo-Json | Set-Content $resourceFile
}
$items = Get-Content $resourceFile | ConvertFrom-Json

$siteFile      = ".\Metadata\Sites.json"
$buildingFile  = ".\Metadata\Buildings.json"
$floorFile     = ".\Metadata\Floors.json"
$pathwayFile   = ".\Metadata\Pathways.json"
$domainConfig  = ".\config\TenantConfig.json"
$draftFolder   = ".\.Drafts\"
if (!(Test-Path $draftFolder)) { New-Item $draftFolder -ItemType Directory | Out-Null }

#endregion

#region 🔄 User Inputs (Select Site > Building > Floor > Pathway)
$sites = Get-Content $siteFile | ConvertFrom-Json
$site = $sites | Out-GridView -Title "Select Site" -PassThru
if (-not $site) { return }

$buildings = Get-Content $buildingFile | ConvertFrom-Json
$siteBuildings = $buildings | Where-Object { $_.SiteCode -eq $site.SiteCode }
$building = $siteBuildings | Out-GridView -Title "Select Building" -PassThru
if (-not $building) { return }

$floors = Get-Content $floorFile | ConvertFrom-Json
$buildingFloors = $floors | Where-Object {
    $_.SiteCode -eq $site.SiteCode -and $_.BuildingCode -eq $building.BuildingCode
}
$floor = $buildingFloors | Out-GridView -Title "Select Floor" -PassThru
if (-not $floor) { return }

$pathways = Get-Content $pathwayFile | ConvertFrom-Json
$pathway = $pathways | Out-GridView -Title "Select Pathway" -PassThru
if (-not $pathway) { return }

#endregion

#region 🖊 User Inputs for Resource
$deskNum = Read-Host "Enter Desk/Room Number and Name, or Equipment Description (e.g. 17)"
$roleDesc = Read-Host "If a Desk, enter Role Description to indicate the group of people the desk is intended to be used by (optional)"
$displayName = Get-StandardDeskName -SiteCode $site.SiteCode -BuildingNumber $building.BuildingCode -DeskNumber $deskNum -Pathway $pathway.Code -RoleDescription $roleDesc
$alias = ($displayName -replace '\s+', '').ToLower()

#endregion

#region 🌐 Domain Selection
$tenantConfig = Get-Content $domainConfig | ConvertFrom-Json
$domains = @($tenantConfig.DefaultDomain) + ($tenantConfig.Domains | Where-Object { $_ -ne $tenantConfig.DefaultDomain })
$domains = $domains | Select-Object -Unique
$domain = if ($domains.Count -eq 1) {
    $domains[0]
} else {
    for ($i = 0; $i -lt $domains.Count; $i++) {
        Write-Host "[$($i+1)] $($domains[$i])"
    }
    $sel = Read-Host "Select domain"
    $domains[$sel - 1]
}

#endregion

#region 🧾 Build Resource Object
$resource = [PSCustomObject]@{
    DisplayName       = $displayName
    Alias             = $alias
    Domain            = $domain
    SiteCode          = $site.SiteCode
    BuildingCode      = $building.BuildingCode
    FloorId           = $floor.Id
    FloorName         = $floor.DisplayName
    Pathway           = $pathway.Code
    DeskNumber        = $deskNum
    Role              = $roleDesc
    ObjectType        = $resourceType
    Timestamp         = (Get-Date)
}

if ($resourceType -eq 'desk') {
    $resource.IsHeightAdjustable = Read-Host "Height Adjustable (Y/N)"
    $resource.HasDockingStation  = Read-Host "Docking Station Available (Y/N)"
    $resource.IsAccessible       = Read-Host "Wheelchair Accessible (Y/N)"
} elseif ($resourceType -eq 'room') {
    $resource.Capacity = Read-Host "Room Capacity"
} elseif ($resourceType -eq 'equipment') {
    $resource.EquipmentType = Read-Host "Equipment Type (TV, Projector, etc)"
}

#endregion

#region ✅ Review Loop
do {
    Clear-Host
    Render-PanelHeader -Title "Review $resourceType Details Before Saving"
    $resource | Format-List | Out-Host
    $confirm = Read-Host "Do you want to [A]ccept & Save, [E]dit, [C]ancel?"
    switch ($confirm.ToUpper()) {
        'A' {
            break
        }
        'E' {
            $props = $resource.PSObject.Properties | Select-Object -ExpandProperty Name
            foreach ($prop in $props) {
                $curr = $resource.$prop
                $action = Read-Host "$prop: [$curr] → Keep (K), Replace (R), or Skip"
                if ($action -eq 'R') {
                    $resource.$prop = Read-Host "New value for $prop"
                }
            }
        }
        'C' { return }
    }
} while ($true)

#endregion

#region 💥 Provision Exchange Resource
$upn = "$alias@$domain"
$errorFlag = $false
$existingMailbox = Get-Mailbox -Identity $upn -ErrorAction SilentlyContinue

if ($existingMailbox) {
    Write-Host "`n⚠️ Mailbox already exists. Comparing with local data..." -ForegroundColor Yellow
    $diff = Compare-Object -ReferenceObject $resource -DifferenceObject $existingMailbox | Format-Table
    $diff | Out-Host

    $action = Read-Host "Options: [K]eep Exchange, [O]verwrite, [E]dit entries"
    switch ($action.ToUpper()) {
        'K' { Write-Host "✔️ Keeping existing Exchange mailbox." }
        'O' { $overwrite = $true }
        'E' { goto :edit_resource }
    }
} else {
    try {
        function New-SecurePassword {
            $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%^&*'
            do {
                $pwd = -join ((65..90)+(97..122)+(48..57)+33..47 | Get-Random -Count 14 | ForEach-Object {[char]$_})
            } while (
                $pwd -notmatch '[A-Z]' -or
                $pwd -notmatch '[a-z]' -or
                $pwd -notmatch '[0-9]' -or
                $pwd -notmatch '[\!\@\#\$\%\^\&\*]' -or
                $pwd -match '(.)\1{2,}' -or
                $pwd -match '(012|123|234|345|456|567|678|789)'
            )
            return $pwd
        }

        $securePwd = (New-SecurePassword) | ConvertTo-SecureString -AsPlainText -Force

        Write-Host "🛠 Creating mailbox in Exchange..."
        New-Mailbox -Name $resource.DisplayName `
                    -Alias $resource.Alias `
                    -DisplayName $resource.DisplayName `
                    -MicrosoftOnlineServicesID $upn `
                    -Room `
                    -EnableRoomMailboxAccount $true `
                    -RoomMailboxPassword $securePwd

        Set-Mailbox -Identity $upn -Type Room

        $placeParams = @{
            Identity     = $upn
            Building     = $resource.BuildingCode
            FloorLabel   = $resource.FloorName
            FloorNumber  = $floor.FloorNumber
        }

        if ($resourceType -eq 'desk') {
            if ($resource.IsAccessible -eq 'Y') { $placeParams['IsWheelChairAccessible'] = $true }
            if ($resource.IsHeightAdjustable -eq 'Y') { $placeParams['IsHeightAdjustable'] = $true }
            if ($resource.HasDockingStation -eq 'Y') { $placeParams['HasDockingStation'] = $true }
            $placeParams['DeskNumber'] = $resource.DeskNumber
        }

        Set-Place @placeParams
        Write-Host "🏢 Microsoft Places configuration applied." -ForegroundColor Green

    } catch {
        $errorFlag = $true
        Write-Warning "❌ Exchange provisioning failed: $_"
        $draftPath = "$draftFolder\Draft_${resourceType}_$(Get-Date -Format 'yyyyMMdd_HHmm').json"
        $resource | ConvertTo-Json -Depth 8 | Set-Content $draftPath
        Write-Host "💾 Draft saved to $draftPath for retry."
        return
    }
}

#endregion

#region 💾 Save Metadata
$items = $items | Where-Object { $_.Alias -ne $alias }
$items += $resource
$items | ConvertTo-Json -Depth 8 | Set-Content $resourceFile
Write-Log "$resourceType '$($resource.DisplayName)' created. Exchange provisioning: $([bool](-not $errorFlag))"

#endregion

#region 📅 Offer Booking Simulation
if (-not $errorFlag) {
    do {
        $runSim = Read-Host "Would you like to run a booking simulation now? (Y/N)"
        if ($runSim -eq 'Y') {
            try {
                $simResult = . "$PSScriptRoot\TestSuite\Simulate-BookingTest.ps1" -Alias $alias -Domain $domain
                $success = $simResult.MailboxFound -and $simResult.MailFlowOK -and $simResult.AutoAccept

                if ($success) {
                    Write-Host "✅ Simulation test passed for $alias@$domain" -ForegroundColor Green
                    Write-Log "Simulation success for $alias@$domain"
                    break
                } else {
                    Write-Warning "⚠️ Simulation ran but had issues. See log or review above."
                    Write-Log "Simulation warning for $alias@$domain"
                    $again = Read-Host "Would you like to retry simulation? (Y/N)"
                    if ($again -ne 'Y') { break }
                }
            } catch {
                Write-Warning "❌ Simulation test failed: $_"
                Write-Log "Simulation exception: $_"
                break
            }
        } elseif ($runSim -eq 'N') {
            break
        }
    } while ($true)
} else {
    Write-Host "❌ Resource not provisioned in Exchange. Skipping simulation." -ForegroundColor Yellow
}
#endregion

return

:edit_resource
# jump label used in editable retry loop above

