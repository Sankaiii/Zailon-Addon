$manifestsDir = "$env:APPDATA\com.twintaillauncher.ttl\manifests"
if (-not (Test-Path $manifestsDir)) {
    Write-Host "TwintailLauncher n'est pas installe. Installe-le d'abord : https://twintaillauncher.app" -ForegroundColor Red
    pause
    exit 1
}
$nteUrl = "https://raw.githubusercontent.com/Sankaiii/Zailon-game/main/nte_global.json"
$nteDest = Join-Path $manifestsDir "nte_global.json"
Write-Host "Telechargement du manifest NTE..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $nteUrl -OutFile $nteDest
$repoFile = Join-Path $manifestsDir "repository.json"
$repo = Get-Content $repoFile | ConvertFrom-Json
if ($repo.manifests -notcontains "nte_global.json") {
    $repo.manifests += "nte_global.json"
    $repo | ConvertTo-Json -Depth 10 | Set-Content $repoFile
}
Write-Host "Zailon installe ! Redemarre TwintailLauncher pour voir NTE." -ForegroundColor Green
pause
