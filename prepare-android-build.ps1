param(
    [string]$BuildRoot = (Join-Path $PSScriptRoot 'android/build'),
    [string]$SdkRoot = "$env:LOCALAPPDATA/Android/Sdk"
)
$ErrorActionPreference = 'Stop'
$configPath = Join-Path $BuildRoot 'config.gradle'
$wrapperPath = Join-Path $BuildRoot 'gradle/wrapper/gradle-wrapper.properties'
$manifestPath = Join-Path $BuildRoot 'src/main/AndroidManifest.xml'
$propertiesPath = Join-Path $BuildRoot 'gradle.properties'
foreach ($path in @($configPath, $wrapperPath, $manifestPath, $propertiesPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing Android template file: $path" }
}
$stripPath = Join-Path $SdkRoot 'ndk/28.2.13676358/toolchains/llvm/prebuilt/windows-x86_64/bin/llvm-strip.exe'
if (-not (Test-Path -LiteralPath $stripPath -PathType Leaf)) {
    throw 'Install Android NDK 28.2.13676358 before building the bundle.'
}
$config = Get-Content -LiteralPath $configPath -Raw
foreach ($entry in @(
    @{Name='androidGradlePlugin'; Value='8.11.1'},
    @{Name='ndkVersion'; Value='28.2.13676358'},
    @{Name='buildTools'; Value='36.0.0'}
)) {
    $pattern = "(?m)^(\s*" + [regex]::Escape($entry.Name) + "\s*:\s*)'[^']+'"
    if ([regex]::Matches($config, $pattern).Count -ne 1) { throw "Unexpected template setting: $($entry.Name)" }
    $replacement = '${1}' + "'" + $entry.Value + "'"
    $config = [regex]::Replace($config, $pattern, $replacement)
}
$wrapper = Get-Content -LiteralPath $wrapperPath -Raw
$properties = Get-Content -LiteralPath $propertiesPath -Raw
foreach ($entry in @(@{Name='org.gradle.daemon'; Value='false'}, @{Name='org.gradle.console'; Value='plain'})) {
    $pattern = '(?m)^' + [regex]::Escape($entry.Name) + '=[^\r\n]+'
    if ($properties -match $pattern) {
        $properties = [regex]::Replace($properties, $pattern, ($entry.Name + '=' + $entry.Value))
    } else {
        $properties = $properties.TrimEnd() + "`n" + $entry.Name + '=' + $entry.Value + "`n"
    }
}
if ([regex]::Matches($wrapper, '(?m)^distributionUrl=').Count -ne 1) { throw 'Unexpected Gradle wrapper format.' }
$wrapper = [regex]::Replace($wrapper, '(?m)^distributionUrl=[^\r\n]+', 'distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-bin.zip')
$checksum = '20f1b1176237254a6fc204d8434196fa11a4cfb387567519c61556e8710aed78'
if ($wrapper -match '(?m)^distributionSha256Sum=') {
    $wrapper = [regex]::Replace($wrapper, '(?m)^distributionSha256Sum=[^\r\n]+', "distributionSha256Sum=$checksum")
} else {
    $wrapper = $wrapper.TrimEnd() + "`n" + "distributionSha256Sum=$checksum`n"
}
# Provide real fallback metadata so the exporter overlay can replace declarations
# that actually exist. No warning suppression or editing of exported overlay files.
$manifest = New-Object System.Xml.XmlDocument
$manifest.PreserveWhitespace = $true
$manifest.Load($manifestPath)
$application = $manifest.SelectSingleNode('/manifest/application')
if ($null -eq $application) { throw 'Missing template application element.' }
$androidNamespace = 'http://schemas.android.com/apk/res/android'
foreach ($entry in @(
    @{Name='org.godotengine.rendering.method'; Value='gl_compatibility'},
    @{Name='org.godotengine.editor.version'; Value='4.7.2.stable'}
)) {
    $existing = @($application.SelectNodes('meta-data') | Where-Object { $_.GetAttribute('name', $androidNamespace) -eq $entry.Name })
    if ($existing.Count -eq 0) {
        $node = $manifest.CreateElement('meta-data')
        $node.SetAttribute('name', $androidNamespace, $entry.Name) | Out-Null
        $node.SetAttribute('value', $androidNamespace, $entry.Value) | Out-Null
        $application.AppendChild($node) | Out-Null
    }
}
[IO.File]::WriteAllText($configPath, $config)
[IO.File]::WriteAllText($wrapperPath, $wrapper)
[IO.File]::WriteAllText($propertiesPath, $properties)
$manifest.Save($manifestPath)
Write-Output 'Android toolchain prepared: AGP 8.11.1, Gradle 8.13 (SHA256 pinned), NDK 28.2.13676358.'
