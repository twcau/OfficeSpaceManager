. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
function Suggest-RenameResource {
    Render-PanelHeader -Title "Suggest Rename for Non-Standard Resources"

    $cache = Get-Content ".\Metadata\CachedResources.json" | ConvertFrom-Json

    foreach ($r in $cache.Desks) {
        if ($r.DisplayName -notmatch '^[A-Z]{3}[A-Z0-9]+ Shared Desk \d+ \(.+\)$') {
            Write-Host "`nCurrent Name: $($r.DisplayName)"
            $suggest = Read-Host "Suggested Name"
            $confirm = Read-Host "Rename in Exchange now? (Y/N)"
            if ($confirm -eq 'Y') {
                Set-Mailbox -Identity $r.Email -DisplayName $suggest
                Write-Log "Renamed $($r.Email) to $suggest"
                Write-Host "✔️ Renamed."
            }
        }
    }
}
Suggest-RenameResource
