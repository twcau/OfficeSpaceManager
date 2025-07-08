<#
.SYNOPSIS
    Provides structured timestamped logging with optional severity indicators.
.DESCRIPTION
    Appends logs to the daily log file under .\Logs\, and prints to console.
#>

function Write-Log {
    param (
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $prefix = switch ($Level) {
        "INFO"  { "ℹ️" }
        "WARN"  { "⚠️" }
        "ERROR" { "❌" }
        "DEBUG" { "🐛" }
        default { "📝" }
    }

    $line = "$timestamp [$Level] $Message"
    $logDir = Join-Path $PSScriptRoot "..\Logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $logPath = Join-Path $logDir ("Log_" + (Get-Date -Format "yyyyMMdd") + ".log")
    Add-Content -Path $logPath -Value $line

    $color = switch ($Level) {
        "INFO"  { "White" }
        "WARN"  { "Yellow" }
        "ERROR" { "Red" }
        "DEBUG" { "DarkCyan" }
        default { "Gray" }
    }

    Write-Host "$prefix $line" -ForegroundColor $color
}
