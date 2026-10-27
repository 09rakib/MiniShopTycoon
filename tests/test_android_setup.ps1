$ErrorActionPreference = 'Stop'
$project = Split-Path -Parent $PSScriptRoot
$prepare = Join-Path $project 'prepare-android-build.ps1'
$fixture = Join-Path $project ('tools/android-setup-test-' + [guid]::NewGuid().ToString('N'))
$build = Join-Path $fixture 'build'
$sdk = Join-Path $fixture 'sdk'
$checks = 0
function Check([bool]$Value, [string]$Description) {
    $script:checks++
    if (-not $Value) { throw "FAIL: $Description" }
    Write-Output "PASS: $Description"
}
New-Item -ItemType Directory -Path "$build/gradle/wrapper", "$build/src/main", "$sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/windows-x86_64/bin" -Force | Out-Null
[IO.File]::WriteAllText("$sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/windows-x86_64/bin/llvm-strip.exe", '')
$configPath = "$build/config.gradle"
$wrapperPath = "$build/gradle/wrapper/gradle-wrapper.properties"
$manifestPath = "$build/src/main/AndroidManifest.xml"
[IO.File]::WriteAllText("$build/gradle.properties", "org.gradle.daemon=true`ncustom.setting=keep`n")
[IO.File]::WriteAllText($configPath, "ext.versions = [`n androidGradlePlugin: '8.6.1',`n ndkVersion: '29.0.14206865',`n buildTools: '36.1.0',`n customValue: 'untouched'`n]`n")
[IO.File]::WriteAllText($wrapperPath, "distributionUrl=https\://services.gradle.org/distributions/gradle-8.11.1-bin.zip`ndistributionSha256Sum=old`n")
[IO.File]::WriteAllText($manifestPath, '<manifest xmlns:android="http://schemas.android.com/apk/res/android"><application android:label="unchanged"><meta-data android:name="custom.metadata" android:value="keep" /></application></manifest>')
& $prepare -BuildRoot $build -SdkRoot $sdk | Out-Null
$config = Get-Content $configPath -Raw
$wrapper = Get-Content $wrapperPath -Raw
$manifest = Get-Content $manifestPath -Raw
$properties = Get-Content "$build/gradle.properties" -Raw
Check ($config -match "androidGradlePlugin: '8.11.1'") 'Pins supported Android Gradle plugin'
Check ($config -match "ndkVersion: '28.2.13676358'" -and $config -match "buildTools: '36.0.0'" -and (Get-Content "$build/gradle.properties" -Raw) -match 'org.gradle.daemon=false') 'Selects SDK/NDK tools and non-persistent build execution'
Check ($wrapper -match 'gradle-8.13-bin.zip' -and $wrapper -match '20f1b1176237254a6fc204d8434196fa11a4cfb387567519c61556e8710aed78') 'Pins Gradle distribution and official SHA256'
Check (([regex]::Matches($wrapper, 'distributionSha256Sum=')).Count -eq 1) 'Replaces existing checksum without duplicate properties'
Check ($manifest -match 'org.godotengine.rendering.method' -and $manifest -match 'org.godotengine.editor.version') 'Adds real fallback declarations for export overlay metadata'
Check ($manifest -match 'custom.metadata' -and $manifest -match 'unchanged' -and $config -match "customValue: 'untouched'" -and $properties -match 'custom.setting=keep') 'Preserves unrelated template declarations'
& $prepare -BuildRoot $build -SdkRoot $sdk | Out-Null
Check ((Get-Content $configPath -Raw) -eq $config -and (Get-Content $wrapperPath -Raw) -eq $wrapper -and (Get-Content $manifestPath -Raw) -eq $manifest -and (Get-Content "$build/gradle.properties" -Raw) -eq $properties) 'Repeated preparation is byte-stable'
$failed = $false
try { & $prepare -BuildRoot $build -SdkRoot "$fixture/missing-sdk" | Out-Null } catch { $failed = $true }
Check ($failed -and (Get-Content $configPath -Raw) -eq $config -and (Get-Content $wrapperPath -Raw) -eq $wrapper) 'Missing NDK fails before modifying template'
[IO.File]::WriteAllText($wrapperPath, 'unexpected-wrapper-format')
$failed = $false
try { & $prepare -BuildRoot $build -SdkRoot $sdk | Out-Null } catch { $failed = $true }
Check ($failed -and (Get-Content $configPath -Raw) -eq $config -and (Get-Content $manifestPath -Raw) -eq $manifest) 'Unknown wrapper format fails without partial writes'
[IO.File]::WriteAllText($wrapperPath, $wrapper)
[IO.File]::WriteAllText($configPath, "androidGradlePlugin: '8.6.1'")
$failed = $false
try { & $prepare -BuildRoot $build -SdkRoot $sdk | Out-Null } catch { $failed = $true }
Check ($failed -and (Get-Content $wrapperPath -Raw) -eq $wrapper -and (Get-Content $manifestPath -Raw) -eq $manifest) 'Unknown template settings fail before export'
Write-Output "ANDROID SETUP RESULT: $checks checks, 0 failures"
