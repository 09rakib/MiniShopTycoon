param([ValidateSet('apk', 'aab')][string]$Format = 'aab')
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$env:APPDATA = Join-Path $PSScriptRoot 'tools/profile'
$env:LOCALAPPDATA = Join-Path $PSScriptRoot 'tools/local-profile'
if (-not $env:JAVA_HOME) { $env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr' }
$engine = Join-Path $PSScriptRoot 'tools/godot/Godot_v4.7.2-stable_win64_console.exe'
$preset = if ($Format -eq 'aab') { 'Android Bundle Candidate' } else { 'Android Release Candidate' }
$artifact = "builds/MiniShopTycoon-phaseK-unsigned.$Format"
$arguments = @('--headless', '--path', '.', '--export-release', $preset, $artifact)
if ($Format -eq 'aab' -and -not (Test-Path -LiteralPath 'android/build/build.gradle')) {
    $arguments = @('--install-android-build-template') + $arguments
}
# A failed export must not be mistaken for a stale successful artifact.
if (Test-Path -LiteralPath $artifact) { Remove-Item -LiteralPath $artifact }
$output = & $engine @arguments 2>&1
$output | Set-Content -LiteralPath "tools/release-$Format.log"
if ($LASTEXITCODE -ne 0 -or ($output | Select-String -Pattern 'ERROR:|SCRIPT ERROR:') -or -not (Test-Path -LiteralPath $artifact)) {
    throw "Release candidate export failed. See tools/release-$Format.log"
}
& python tests/audit_android.py $artifact --report "builds/audit-release-$Format.json"
if ($LASTEXITCODE -ne 0) { throw 'Artifact audit failed.' }
if ($Format -eq 'aab' -and (Test-Path -LiteralPath 'tools/bundletool-all-1.18.3.jar')) {
    & "$env:JAVA_HOME/bin/java.exe" -jar tools/bundletool-all-1.18.3.jar validate "--bundle=$artifact" *> tools/bundle-validate.log
    if ($LASTEXITCODE -ne 0) { throw 'Bundle validation failed. See tools/bundle-validate.log' }
}
Write-Output "Unsigned candidate created: $artifact. Sign with your own upload key before Play submission."
