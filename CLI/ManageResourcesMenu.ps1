Render-PanelHeader -Title "Manage Resources"

# ðŸ‘‡ Check if any valid drafts exist
$hasDrafts = @(Get-ChildItem ".\.Drafts" -Filter *.json -ErrorAction SilentlyContinue | Where-Object {
    try {
        $null = Get-Content $_.FullName | ConvertFrom-Json -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}).Count -gt 0

# ðŸ‘‡ Display menu
Write-Host "[1] Create or Edit a Resource (Desk / Room / Equipment)"
if ($hasDrafts) {
    Write-Host "[2] Recover Failed Draft(s)"
}
Write-Host "[3] Retire or Reactivate a Resource"
Write-Host "[4] Run Booking Simulation Test"
Write-Host "[5] Create Desk Pool"
Write-Host "[6] Manage Desk Pools"
Write-Host "[7] Return to Main Menu"

$choice = Read-Host "`nSelect an option"

switch ($choice) {
    '1' { 
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Wizards\Manage-ResourceWizard.ps1"
    }
    '2' {
        if ($hasDrafts) {
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Wizards\Retry-DraftRunner.ps1"
        } else {
            Write-Host "No drafts available to recover." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
    '3' { 
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Manage\Toggle-ResourceState.ps1"
    }
    '4' { 
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\..\TestSuite\Run-BookingSimulation.ps1"
    }
    '5' { 
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Wizards\Create-DeskPoolWizard.ps1"
    }
    '6' { 
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Wizards\Manage-DeskPools.ps1"
    }
    '7' { 
        return 
    }
    default {
        Write-Host "Invalid option." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
    }
}





