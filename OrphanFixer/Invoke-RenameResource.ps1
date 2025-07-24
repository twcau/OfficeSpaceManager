<#
.SYNOPSIS
    Suggests and applies renames for non-standard resources in OfficeSpaceManager.
.DESCRIPTION
    Analyses resource names and suggests or applies renames to match the standard convention. Uses EN-AU spelling and accessible output.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>
Import-Module "$PSScriptRoot/../Modules/CLI/CLI.psm1"
Import-Module "$PSScriptRoot/../Modules/Logging/Logging.psm1"
function Invoke-RenameResource {
    Get-PanelHeader -Title "Suggest Rename for Non-Standard Resources"

    $cache = Get-Content ".\Metadata\CachedResources.json" | ConvertFrom-Json

    foreach ($r in $cache.Desks) {
        if ($r.DisplayName -notmatch '^[A-Z]{3}[A-Z0-9]+ Shared Desk \d+ \(.+\)$') {
            Write-Host "`nCurrent Name: $($r.DisplayName)"
            $suggest = Read-Host "Suggested Name"
            $confirm = Read-Host "Rename in Exchange now? (Y/N)"
            if ($confirm -eq 'Y') {
                try {
                    Set-Mailbox -Identity $r.Email -DisplayName $suggest
                    Write-Log "Renamed $($r.Email) to $suggest"
                    Write-Log -Message "Renamed." -Level 'INFO'
                }
                catch {
                    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
                    Read-Host "Press Enter to continue..."
                }
            }
        }
    }
}
Invoke-RenameResource
