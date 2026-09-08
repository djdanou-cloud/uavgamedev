@echo off
rem Run the gdUnit4 suite headless. Usage: tools\test.cmd [res://path/to/suite_or_dir]
if "%GODOT_BIN%"=="" (echo set GODOT_BIN to the Godot 4.7.2 console binary ^(docs\toolchain.md^) & exit /b 2)
set "SUITE=%~1"
if "%SUITE%"=="" set "SUITE=res://test"
"%GODOT_BIN%" --headless --path . -d -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a "%SUITE%" -rd reports/gdunit -c
exit /b %ERRORLEVEL%
