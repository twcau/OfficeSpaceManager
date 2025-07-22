<#
.SYNOPSIS
    Finds and optionally refactors direct Write-Host, Write-Error, and Write-Warning calls to use Write-Log in the project, ensuring consistent log levels and removal of redundant icons/colors.
.DESCRIPTION
    - Backs up all files to be changed into \Backups\RefactorLogging_<timestamp>\ at the project root, preserving folder structure.
    - Prompts for approval before changing each file, showing before/after for each line.
    - Creates a detailed change log (ChangeLog.csv) in the backup folder.
    - Zips the backup folder and removes the unzipped backup after completion.
    - Provides a summary of changes and backup location.
.NOTES
    Run from anywhere; specify -ProjectRoot if not running from project root.
#>

param (
    [string]$ProjectRoot = (Resolve-Path (git rev-parse --show-toplevel 2>$null) | Select-Object -First 1).Path,
    [string]$BackupRoot = "Backups"
)

if (-not $ProjectRoot -or -not (Test-Path (Join-Path $ProjectRoot ".gitignore"))) {
    Write-Host "Could not determine project root. Please specify -ProjectRoot pointing to the root of your repository." -ForegroundColor Red
    exit 1
}

# --- Parse .gitignore for ignore patterns ---
$gitignorePath = Join-Path $ProjectRoot ".gitignore"
$ignorePatterns = @()
if (Test-Path $gitignorePath) {
    # Read .gitignore, skipping comments and blank lines
    $ignorePatterns = Get-Content $gitignorePath | Where-Object {
        $_ -and -not ($_ -match '^\s*#') -and -not ($_ -match '^\s*$')
    }
}

# --- Helper: Check if a path should be ignored based on .gitignore patterns ---
function Test-IsIgnored {
    param (
        [string]$Path
    )
    foreach ($pattern in $ignorePatterns) {
        $wildcard = $pattern -replace '/', '\'
        if ($wildcard.StartsWith("*")) { $wildcard = "*$($wildcard.TrimStart("*"))" }
        if ($Path -like "*$wildcard*") { return $true }
    }
    return $false
}

# --- Helper: Map Write-Host -ForegroundColor to Write-Log -Level ---
function Get-LogLevelFromHostLine {
    param (
        [string]$line
    )
    if ($line -match '-ForegroundColor\s+Yellow') { return 'WARN' }
    if ($line -match '-ForegroundColor\s+Red') { return 'ERROR' }
    if ($line -match '-ForegroundColor\s+Green') { return 'INFO' }
    if ($line -match '-ForegroundColor\s+DarkCyan') { return 'DEBUG' }
    return 'INFO'
}

# --- Helper: Remove color switches, quotes, and leading icons/emoji from messages ---
function CleanMessage {
    param (
        [string]$msg
    )
    $msg = $msg -replace '-ForegroundColor\s+\w+', ''
    $msg = $msg.Trim()
    if ($msg.StartsWith('"') -and $msg.EndsWith('"')) {
        $msg = $msg.Substring(1, $msg.Length - 2)
    }
    $msg = $msg -replace '^[\s`"]*[\p{So}\p{Sk}\p{Cn}\p{Zs}\p{C}]+', ''
    $msg = $msg -replace '^[^A-Za-z0-9]+', ''
    return $msg
}

# --- Helper: Remove known emoji/icons from the start of a message ---
function RemoveKnownIcons {
    param (
        [string]$msg
    )
    $icons = @("⚠️", "❌", "ℹ️", "🐛")
    foreach ($icon in $icons) {
        if ($msg.TrimStart().StartsWith($icon)) {
            $msg = $msg.TrimStart().Substring($icon.Length).TrimStart()
        }
    }
    return $msg
}

