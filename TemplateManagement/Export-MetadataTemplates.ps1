<#
.SYNOPSIS
    Exports pathway and desk role metadata templates to a date-stamped folder for bulk import.
.DESCRIPTION
    This script exports pathway and desk role templates as CSV files, providing sample data for each. The output is placed in a date-stamped folder under .\Exports. Intended for use in bulk import or as a template reference.
.FILECREATED
    2023-07-01
.FILELASTUPDATED
    2025-07-23
.OUTPUTS
    CSV files for Pathways and DeskRoles in the .\Exports\<date> folder.
.EXAMPLE
    .\Export-MetadataTemplates.ps1
    # Exports pathway and desk role templates to a new folder under .\Exports
.DOCUMENTATION Export-Csv
    https://learn.microsoft.com/en-au/powershell/module/microsoft.powershell.utility/export-csv
#>

# Import global error handling and reporting module
. (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Logging/GlobalErrorHandling.ps1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Reporting/Reporting.psm1') -Force

function Export-MetadataTemplates {
    <#
    .SYNOPSIS
        Main function to export pathway and desk role templates.
    .DESCRIPTION
        Handles folder creation and exports sample pathway and desk role templates to CSV.
    .OUTPUTS
        None. Writes CSV files to disk.
    #>
    Display-PanelHeader -Title "Export Metadata Templates"

    $exportDate = Get-Date -Format 'yyyy-MM-dd'
    $exportFolder = ".\Exports\$exportDate"
    if (!(Test-Path $exportFolder)) { New-Item -ItemType Directory -Path $exportFolder | Out-Null }

    # Pathways Template
    $pathwayTemplate = @()
    $pathwayTemplate += [PSCustomObject]@{
        PathwayCode = "FIN"
        PathwayName = "Finance"
    }
    $pathwayTemplate | Export-Csv -Path "$exportFolder\Template-Pathways.csv" -NoTypeInformation

    # Desk Roles Template
    $roleTemplate = @()
    $roleTemplate += [PSCustomObject]@{
        RoleName = "ICT Support Analyst"
    }
    $roleTemplate | Export-Csv -Path "$exportFolder\Template-DeskRoles.csv" -NoTypeInformation

    Write-Host "`n✅ Templates exported to: $exportFolder"
    Write-Log "Exported metadata templates to $exportFolder"
}

# Call the main function
Export-MetadataTemplates
