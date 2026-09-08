@echo off
rem gdlint + gdformat over every project .gd file.
if "%GDLINT%"=="" set "GDLINT=gdlint"
if "%GDFORMAT%"=="" set "GDFORMAT=gdformat"
dir /s /b src\*.gd scenes\*.gd tools\*.gd test\*.gd > "%TEMP%\cad_gd_files.txt" 2>nul
for /f %%f in ("%TEMP%\cad_gd_files.txt") do if %%~zf==0 (echo no .gd files yet & exit /b 0)
"%GDLINT%" @"%TEMP%\cad_gd_files.txt" || exit /b 1
"%GDFORMAT%" --check @"%TEMP%\cad_gd_files.txt" || exit /b 1
exit /b 0
