function Cleanup-TestResources {
    Render-PanelHeader -Title "Cleanup: Test Resources"

    $mailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object { $_.Alias -like "TEST_*" }
    if ($mailboxes.Count -eq 0) {
        Write-Host "✅ No test mailboxes found."
        return
    }

    foreach ($mb in $mailboxes) {
        Write-Host "🧹 Removing test mailbox: $($mb.Alias)"
        Remove-Mailbox -Identity $mb.Alias -Confirm:$false
    }

    # Remove test metadata if present
    $metaPath = ".\Metadata\DeskDefinitions.json"
    if (Test-Path $metaPath) {
        $desks = Get-Content $metaPath | ConvertFrom-Json
        $filtered = $desks | Where-Object { $_.DeskId -notlike "TEST_*" }
        $filtered | ConvertTo-Json -Depth 4 | Set-Content $metaPath
    }

    Write-Host "✅ Cleanup complete."
    Write-Log "All test resources cleaned from Exchange and metadata."
}
Cleanup-TestResources
