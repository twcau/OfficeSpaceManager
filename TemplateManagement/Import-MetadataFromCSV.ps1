<#
.SYNOPSIS
    Imports pathway and desk role metadata from CSV templates into local metadata storage.
.DESCRIPTION
    This script allows the user to select a pathway or desk role template CSV file from the most recent export folder and imports its contents into the appropriate local metadata JSON file. Logs all actions and provides feedback on success or failure.
.FILECREATED
    2023-07-01
.FILELASTUPDATED
    2025-07-23
.OUTPUTS
    Updates local metadata JSON files based on imported CSV data.
.EXAMPLE
    .\Import-MetadataFromCSV.ps1
    # Imports selected pathway or desk role template from the latest export folder.
.DOCUMENTATION Import-Csv
    https://learn.microsoft.com/en-au/powershell/module/microsoft.powershell.utility/import-csv
#>

# Import global error handling and logging
. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"

function Import-MetadataFromCSV {
    <#
    .SYNOPSIS
        Main function to import pathway and desk role metadata from CSV.
    .DESCRIPTION
        Allows user to select a template CSV from the latest export folder and imports it into the correct metadata store.
    .OUTPUTS
        None. Updates local JSON files.
    #>
    Display-PanelHeader -Title "Import Metadata from CSV"

    # Get the most recent export folder
    $folder = Get-Item ".\Exports\" | Get-ChildItem -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $folder) {
        Write-Log -Message "No export folder found." -Level 'WARN'
        return
    }

    # Get all CSV files in the folder that match the template pattern
    $csvFiles = Get-ChildItem $folder.FullName -Filter "Template-*.csv"
    if (-not $csvFiles) {
        Write-Log -Message "No metadata template CSV files found." -Level 'WARN'
        return
    }

    # Prompt the user to select a CSV file
    $file = $csvFiles | Out-GridView -Title "Select a CSV file to import" -PassThru
    if (-not $file) { return }

    # Import the selected CSV file based on its template type
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

# Call the main function
Import-MetadataFromCSV
