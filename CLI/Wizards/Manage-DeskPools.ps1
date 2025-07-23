. "$PSScriptRoot/../../Shared/Global-ErrorHandling.ps1"
<#
.SYNOPSIS
    Wizard for managing desk pools in OfficeSpaceManager.
.DESCRIPTION
    Provides interactive options for editing, deleting, or viewing desk pools. Uses EN-AU spelling and accessible output.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Write-Log.ps1"

$poolsFile = ".\Metadata\DeskPools.json"
if (-not (Test-Path $poolsFile)) {
    Write-Log -Message "No pools found." -Level 'WARN'
    return
}
$pools = Get-Content $poolsFile | ConvertFrom-Json

$selectedPool = $pools | Out-GridView -PassThru -Title "Select a desk pool to manage"
if (-not $selectedPool) { return }

Write-Host "`nSelected: $($selectedPool.PoolName)" -ForegroundColor Cyan
Write-Host "1. Rename Pool"
Write-Host "2. Edit Assigned Desks"
Write-Host "3. Delete Pool"
Write-Host "4. Cancel"

$opt = Read-Host "Choose option"
switch ($opt) {
    '1' {
        $newName = Read-Host "New name"
        $selectedPool.PoolName = $newName
    }
    '2' {
        $deskFile = ".\Metadata\desks.json"
        $desks = Get-Content $deskFile | ConvertFrom-Json
        $newDesks = $desks | Out-GridView -PassThru -Title "Reassign desks"
        $selectedPool.DeskAliases = $newDesks.Alias
    }
    '3' {
        $confirm = Read-Host "Type DELETE to confirm"
        if ($confirm -eq "DELETE") {
            $pools = $pools | Where-Object { $_.PoolName -ne $selectedPool.PoolName }
            $pools | ConvertTo-Json -Depth 5 | Set-Content $poolsFile
            Write-Log -Message "Pool deleted." -Level 'ERROR'
            Write-Log "Deleted pool '$($selectedPool.PoolName)'"
            return
        }
    }
    default { return }
}

$pools = $pools | Where-Object { $_.PoolName -ne $selectedPool.PoolName }
$pools += $selectedPool
$pools | ConvertTo-Json -Depth 5 | Set-Content $poolsFile
Write-Log "Updated pool '$($selectedPool.PoolName)'"
Write-Log -Message "Pool updated." -Level 'INFO'



