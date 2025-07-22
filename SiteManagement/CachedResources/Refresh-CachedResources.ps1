<#
.SYNOPSIS
    Sync local cache of Exchange/Places resource metadata.
.DESCRIPTION
    Retrieves desks, rooms, equipment metadata from Exchange Online and Places.
    Saves to .\Metadata\CachedResources.json and writes .lastSync.json for sync freshness tracking.
#>

param (
    [switch]$Force
)

. "$PSScriptRoot/../../Shared/Global-ErrorHandling.ps1"

# Load Shared Modules
Write-Log -Message "Loading shared modules"
Write-Log -Message "Loading Shared\Write-Log.ps1"
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Write-Log.ps1"
Write-Log -Message "Loading Shared\Connect-ExchangeAdmin.ps1"
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Connect-ExchangeAdmin.ps1"
Write-Log -Message "Shared modules loaded"

# Ensure connection to Exchange
$admin = Connect-ExchangeAdmin
if (-not $admin -or $admin -eq '') {
Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    Write-Log -Message "⚠️ Skipping resource sync: unable to authenticate with Exchange Online."
    return
}

# region 🔁 Metadata Cache Freshness Check with Prompt
$syncTrackPath = ".\Metadata\.lastSync.json"
if (Test-Path $syncTrackPath) {
    try {
        $lastSync = (Get-Content $syncTrackPath | ConvertFrom-Json).LastRefreshed
        $lastSyncDate = Get-Date $lastSync
        $minutesOld = (New-TimeSpan -Start $lastSyncDate -End (Get-Date)).TotalMinutes

        if ($minutesOld -lt 15 -and -not $Force) {
            Write-Log -Message "🕒 Metadata was last refreshed $([int]$minutesOld) minutes ago."
Write-Log -Message "Metadata was last refreshed $([int]$minutesOld) minutes ago." -Level 'WARN'
            $doSync = Read-Host "Re-sync cloud metadata anyway? (Y/N)"
            if ($doSync -notin @('Y', 'y')) {
Write-Log -Message "Skipping metadata refresh." -Level 'WARN'
                Write-Log "Skipped Refresh-CachedResources — user declined re-sync at $([int]$minutesOld) minutes."
                return
            }
        }
    }
    catch {
Write-Log -Message "Failed to evaluate metadata freshness — proceeding with sync." -Level 'WARN'
        Write-Log "⚠️ Failed to evaluate last sync timestamp — $($_.Exception.Message)"
    }
}
# endregion

Render-PanelHeader -Title "Syncing Cached Resource Metadata"

$cachePath = ".\Metadata\CachedResources.json"
$syncTrackPath = ".\Metadata\.lastSync.json"
$newCache = @{
    LastSynced = (Get-Date).ToUniversalTime().ToString("o")
    Desks      = @()
    Rooms      = @()
    Equipment  = @()
}

try {
    Write-Log "📡 Starting cloud metadata sync for Exchange and Places..."
    Write-Host "`n📥 Fetching Room and Equipment Mailboxes..."

    $mailboxes = Get-Mailbox -RecipientTypeDetails RoomMailbox, EquipmentMailbox -ResultSize Unlimited

    foreach ($mb in $mailboxes) {
        $type = $mb.RecipientTypeDetails
        $alias = $mb.Alias
        $objectId = $mb.ExchangeObjectId.Guid
        $place = Get-Place -Identity $alias -ErrorAction SilentlyContinue

        $record = [PSCustomObject]@{
            DisplayName      = $mb.DisplayName
            Email            = $mb.PrimarySmtpAddress.ToString()
            ExchangeObjectId = $objectId
            Alias            = $alias
            Type             = $type
            Site             = $place.Site
            Building         = $place.Building
            Floor            = $place.Floor
            Capacity         = $place.Capacity
        }

        switch ($type) {
            "RoomMailbox" {
                if ($place.IsWheelChairAccessible -or $mb.DisplayName -like "*Desk*") {
                    $newCache.Desks += $record
                }
                else {
                    $newCache.Rooms += $record
                }
            }
            "EquipmentMailbox" {
                $newCache.Equipment += $record
            }
        }
    }

    $jsonNew = $newCache | ConvertTo-Json -Depth 6
    $jsonOld = if (Test-Path $cachePath) { Get-Content $cachePath -Raw } else { "" }

    if ($Force -or ($jsonNew -ne $jsonOld)) {
        $jsonNew | Set-Content $cachePath
        Write-Host "`n✅ Cached resource metadata updated." -ForegroundColor Green
        Write-Log "✅ CachedResources.json updated successfully."
    }
    else {
        Write-Host "`n🟡 No changes detected in metadata. Skipping write."
        Write-Log "🟡 No update to cache — content unchanged."
    }

    # Save sync timestamp
    @{
        LastRefreshed = (Get-Date)
    } | ConvertTo-Json | Set-Content $syncTrackPath

    Write-Log "🕒 Updated .lastSync.json with current sync timestamp."

}
catch {
Write-Log -Message "Sync failed: $($_.Exception.Message)" -Level 'WARN'
    Write-Log "❌ Refresh-CachedResources failed: $($_.Exception.Message)"
}
