@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0tools\profile"
set "LOCALAPPDATA=%~dp0tools\local-profile"
start "Mini Shop Tycoon" "tools\godot\Godot_v4.7.2-stable_win64.exe" --path "%~dp0."
