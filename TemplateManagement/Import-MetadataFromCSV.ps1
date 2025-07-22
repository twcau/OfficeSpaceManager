. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
function Import-MetadataFromCSV {
    Render-PanelHeader -Title "Import Metadata from CSV"

    $folder = Get-Item ".\Exports\" | Get-ChildItem -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $folder) {
Write-Log -Message "No export folder found." -Level 'WARN'
        return
    }

    $csvFiles = Get-ChildItem $folder.FullName -Filter "Template-*.csv"
    if (-not $csvFiles) {
Write-Log -Message "No metadata template CSV files found." -Level 'WARN'
        return
    }

    $file = $csvFiles | Out-GridView -Title "Select a CSV file to import" -PassThru
    if (-not $file) { return }

    switch -Wildcard ($file.Name) {
        "Template-Pathways.csv" {
            $data = Import-Csv -Path $file.FullName
            $data | ConvertTo-Json -Depth 5 | Set-Content ".\Metadata\Pathways.json"
Write-Log -Message "Imported Pathways from CSV." -Level 'INFO'
            Write-Log "Imported Pathways metadata from $($file.Name)"
        }
        "Template-DeskRoles.csv" {
            $data = Import-Csv -Path $file.FullName
            $data | ConvertTo-Json -Depth 5 | Set-Content ".\Metadata\DeskRoles.json"
Write-Log -Message "Imported Desk Roles from CSV." -Level 'INFO'
            Write-Log "Imported DeskRoles metadata from $($file.Name)"
        }
        default {
Write-Log -Message "Unsupported template format." -Level 'WARN'
        }
    }
}
Import-MetadataFromCSV
