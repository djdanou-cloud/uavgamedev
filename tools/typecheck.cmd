@echo off
if "%GODOT_BIN%"=="" (echo set GODOT_BIN to the Godot 4.7.2 console binary ^(docs\toolchain.md^) & exit /b 2)
"%GODOT_BIN%" --headless --path . -s res://tools/check_scripts.gd
exit /b %ERRORLEVEL%
