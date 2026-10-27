@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0tools\profile"
set "LOCALAPPDATA=%~dp0tools\local-profile"
set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
"tools\godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --log-file tools/debug-export.log --export-debug "Android Phase K" "builds/MiniShopTycoon-v0.14.0.apk"
set "buildResult=%errorlevel%"
findstr /C:"SCRIPT ERROR:" /C:"ERROR:" tools\debug-export.log >nul
if not errorlevel 1 set "buildResult=1"
if not "%buildResult%"=="0" echo Export failed. See tools\debug-export.log. An older APK may still exist.
pause
exit /b %buildResult%
