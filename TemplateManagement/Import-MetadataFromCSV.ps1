function Import-MetadataFromCSV {
    Render-PanelHeader -Title "Import Metadata from CSV"

    $folder = Get-Item ".\Exports\" | Get-ChildItem -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $folder) {
        Write-Warning "No export folder found."
        return
    }

    $csvFiles = Get-ChildItem $folder.FullName -Filter "Template-*.csv"
    if (-not $csvFiles) {
        Write-Warning "No metadata template CSV files found."
        return
    }

    $file = $csvFiles | Out-GridView -Title "Select a CSV file to import" -PassThru
    if (-not $file) { return }

    switch -Wildcard ($file.Name) {
        "Template-Pathways.csv" {
            $data = Import-Csv -Path $file.FullName
            $data | ConvertTo-Json -Depth 5 | Set-Content ".\Metadata\Pathways.json"
            Write-Host "✅ Imported Pathways from CSV."
            Write-Log "Imported Pathways metadata from $($file.Name)"
        }
        "Template-DeskRoles.csv" {
            $data = Import-Csv -Path $file.FullName
            $data | ConvertTo-Json -Depth 5 | Set-Content ".\Metadata\DeskRoles.json"
            Write-Host "✅ Imported Desk Roles from CSV."
            Write-Log "Imported DeskRoles metadata from $($file.Name)"
        }
        default {
            Write-Warning "⚠️ Unsupported template format."
        }
    }
}
Import-MetadataFromCSV
