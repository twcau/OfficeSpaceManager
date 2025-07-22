# Load Shared Connection Logic
. "$PSScriptRoot/../Shared/Global-ErrorHandling.ps1"
. "C:\Users\pc\Documents\GitProjects\OfficeSpaceManager\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    return
}

function Cleanup-TestResources {
    Render-PanelHeader -Title "Cleanup: Test Resources"

    $mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.Alias -like "TEST_*" }
    if ($mailboxes.Count -eq 0) {
Write-Log -Message "No test mailboxes found." -Level 'INFO'
        return
    }

    foreach ($mb in $mailboxes) {
Write-Log -Message "Removing test mailbox: $($mb.Alias)" -Level 'INFO'
        Remove-Mailbox -Identity $mb.Alias -Confirm:$false
    }

    # Remove test metadata if present
    $metaPath = ".\Metadata\DeskDefinitions.json"
    if (Test-Path $metaPath) {
        $desks = Get-Content $metaPath | ConvertFrom-Json
        $filtered = $desks | Where-Object { $_.DeskId -notlike "TEST_*" }
        $filtered | ConvertTo-Json -Depth 4 | Set-Content $metaPath
    }

Write-Log -Message "Cleanup complete." -Level 'INFO'
    Write-Log "All test resources cleaned from Exchange and metadata."
}
Cleanup-TestResources




