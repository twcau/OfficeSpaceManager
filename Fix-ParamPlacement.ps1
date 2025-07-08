# Fix-ParamPlacement.ps1
# ✅ Final version: Corrects misplaced or duplicated param() blocks across scripts

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = ".\Backups\ParamFix_$timestamp"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

Write-Host "🔍 Scanning for .ps1 files and fixing misplaced or duplicate param() blocks..." -ForegroundColor Cyan

function Find-Index {
    param (
        [array]$array,
        [scriptblock]$predicate
    )
    for ($i = 0; $i -lt $array.Count; $i++) {
        if (& $predicate $array[$i]) {
            return $i
        }
    }
    return -1
}

# Recursively scan all .ps1 files except in Logs or Backups
$files = Get-ChildItem -Recurse -Filter *.ps1 | Where-Object {
    $_.FullName -notmatch '\\Logs\\' -and $_.FullName -notmatch '\\Backups\\'
}

foreach ($file in $files) {
    try {
        $filePath = $file.FullName
        $raw = Get-Content $filePath -Raw -Encoding UTF8 -ErrorAction Stop

        # ✅ Convert to mutable list
        $lineList = [System.Collections.Generic.List[string]]::new()
        $raw -split "`n" | ForEach-Object { $lineList.Add($_.TrimEnd()) }
        $originalLines = $lineList.ToArray()

        # 🔍 Locate all param() blocks
        $paramLines = $lineList | Where-Object { $_ -match '^\s*param\s*\(' }
        if ($paramLines.Count -eq 0) { continue }

        if ($paramLines.Count -gt 1) {
            Write-Warning "⚠️ Multiple param() blocks found in: $($file.Name). Keeping the first one."
        }

        # Store and remove all param() lines
        $paramLine = $paramLines[0]
        $lineList = $lineList | Where-Object { $_ -notmatch '^\s*param\s*\(' }

        # 🔎 Find header region
        $headerStart = Find-Index $lineList { $_ -match '^\s*<#' }
        $headerEnd   = Find-Index $lineList { $_ -match '#>\s*$' }
        $hasHeader = ($headerStart -ge 0 -and $headerEnd -gt $headerStart)
        $insertIndex = if ($hasHeader) { $headerEnd + 1 } else { 0 }

        # 🧩 Reinsert param() block after header
        $lineList.Insert($insertIndex, "")         # blank line for spacing
        $lineList.Insert($insertIndex + 1, $paramLine)

        # 💾 Backup original, save new version
        $backupPath = Join-Path $backupDir $file.Name
        Copy-Item $filePath $backupPath -Force
        Set-Content -Path $filePath -Value $lineList -Encoding UTF8

        Write-Host "✔️ Fixed param() in: $($file.FullName.Replace($PWD.Path, '.'))" -ForegroundColor Green

    } catch {
        Write-Warning "❌ Failed to fix param() in $($file.Name): $($_.Exception.Message)"
    }
}

Write-Host "`n✅ All applicable scripts fixed. Backups saved to: $backupDir" -ForegroundColor Cyan
