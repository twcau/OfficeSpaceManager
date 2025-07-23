<#
.SYNOPSIS
    Removes all test resources (mailboxes and metadata) created for simulation/testing.
.DESCRIPTION
    This script removes all test mailboxes (aliases starting with TEST_) from Exchange Online and cleans up any test desk metadata from DeskDefinitions.json. Intended for use after running simulation or test suites to ensure a clean environment.
.FILECREATED
    2023-07-01
.FILELASTUPDATED
    2025-07-23
.OUTPUTS
    Removes test mailboxes and updates metadata JSON files.
.EXAMPLE
    .\Remove-TestResources.ps1
    # Removes all test mailboxes and test desk metadata.
.DOCUMENTATION Remove-Mailbox
    https://learn.microsoft.com/en-au/powershell/module/exchange/remove-mailbox
#>

# Load shared modules and error handling
. (Join-Path $PSScriptRoot '..\Modules\Utilities\Resolve-OfficeSpaceManagerRoot.ps1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\Utilities\Utilities.psm1')
. (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Logging/GlobalErrorHandling.ps1')

$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    Read-Host "Press Enter to continue..."
    return
}

Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules\CLI\CLI.psm1')

function Remove-TestResources {
    <#
    .SYNOPSIS
        Removes all test mailboxes and test desk metadata.
    .DESCRIPTION
        Finds and removes all mailboxes with aliases starting with TEST_ and cleans up test desk entries in DeskDefinitions.json.
    .OUTPUTS
        None. Updates Exchange and metadata files.
    #>
    Display-PanelHeader -Title "Cleanup: Test Resources"

    # Find and remove test mailboxes
    $mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.Alias -like "TEST_*" }
    if ($mailboxes.Count -eq 0) {
        Write-Log -Message "No test mailboxes found." -Level 'INFO'
        Read-Host "Press Enter to continue..."
        return
    }
    foreach ($mb in $mailboxes) {
        Write-Log -Message "Removing test mailbox: $($mb.Alias)" -Level 'INFO'
        Remove-Mailbox -Identity $mb.Alias -Confirm:$false
    }

    # Remove test desk metadata
    $metaPath = ".\Metadata\DeskDefinitions.json"
    if (Test-Path $metaPath) {
        $desks = Get-Content $metaPath | ConvertFrom-Json
        $filtered = $desks | Where-Object { $_.DeskId -notlike "TEST_*" }
        $filtered | ConvertTo-Json -Depth 4 | Set-Content $metaPath
    }

    Write-Log -Message "Cleanup complete." -Level 'INFO'
    Write-Log "All test resources cleaned from Exchange and metadata."
}

Remove-TestResources




