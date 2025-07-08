<#
.SYNOPSIS
    Standardizes dot-sourcing paths in PowerShell scripts.
.DESCRIPTION
    Updates inconsistent relative dot-sourcing (e.g. '..\..\Shared\X.ps1') to use clean and consistent
    form: "$PSScriptRoot\Shared\X.ps1"
    Backs up all modified files to .\Backups\DotSourceFixes\
.NOTES
    Excludes: \Backups\ and \Logs\
#>

$backupRoot = ".\Backups\DotSourceFixes"
if (-not (Test-Path $backupRoot)) {
    New-Item -ItemType Directory -Path $backupRoot | Out-Null
}

$changedFiles = @()

$files = Get-ChildItem -Path "." -Filter *.ps1 -Recurse |
    Where-Object {
        $_.FullName -notmatch '\\Backups\\' -and
        $_.FullName -notmatch '\\Logs\\'
    }

foreach ($file in $files) {
    $originalContent = Get-Content $file.FullName -Raw

    # Regex to match variations of dot-sourced paths using relative navigation
    $fixedContent = $originalContent -replace '(?ms)\. ?"?\$PSScriptRoot\\(?:\.\.\\)+', '. "$PSScriptRoot\'

    if ($fixedContent -ne $originalContent) {
        # Backup original
        $relPath = $file.FullName.Substring((Get-Location).Path.Length + 1)
        $backupPath = Join-Path $backupRoot $relPath
        $backupDir = Split-Path $backupPath -Parent
        if (-not (Test-Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        }
        Copy-Item $file.FullName $backupPath -Force

        # Save fixed version
        Set-Content -Path $file.FullName -Value $fixedContent -Force
        $changedFiles += $relPath
    }
}

if ($changedFiles.Count -gt 0) {
    Write-Host "`n✅ Dot-sourcing paths updated in $($changedFiles.Count) file(s):`n" -ForegroundColor Green
    $changedFiles | ForEach-Object { Write-Host " - $_" }
    Write-Host "`n🗃 Backup of originals saved to: $backupRoot" -ForegroundColor Yellow
} else {
    Write-Host "`n✔️ All .ps1 files already use consistent dot-sourcing. No changes made." -ForegroundColor Cyan
}
