@echo off
rem ###################################
rem Batch file for running PTM
rem ###################################
setlocal
set ptm_home=%~dp0
rem echo %ptm_home%
if exist "%ptm_home%/PTM.jar" goto :valid


:notfound

echo ############################################################
echo   Error: ptm files not found
echo   ___
echo   Installation instructions
echo   ___
echo   The value of the environment variable ptm_home in the 
echo   file ptm.bat needs to match the location where
echo   ptm has been installed
echo ############################################################
PAUSE
goto :end

:valid
rem ###############
rem Set path to location of dll
rem ###############
set path=%ptm_home%;%ptm_home%\lib;%path%

rem ###############
rem starting ptm
rem ###############
::start %ptm_home%/jre/bin/
"%ptm_home%jre/bin/java" -ss1m -mx64m  -cp "%ptm_home%lib\edu.jar;%ptm_home%lib\COM.jar;;%ptm_home%lib\xml.jar"  -jar %ptm_home%PTM.jar

:end
endlocal 
rem 

