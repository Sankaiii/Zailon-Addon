$ErrorActionPreference = "Stop"
$Host.UI.RawUI.ForegroundColor = "DarkYellow"
Write-Host "========================================" 
Write-Host "         Zailon Addon Installer         "
Write-Host "========================================"
$Host.UI.RawUI.ForegroundColor = "White"

$possiblePaths = @(
    "$env:APPDATA\com.twintaillauncher.ttl",
    "$env:LOCALAPPDATA\com.twintaillauncher.ttl"
)
$drives = (Get-PSDrive -PSProvider FileSystem).Root
foreach ($drive in $drives) {
    Get-ChildItem -Path $drive -Recurse -Depth 6 -Filter "twintaillauncher.exe" -ErrorAction SilentlyContinue | ForEach-Object {
        $possiblePaths += $_.DirectoryName
    }
}

$ttlDir = $null
foreach ($path in $possiblePaths) {
    if (Test-Path $path) { $ttlDir = $path; break }
}
if (-not $ttlDir) {
    Write-Host "Launcher non trouve automatiquement." -ForegroundColor DarkYellow
    $ttlDir = Read-Host "Chemin du dossier TwintailLauncher"
}

Write-Host "Launcher trouve : $ttlDir" -ForegroundColor DarkYellow
$manifestsDir = Join-Path $ttlDir "manifests"
if (-not (Test-Path $manifestsDir)) { New-Item -ItemType Directory -Path $manifestsDir | Out-Null }

# Ferme TTL si ouvert
$ttlProcess = Get-Process -Name "twintaillauncher" -ErrorAction SilentlyContinue
if ($ttlProcess) {
    Write-Host "Fermeture du launcher..." -ForegroundColor DarkYellow
    $ttlProcess | Stop-Process -Force
    Start-Sleep -Seconds 2
}

# Telecharge les fichiers addon avec progression
$addonFiles = @(
    "https://raw.githubusercontent.com/Sankaiii/Zailon-game/main/nte_global.json"
)
$total = $addonFiles.Count
$i = 0
foreach ($url in $addonFiles) {
    $i++
    $pct = [int](($i / $total) * 100)
    $fileName = $url.Split("/")[-1]
    Write-Host ""
    Write-Host "[$pct%] Telechargement : $fileName" -ForegroundColor DarkYellow
    $bar = "#" * [int]($pct / 5)
    $empty = "-" * (20 - [int]($pct / 5))
    Write-Host "  [$bar$empty]" -ForegroundColor DarkYellow
    Invoke-WebRequest -Uri $url -OutFile "$manifestsDir\$fileName" -UseBasicParsing
}

# Met a jour repository.json
$repoFile = Join-Path $manifestsDir "repository.json"
if (Test-Path $repoFile) {
    $repo = Get-Content $repoFile -Raw | ConvertFrom-Json
} else {
    $repo = [PSCustomObject]@{ name="Zailon"; description="Zailon addon manifests"; maintainers=@("Sankaiii"); manifests=@() }
}
$addonManifests = @("nte_global.json")
foreach ($m in $addonManifests) {
    if ($repo.manifests -notcontains $m) { $repo.manifests += $m }
}
$repo | ConvertTo-Json -Depth 10 | Set-Content $repoFile -Encoding UTF8

Write-Host ""
Write-Host "[100%] Installation complete !" -ForegroundColor DarkYellow

# Relance TTL
$ttlExe = Get-ChildItem -Path $ttlDir -Filter "twintaillauncher.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($ttlExe) {
    Write-Host "Relancement du launcher..." -ForegroundColor DarkYellow
    Start-Process $ttlExe.FullName
}
Write-Host "========================================" -ForegroundColor DarkYellow
Write-Host "   Zailon installe ! Bon jeu." -ForegroundColor DarkYellow
Write-Host "========================================" -ForegroundColor DarkYellow
pause
