<#
.SYNOPSIS
    Simulates a booking by validating mail flow and calendar processing.
.DESCRIPTION
    Verifies whether the resource mailbox is healthy, auto-accepting,
    and ready for meeting bookings via Exchange Online.
#>

# Load Shared Connection Logic
. "$PSScriptRoot\..\Shared\Connect-ExchangeAdmin.ps1"
$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Warning "⚠️ Skipping resource sync: unable to authenticate with Exchange Online."
    return
}

    [string]$Alias,
    [string]$Domain
)

$upn = "$Alias@$Domain"
Write-Host "`nðŸ“… Simulating booking test for: $upn" -ForegroundColor Cyan
Write-Log "Starting booking simulation for $upn"

$results = [PSCustomObject]@{
    Resource      = $upn
    MailboxFound  = $false
    AutoAccept    = $false
    MailFlowOK    = $false
    Timestamp     = (Get-Date)
    Notes         = ""
}

try {
    $mailbox = Get-Mailbox -Identity $upn -ErrorAction Stop
    $results.MailboxFound = $true
    Write-Host "âœ”ï¸ Mailbox exists and is reachable." -ForegroundColor Green
    Write-Log "Mailbox $upn found."

    $calendarSettings = Get-CalendarProcessing -Identity $upn -ErrorAction Stop

    if ($calendarSettings.AutomateProcessing -eq 'AutoAccept') {
        $results.AutoAccept = $true
        Write-Host "âœ”ï¸ Calendar processing is set to AutoAccept." -ForegroundColor Green
        Write-Log "Calendar processing for $upn is AutoAccept."
    } else {
        $results.Notes += "AutomateProcessing is set to '$($calendarSettings.AutomateProcessing)'. "
        Write-Warning "âš ï¸ Calendar processing is not AutoAccept: $($calendarSettings.AutomateProcessing)"
        Write-Log "Calendar processing mismatch for $upn."
    }

    Write-Host "`nðŸ“¬ Running mail flow test..." -ForegroundColor Cyan
    $test = Test-MailFlow -TargetEmailAddress $upn -ErrorAction Stop

    if ($test.TestResult -eq 'Success') {
        $results.MailFlowOK = $true
        Write-Host "âœ”ï¸ Mail flow is working." -ForegroundColor Green
        Write-Log "Test-MailFlow to $upn passed."
    } else {
        $results.Notes += "Mail flow failed: $($test.Message)"
        Write-Warning "âŒ Mail flow test failed: $($test.Message)"
        Write-Log "Mail flow to $upn failed: $($test.Message)"
    }

} catch {
    $results.Notes += $_.Exception.Message
    Write-Warning "âŒ Simulation failed: $_"
    Write-Log "Booking simulation failed for $upn: $_"
}

# Output result and log it
Write-Host "`nðŸ“Š Simulation Summary:`n" -ForegroundColor Cyan
$results | Format-List

Write-Log "Booking simulation results: $(ConvertTo-Json $results -Compress)"
return $results
