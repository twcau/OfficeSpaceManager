function Export-MetadataTemplates {
    Render-PanelHeader -Title "Export Metadata Templates"

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
Export-MetadataTemplates
