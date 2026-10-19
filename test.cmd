@echo off
cd /d "%~dp0"
set "APPDATA=%~dp0tools\profile"
set "LOCALAPPDATA=%~dp0tools\local-profile"
"tools\godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --log-file tools/test-run.log --script tests/run_tests.gd
set "testResult=%errorlevel%"
findstr /C:"SCRIPT ERROR:" /C:"ERROR:" tools\test-run.log >nul
if not errorlevel 1 set "testResult=1"
"tools\godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --log-file tools/world-test-run.log --script tests/run_world_tests.gd
if errorlevel 1 set "testResult=1"
findstr /C:"SCRIPT ERROR:" /C:"ERROR:" tools\world-test-run.log >nul
if not errorlevel 1 set "testResult=1"
"tools\godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --log-file tools/production-test-run.log --script tests/run_production_tests.gd
if errorlevel 1 set "testResult=1"
findstr /C:"SCRIPT ERROR:" /C:"ERROR:" tools\production-test-run.log >nul
if not errorlevel 1 set "testResult=1"
"tools\godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --log-file tools/handling-test-run.log --script tests/run_handling_tests.gd
if errorlevel 1 set "testResult=1"
findstr /C:"SCRIPT ERROR:" /C:"ERROR:" tools\handling-test-run.log >nul
if not errorlevel 1 set "testResult=1"
"tools\godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --log-file tools/customer-test-run.log --script tests/run_customer_tests.gd
if errorlevel 1 set "testResult=1"
findstr /C:"SCRIPT ERROR:" /C:"ERROR:" tools\customer-test-run.log >nul
if not errorlevel 1 set "testResult=1"
"tools\godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --log-file tools/cash-test-run.log --script tests/run_cash_tests.gd
if errorlevel 1 set "testResult=1"
findstr /C:"SCRIPT ERROR:" /C:"ERROR:" tools\cash-test-run.log >nul
if not errorlevel 1 set "testResult=1"
"tools\godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path . --log-file tools/operations-test-run.log --script tests/run_operations_tests.gd
if errorlevel 1 set "testResult=1"
findstr /C:"SCRIPT ERROR:" /C:"ERROR:" tools\operations-test-run.log >nul
if not errorlevel 1 set "testResult=1"
if not "%testResult%"=="0" echo Tests failed. See tools\*-test-run.log.
pause
exit /b %testResult%