# --- Helper: Detect if a Write-Host line is a CLI menu/header/visual element ---
# --- Helper: Detect if a Write-Host line is a CLI menu/header/visual element ---
function IsCliMenuOrVisualLine {
    param (
        [string]$line,
        [string]$file
    )
    $excludedFiles = @('Write-Log.ps1', 'LogRefactor.ps1')
    if ($excludedFiles -contains ([System.IO.Path]::GetFileName($file))) { return $true }

    # Visual lines (boxes, separators, bullets, emoji, etc)
    if ($line -match '^\s*Write-Host\s*("[\s╔═╗╚╝╠╣─│•—━═]+")?\s*-?ForegroundColor\s+\w+\s*$') { return $true }
    if ($line -match '^\s*Write-Host\s*""\s*$') { return $true }
    if ($line -match '^\s*Write-Host\s*"\s*"\s*$') { return $true }
    if ($line -match '^\s*Write-Host\s*"`n[^\"]*"\s*-?ForegroundColor\s+\w+\s*$') { return $true }
    if ($line -match '^\s*Write-Host\s*"`n[^\"]*"$') { return $true }
    if ($line -match '^\s*Write-Host\s*"\s*[•╔═╗╚╝╠╣─│—━═]+"') { return $true }

    # Lines starting with a bullet, box drawing char, emoji, or special symbol (e.g. "• $_", "╚══════", "🏢 Building: ...", "▸ Floor ...")
    if ($line -match '^\s*Write-Host\s*"\s*[\p{So}\p{Sk}•▸▶►▪▫➤➔➣➢➥➦➧➨➩➪➫➬➭➮➯➱➲➳➴➵➶➷➸➹➺➻➼➽➾➿🏢🗄️🗃️🗂️📁📂].*') { return $true }

    # Menu options: e.g. "[1.1] Option", "  [2.3] Something", "[4.5] ...", "[6.4] ..."
    if ($line -match '^\s*Write-Host\s*"\s*\[\d+(\.\d+)*\]\s*.+?"') { return $true }
    if ($line -match '^\s*Write-Host\s*"\s*\d+(\.\d+)*\.\s*.+?"') { return $true }
    if ($line -match '^\s*Write-Host\s*"\s*\d+(\.\d+)*\]\s*.+?"') { return $true }

    # Summary/column lines: e.g. "  Desks:      $($desks.Count)"
    if ($line -match '^\s*Write-Host\s*"\s*[A-Za-z ]+:\s*\$?\(.+\)"') { return $true }

    # Indented lines with a word and colon (e.g. "  Building: ...")
    if ($line -match '^\s*Write-Host\s*"\s+[A-Za-z0-9 ]+:\s*.+') { return $true }

    # Variable-based visual lines
    if ($line -match '^\s*Write-Host\s*\$[a-zA-Z_][a-zA-Z0-9_]*\s*-?ForegroundColor\s+\w+\s*$') { return $true }

    # Write-Host with variable ForegroundColor (e.g. -ForegroundColor $color)
    if ($line -match '^\s*Write-Host\s+.*-ForegroundColor\s+\$[a-zA-Z_][a-zA-Z0-9_]*') { return $true }

    # Generic menu/visual patterns (lines, boxes, etc)
    if ($line -match '^\s*Write-Host\s*"\s*[A-Za-z0-9\.\[\]\(\)\-\/ ]+\s*"\s*-?ForegroundColor\s+\w+\s*$') { return $true }

    return $false
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFolder = Join-Path $ProjectRoot "$BackupRoot\RefactorLogging_$timestamp"

# --- Find all .ps1 files not ignored by .gitignore or excluded folders ---
$filesToScan = Get-ChildItem -Path $ProjectRoot -Recurse -Include *.ps1 | Where-Object {
    $_.FullName -notmatch '\\Backups\\' -and $_.FullName -notmatch '\\Logs\\' -and -not (Test-IsIgnored $_.FullName)
}

$changeSummary = @()
$anyChanged = $false
$changeLog = @()

foreach ($file in $filesToScan) {
    $content = Get-Content $file.FullName
    $foundLines = @()
    for ($i = 0; $i -lt $content.Count; $i++) {
        $original = $content[$i]
        $replacement = $null

        # --- Only refactor Write-Host if NOT a CLI menu/header/visual element or excluded file ---
        if ($original -match '^\s*Write-Host\s+' -and -not (IsCliMenuOrVisualLine $original $file.FullName)) {
            $level = Get-LogLevelFromHostLine $original
            $msg = $original -replace '^\s*Write-Host\s+', ''
            $msg = CleanMessage $msg
            $msg = RemoveKnownIcons $msg
            $replacement = "Write-Log -Message `"$msg`" -Level '$level'"
        }
        elseif ($original -match '^\s*Write-Error\s+') {
            $msg = $original -replace '^\s*Write-Error\s+', ''
            $msg = CleanMessage $msg
            $msg = RemoveKnownIcons $msg
            $replacement = "Write-Log -Message `"$msg`" -Level 'ERROR'"
        }
        elseif ($original -match '^\s*Write-Warning\s+') {
            $msg = $original -replace '^\s*Write-Warning\s+', ''
            $msg = CleanMessage $msg
            $msg = RemoveKnownIcons $msg
            $replacement = "Write-Log -Message `"$msg`" -Level 'WARN'"
        }

        if ($replacement) {
            $foundLines += [PSCustomObject]@{
                LineNumber  = $i + 1
                Original    = $original
                Replacement = $replacement
            }
        }
    }

    if ($foundLines.Count -gt 0) {
        Write-Host "`nFound direct output in $($file.FullName):" -ForegroundColor Yellow
        foreach ($line in $foundLines) {
            Write-Host ("  [$($line.LineNumber)] " + $line.Original) -ForegroundColor Cyan
            Write-Host ("    Will be replaced with: " + $line.Replacement) -ForegroundColor Green
        }
        $approve = $null
        while ($null -eq $approve) {
            $input = Read-Host "Refactor this file to use Write-Log? (y/n/x to exit)"
            if ($input -eq 'y' -or $input -eq 'n' -or $input -eq 'x') {
                $approve = $input
            }
            else {
                Write-Host "Please enter y (yes), n (no), or x (exit)." -ForegroundColor Yellow
            }
        }
        foreach ($line in $foundLines) {
            $changeLog += [PSCustomObject]@{
                File        = $file.FullName.Substring($ProjectRoot.Length).TrimStart('\', '/')
                LineNumber  = $line.LineNumber
                Original    = $line.Original
                Approved    = $approve -eq 'y'
                Replacement = $approve -eq 'y' ? $line.Replacement : ''
            }
        }
        if ($approve -eq 'y') {
            $relPath = $file.FullName.Substring($ProjectRoot.Length).TrimStart('\', '/')
            $backupPath = Join-Path $backupFolder $relPath
            $backupDir = Split-Path $backupPath
            if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }
            Copy-Item $file.FullName $backupPath -Force

            for ($i = 0; $i -lt $content.Count; $i++) {
                $original = $content[$i]
                $replacement = $null
                if ($original -match '^\s*Write-Host\s+' -and -not (IsCliMenuOrVisualLine $original)) {
                    $level = Get-LogLevelFromHostLine $original
                    $msg = $original -replace '^\s*Write-Host\s+', ''
                    $msg = CleanMessage $msg
                    $msg = RemoveKnownIcons $msg
                    $content[$i] = "Write-Log -Message `"$msg`" -Level '$level'"
                }
                elseif ($original -match '^\s*Write-Error\s+') {
                    $msg = $original -replace '^\s*Write-Error\s+', ''
                    $msg = CleanMessage $msg
                    $msg = RemoveKnownIcons $msg
                    $content[$i] = "Write-Log -Message `"$msg`" -Level 'ERROR'"
                }
                elseif ($original -match '^\s*Write-Warning\s+') {
                    $msg = $original -replace '^\s*Write-Warning\s+', ''
                    $msg = CleanMessage $msg
                    $msg = RemoveKnownIcons $msg
                    $content[$i] = "Write-Log -Message `"$msg`" -Level 'WARN'"
                }
            }
            Set-Content $file.FullName $content -Encoding UTF8
            $changeSummary += $file.FullName
            $anyChanged = $true
            Write-Host "Refactored and backed up: $($file.FullName)" -ForegroundColor Green
        }
        elseif ($approve -eq 'n') {
            Write-Host "Skipped: $($file.FullName)" -ForegroundColor DarkGray
        }
        elseif ($approve -eq 'x') {
            Write-Host "Exiting as requested. Finalizing backup and logs..." -ForegroundColor Yellow
            break
        }
    }
    if ($approve -eq 'x') { break }
}

# --- Write change log to backup folder ---
if ($changeLog.Count -gt 0) {
    if (-not (Test-Path $backupFolder)) { New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null }
    $changeLog | Export-Csv -Path (Join-Path $backupFolder "ChangeLog.csv") -NoTypeInformation -Encoding UTF8
}

# --- Zip backup folder and clean up ---
$changeLogPath = Join-Path $backupFolder "ChangeLog.csv"
if ((Test-Path $backupFolder) -and (Test-Path $changeLogPath)) {
    $zipPath = "$backupFolder.zip"
    Write-Host "`nZipping backup folder to $zipPath..." -ForegroundColor Yellow
    Compress-Archive -Path $backupFolder -DestinationPath $zipPath -Force
    Remove-Item $backupFolder -Recurse -Force
    Write-Host "Backup zipped and original backup folder removed." -ForegroundColor Green
}

# --- Summary output ---
Write-Host "`nRefactor complete. Changed files:" -ForegroundColor White
$changeSummary | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
if ($anyChanged) {
    Write-Host "Backup archive: $zipPath" -ForegroundColor White
    Write-Host "Change log: $($zipPath -replace '\.zip$', '\ChangeLog.csv')" -ForegroundColor White
}
Write-Host "Review changes and test scripts before deploying to production." -ForegroundColor Yellow