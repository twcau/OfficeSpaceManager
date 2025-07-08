
<#
.SYNOPSIS
    Automatically validates and fixes incorrect dot-sourced paths across a PowerShell project.
.DESCRIPTION
    Recursively scans all .ps1 files, identifies invalid dot-sourcing, suggests replacements,
    performs backup and logging, and finishes with re-validation to ensure success.
.TODO
    Remove File Folder after .zip file is made
    Consider if an integrity check should be performed on the .zip file before deleting the file folder, to ensure nothing is missed.
#>

$projectRoot = (Get-Location).Path
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupPath = Join-Path $projectRoot "Backups\DotSourceFix_$timestamp"
$logFile = Join-Path $backupPath "FixLog.txt"

New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
"`nFix Log for Dot-Sourcing Issues ($timestamp)`n" | Set-Content $logFile

# Get all .ps1 files recursively excluding backups and logs
$allScripts = Get-ChildItem -Recurse -Filter *.ps1 | Where-Object {
    $_.FullName -notmatch '\\Backups\\' -and $_.FullName -notmatch '\\Logs\\'
}

Write-Host "`nScanning for .ps1 scripts recursively..." -ForegroundColor Cyan

foreach ($script in $allScripts) {
    $scriptPath = $script.FullName
    $lines = Get-Content -Path $scriptPath -Raw -Encoding UTF8 -ErrorAction Stop
    $lineList = $lines -split "`r?`n"
    $original = $lineList.Clone()
    $modified = $false
    $relativeScriptPath = $scriptPath.Replace($projectRoot, ".")

    for ($i = 0; $i -lt $lineList.Count; $i++) {
        $line = $lineList[$i].Trim()
        $regex = [regex]::new('^\s*\.\s+["'']?\$PSScriptRoot[\\/](?<path>[^"'']+\.ps1)["'']?\s*$')

        if ($regex.IsMatch($line)) {
            $match = $regex.Match($line)
            $relativeDotPath = $match.Groups['path'].Value
            $fullDotPath = Join-Path -Path (Split-Path $scriptPath) -ChildPath $relativeDotPath

            if (-not (Test-Path $fullDotPath)) {
                Write-Host "`nFix required in: $relativeScriptPath" -ForegroundColor Yellow
                Write-Host "Could not resolve: `$PSScriptRoot\$relativeDotPath"

                $targetFile = Split-Path -Leaf $relativeDotPath
                $candidates = Get-ChildItem -Path $projectRoot -Recurse -Filter $targetFile |
                              Where-Object { $_.FullName -notmatch '\\Backups\\' }

                if ($candidates.Count -eq 0) {
                    Write-Host "No matching script found for '$targetFile'" -ForegroundColor Red
                    continue
                }

                Write-Host "Possible candidates:"
                for ($j = 0; $j -lt $candidates.Count; $j++) {
                    Write-Host "[$($j + 1)] $($candidates[$j].FullName)"
                }

                $choice = Read-Host "Choose correct file number to replace or press Enter to skip"
                if ([string]::IsNullOrWhiteSpace($choice)) { continue }

                [int]$selected = 0
                if ([int]::TryParse($choice, [ref]$selected) -and $selected -ge 1 -and $selected -le $candidates.Count) {
                    $resolvedPath = $candidates[$selected - 1].FullName
                    $absolutePath = (Resolve-Path $resolvedPath).Path
                    $replacement = ". `"$absolutePath`""
                    $lineList[$i] = $replacement
                    $modified = $true
                    "[$(Get-Date)] FIXED: $relativeDotPath => $absolutePath in $relativeScriptPath" | Add-Content $logFile
                } else {
                    Write-Host "Invalid selection. Skipping..." -ForegroundColor DarkYellow
                }
            }
        }
    }

    if ($modified) {
        $backupScriptPath = Join-Path $backupPath ($script.FullName.Replace($projectRoot, '') -replace '^[\\\/]', '')
        $backupScriptDir = Split-Path $backupScriptPath
        New-Item -ItemType Directory -Force -Path $backupScriptDir | Out-Null
        Copy-Item -Path $scriptPath -Destination $backupScriptPath -Force
        Set-Content -Path $scriptPath -Value ($lineList -join "`r`n") -Encoding UTF8
        Write-Host "Fixed dot-sourcing in: $relativeScriptPath" -ForegroundColor Green
    }
}

# Zip the backup
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipPath = "$backupPath.zip"
[System.IO.Compression.ZipFile]::CreateFromDirectory($backupPath, $zipPath)

# Final validation pass
Write-Host "`nValidating all dot-sourced script paths..." -ForegroundColor Cyan
$invalidPaths = @()

foreach ($script in $allScripts) {
    $scriptPath = $script.FullName
    $lines = Get-Content $scriptPath

    foreach ($line in $lines) {
        $regex = [regex]::new('^\s*\.\s+["'']?\$PSScriptRoot[\\/](?<path>[^"'']+\.ps1)["'']?\s*$')
        if ($regex.IsMatch($line)) {
            $relative = $regex.Match($line).Groups['path'].Value
            $resolved = Join-Path -Path (Split-Path $scriptPath) -ChildPath $relative
            if (-not (Test-Path $resolved)) {
                $invalidPaths += "$scriptPath => $relative"
            }
        }
    }
}

if ($invalidPaths.Count -eq 0) {
    Write-Host "`nAll dot-sourced paths validated successfully!" -ForegroundColor Green
} else {
    Write-Host "`nStill unresolved dot-source issues:" -ForegroundColor Red
    $invalidPaths | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
}

Write-Host "`nBackup saved to: $zipPath"
Write-Host "Detailed log: $logFile" -ForegroundColor Cyan
