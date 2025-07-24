<#
.SYNOPSIS
    Simulates a booking by validating mail flow and calendar processing for a resource mailbox.
.DESCRIPTION
    This script verifies whether a resource mailbox is healthy, auto-accepting, and ready for meeting bookings via Exchange Online. It checks mailbox existence, calendar processing settings, and mail flow using Test-MailFlow.
.FILECREATED
    2023-07-01
.FILELASTUPDATED
    2025-07-23
.OUTPUTS
    Test results as a custom object and log entries.
.EXAMPLE
    .\Run-BookingSimulation.ps1 -Alias "FREFRE01SD17ICT" -Domain "contoso.com"
    # Simulates a booking test for the specified resource mailbox.
.DOCUMENTATION Test-MailFlow
    https://learn.microsoft.com/en-au/powershell/module/exchange/test-mailflow
#>

. (Join-Path $PSScriptRoot '..\Modules\Utilities\Resolve-OfficeSpaceManagerRoot.ps1')
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Utilities/Utilities.psm1')

# Import Connections module for robust service connections
Import-Module (Join-Path $env:OfficeSpaceManagerRoot 'Modules/Connections/Connections.psm1') -Force

# Load Shared Connection Logic
$admin = Connect-ExchangeAdmin
if (-not $admin) {
    Write-Log -Message "Skipping resource sync: unable to authenticate with Exchange Online." -Level 'WARN'
    Read-Host "Press Enter to continue..."
    return
}

# Accept parameters for alias and domain
param(
    [Parameter(Mandatory = $true)]
    [string]$Alias,
    [Parameter(Mandatory = $true)]
    [string]$Domain
)

$upn = "$Alias@$Domain"
Write-Host "`n4d3 Simulating booking test for: $upn" -ForegroundColor Cyan
Write-Log "Starting booking simulation for $upn"

$results = [PSCustomObject]@{
    Resource     = $upn
    MailboxFound = $false
    AutoAccept   = $false
    MailFlowOK   = $false
    Timestamp    = (Get-Date)
    Notes        = ""
}

try {
    $mailbox = Get-Mailbox -Identity $upn -ErrorAction Stop
    $results.MailboxFound = $true
    Write-Log -Message "Mailbox exists and is reachable." -Level 'INFO'
    Write-Log "Mailbox $upn found."

    $calendarSettings = Get-CalendarProcessing -Identity $upn -ErrorAction Stop
    if ($calendarSettings.AutomateProcessing -eq 'AutoAccept') {
        $results.AutoAccept = $true
        Write-Log -Message "Calendar processing is set to AutoAccept." -Level 'INFO'
        Write-Log "Calendar processing for $upn is AutoAccept."
    }
    else {
        $results.Notes += "AutomateProcessing is set to '$($calendarSettings.AutomateProcessing)'. "
        Write-Log -Message "Calendar processing is not AutoAccept: $($calendarSettings.AutomateProcessing)" -Level 'WARN'
        Write-Log "Calendar processing mismatch for $upn."
    }

    Write-Host "`n4d3 Running mail flow test..." -ForegroundColor Cyan
    $test = Test-MailFlow -TargetEmailAddress $upn -ErrorAction Stop
    if ($test.TestResult -eq 'Success') {
        $results.MailFlowOK = $true
        Write-Log -Message "Mail flow is working." -Level 'INFO'
        Write-Log "Test-MailFlow to $upn passed."
    }
    else {
        $results.Notes += "Mail flow test failed. "
        Write-Log -Message "Mail flow test failed for $upn." -Level 'WARN'
    }
}
catch {
    $results.Notes += $_.Exception.Message
    Write-Log -Message "Booking simulation failed: $_" -Level 'ERROR'
}

$results | Format-List | Out-String | Write-Host
Write-Log "Booking simulation results: $($results | ConvertTo-Json -Depth 4)"




