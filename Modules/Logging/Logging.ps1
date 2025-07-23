<#
.SYNOPSIS
    Provides structured timestamped logging with optional severity indicators.
.DESCRIPTION
    Appends logs to the daily log file under .\Logs\, and prints to console. Supports log levels and colour-coded output.
.FILECREATED
    2023-12-01
.FILELASTUPDATED
    2025-07-23
#>

function Write-Log {
    <#
    .SYNOPSIS
        Write a log entry to the daily log file and console with timestamp and severity.
    .DESCRIPTION
        Appends a log message to the log file in .\Logs\ and prints to the console. Supports log levels (INFO, WARN, ERROR, DEBUG) with colour-coded output and emoji prefix.
    .PARAMETER Message
        [string] The message to log. Required.
    .PARAMETER Level
        [string] The severity level (INFO, WARN, ERROR, DEBUG). Default is INFO.
    .EXAMPLE
        Write-Log -Message "Operation completed successfully." -Level "INFO"
    .EXAMPLE
        Write-Log -Message "An error occurred." -Level "ERROR"
    .OUTPUTS
        None. Writes to log file and console.
    #>
    param (
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )

    # Get timestamp and emoji prefix for log level
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $prefix = switch ($Level) {
        "INFO" { "ℹ️" }
        "WARN" { "⚠️" }
        "ERROR" { "❌" }
        "DEBUG" { "🐛" }
        default { "📝" }
    }

    $line = "$timestamp [$Level] $Message"
    $logDir = Join-Path $PSScriptRoot "..\..\Logs"
    if (-not (Test-Path $logDir)) {
        # Create log directory if it doesn't exist
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $logPath = Join-Path $logDir ("Log_" + (Get-Date -Format "yyyyMMdd") + ".log")
    Add-Content -Path $logPath -Value $line

    $color = switch ($Level) {
        "INFO" { "White" }
        "WARN" { "Yellow" }
        "ERROR" { "Red" }
        "DEBUG" { "DarkCyan" }
        default { "Gray" }
    }

    Write-Host "$prefix $line" -ForegroundColor $color
}
