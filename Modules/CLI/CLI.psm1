<#
.SYNOPSIS
    CLI module: menu rendering, prompts, CLI output formatting for OfficeSpaceManager.
.DESCRIPTION
    Provides functions for rendering CLI panels, showing action history, and generating secure passwords for resource creation. Ensures all CLI logic is modular, maintainable, and auditable.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

function Display-PanelHeader {
    <#
    .SYNOPSIS
        Renders a stylized panel header for CLI menus.
    .PARAMETER Title
        [string] The title to display in the header (default: "Main Menu").
    .EXAMPLE
        Display-PanelHeader -Title "Resource Management"
    .OUTPUTS
        None. Writes to console.
    #>
    param (
        [string]$Title = "Main Menu"
    )
    $padding = 2
    $width = $Title.Length + ($padding * 2)
    $top = "╔" + ("═" * $width) + "╗"
    $middle = "║" + (" " * $padding) + $Title + (" " * $padding) + "║"
    $bottom = "╚" + ("═" * $width) + "╝"
    Write-Host ""
    Write-Host $top -ForegroundColor Cyan
    Write-Host $middle -ForegroundColor Cyan
    Write-Host $bottom -ForegroundColor Cyan
    Write-Host ""
}

function Display-ActionHistory {
    <#
    .SYNOPSIS
        Displays the last 5 actions from today's log file in a stylized box.
    .DESCRIPTION
        Reads the daily log file and prints the last 5 actions in a formatted box.
    .OUTPUTS
        None. Writes to console.
    .EXAMPLE
        Display-ActionHistory
    #>
    $logDir = Join-Path $PSScriptRoot "..\Logs"
    $logFile = Join-Path $logDir ("Log_" + (Get-Date -Format "yyyyMMdd") + ".log")
    if (-not (Test-Path $logFile)) {
        Write-Host "`n(No log entries found for today.)`n" -ForegroundColor DarkGray
        return
    }
    $lines = Get-Content $logFile | Where-Object { $_.Trim() -ne "" }
    if ($lines.Count -eq 0) {
        Write-Host "`n(No log entries found for today.)`n" -ForegroundColor DarkGray
        return
    }
    Write-Host "`n╔══════════ Recent Actions ══════════╗" -ForegroundColor DarkGray
    $lines | Select-Object -Last 5 | ForEach-Object {
        Write-Host "• $_" -ForegroundColor Gray
    }
    Write-Host "╚════════════════════════════════════╝`n" -ForegroundColor DarkGray
}

function New-SecurePassword {
    <#
    .SYNOPSIS
        Generates a secure random password for resource creation.
    .DESCRIPTION
        Creates a 14-character password with upper/lowercase, digits, and symbols. Avoids repeated or sequential characters.
    .OUTPUTS
        [string] Secure password.
    .EXAMPLE
        $pwd = New-SecurePassword
    #>
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%^&*'
    do {
        $pwd = -join ((65..90) + (97..122) + (48..57) + 33..47 | Get-Random -Count 14 | ForEach-Object { [char]$_ })
    } while (
        $pwd -notmatch '[A-Z]' -or
        $pwd -notmatch '[a-z]' -or
        $pwd -notmatch '[0-9]' -or
        $pwd -notmatch '[\!\@\#\$\%\^\&\*]' -or
        $pwd -match '(.)\1{2,}' -or
        $pwd -match '(012|123|234|345|456|567|678|789)'
    )
    return $pwd
}

Export-ModuleMember -Function Display-PanelHeader, Display-ActionHistory, New-SecurePassword
