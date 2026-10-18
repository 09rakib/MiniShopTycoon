@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0tools\profile"
set "LOCALAPPDATA=%~dp0tools\local-profile"
set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
"tools\godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --export-debug "Android Phase C" "builds/MiniShopTycoon-phaseC.apk"
pause
