::Launches the script dsm2_tidy.py
::This script cleans up input files
@echo off

if "%1" == "--help" goto usage


if "%1" == "" goto do_dir

call vscript.bat %%~dp0\..\scripts\manifest.py %1 %2 %3 
goto end

:usage
echo Usage: manifest echofile manifestfile [dir]
echo If copydir is given and is empty/nonexistent, all files in the manifest will be copied to the directory

:end
