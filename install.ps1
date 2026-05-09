$ErrorActionPreference = "Stop"
Write-Host "Zailon - NTE Addon for TwintailLauncher" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

# Cherche TTL dans plusieurs emplacements possibles
$possiblePaths = @(
    "$env:APPDATA\com.twintaillauncher.ttl",
    "$env:LOCALAPPDATA\com.twintaillauncher.ttl",
    "C:\Program Files\TwintailLauncher",
    "C:\Program Files (x86)\TwintailLauncher"
)

# Cherche aussi sur tous les lecteurs
$drives = (Get-PSDrive -PSProvider FileSystem).Root
foreach ($drive in $drives) {
    Get-ChildItem -Path $drive -Recurse -Depth 5 -Filter "twintaillauncher.exe" -ErrorAction SilentlyContinue | ForEach-Object {
        $possiblePaths += $_.DirectoryName
    }
}

$ttlDir = $null
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $ttlDir = $path
        break
    }
}

if (-not $ttlDir) {
    Write-Host "TTL non trouve automatiquement." -ForegroundColor Yellow
    $ttlDir = Read-Host "Entrez le chemin du dossier TwintailLauncher (ex: G:\logiciel jeux\.A MOD\twintail launcher)"
}

Write-Host "TTL trouve : $ttlDir" -ForegroundColor Green
$manifestsDir = Join-Path $ttlDir "manifests"

if (-not (Test-Path $manifestsDir)) {
    New-Item -ItemType Directory -Path $manifestsDir | Out-Null
}

# Telecharge nte_global.json
Write-Host "Telechargement du manifest NTE..." -ForegroundColor Cyan
$nteUrl = "https://raw.githubusercontent.com/Sankaiii/Zailon-game/main/nte_global.json"
Invoke-WebRequest -Uri $nteUrl -OutFile "$manifestsDir\nte_global.json" -UseBasicParsing

# Cree ou met a jour repository.json
$repoFile = Join-Path $manifestsDir "repository.json"
if (Test-Path $repoFile) {
    $repo = Get-Content $repoFile -Raw | ConvertFrom-Json
} else {
    $repo = [PSCustomObject]@{ manifests = @() }
}

if ($repo.manifests -notcontains "nte_global.json") {
    $repo.manifests += "nte_global.json"
}
$repo | ConvertTo-Json -Depth 10 | Set-Content $repoFile -Encoding UTF8

Write-Host ""
Write-Host "Zailon installe avec succes !" -ForegroundColor Green
Write-Host "Redemarre TwintailLauncher pour voir NTE." -ForegroundColor Green
pause
