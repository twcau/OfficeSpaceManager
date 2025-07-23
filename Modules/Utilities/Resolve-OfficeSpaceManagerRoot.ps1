<#!
.SYNOPSIS
    Robustly resolves the OfficeSpaceManager project root and sets $env:OfficeSpaceManagerRoot.
.DESCRIPTION
    Searches upwards from the current script location for a known anchor file (README.md or .git) to reliably set the project root. Use this at the top of any script that needs robust module importing.
#>

function Resolve-OfficeSpaceManagerRoot {
    param(
        [string]$AnchorFile = 'README.md'
    )
    $current = $PSScriptRoot
    while ($current -and !(Test-Path (Join-Path $current $AnchorFile)) -and !(Test-Path (Join-Path $current '.git'))) {
        $parent = Split-Path $current -Parent
        if ($parent -eq $current) { break }
        $current = $parent
    }
    if ($current -and ((Test-Path (Join-Path $current $AnchorFile)) -or (Test-Path (Join-Path $current '.git')))) {
        $env:OfficeSpaceManagerRoot = $current
        return $current
    } else {
        throw "Unable to resolve OfficeSpaceManager project root. Anchor file not found."
    }
}

# Call the function to set the variable if not already set
if (-not $env:OfficeSpaceManagerRoot) {
    Resolve-OfficeSpaceManagerRoot | Out-Null
}
