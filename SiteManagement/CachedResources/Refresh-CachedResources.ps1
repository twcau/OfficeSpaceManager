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

. "$PSScriptRoot\..\..\Shared\Write-Log.ps1"
Render-PanelHeader -Title "Syncing Cached Resource Metadata"

$cachePath     = ".\Metadata\CachedResources.json"
$syncTrackPath = ".\Metadata\.lastSync.json"
$newCache = @{
    LastSynced = (Get-Date).ToUniversalTime().ToString("o")
    Desks      = @()
    Rooms      = @()
    Equipment  = @()
}

try {
    Write-Log "🔄 Starting cloud metadata sync for Exchange and Places..."
    Write-Host "`n📡 Fetching Room and Equipment Mailboxes..."

    $mailboxes = Get-Mailbox -RecipientTypeDetails RoomMailbox, EquipmentMailbox -ResultSize Unlimited

    foreach ($mb in $mailboxes) {
        $type     = $mb.RecipientTypeDetails
        $alias    = $mb.Alias
        $objectId = $mb.ExchangeObjectId.Guid
        $place    = Get-Place -Identity $alias -ErrorAction SilentlyContinue

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
                } else {
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
    } else {
        Write-Host "`n🟡 No changes detected in metadata. Skipping write."
        Write-Log "ℹ️ No update to cache — content unchanged."
    }

    # Save sync timestamp
    @{
        LastRefreshed = (Get-Date)
    } | ConvertTo-Json | Set-Content $syncTrackPath

    Write-Log "🕒 Updated .lastSync.json with current sync timestamp."

} catch {
    Write-Warning "❌ Sync failed: $_"
    Write-Log "❌ Refresh-CachedResources failed: $_"
}
