setlocal
REM CUSTOMIZE BELOW TO MATCH YOUR ENVIRONMENT
SET CYGWIN_DIR=D:\cygwin
SET PYTHON_DIR=D:\Programs\Anaconda2\envs\dsm2
SET PATH=%PYTHON_DIR%;%CYGWIN_DIR%;%PATH%
REM 32 bit java needed
SET JAVA_HOME="C:\Program Files (x86)\Java\jdk1.8.0_191"
SET DSM2_THIRD_PARTY_DIR=\\cnrastore-bdo\Delta_Mod\Share\DSM2\compile_support\third_party
CALL "c:\Program Files (x86)\IntelSWTools\compilers_and_libraries\windows\bin\compilervars.bat" ia32 vs2015
REM BUILD OPRULE, INPUT STORAGE and then DSM2
ECHO Start building DSM2...
cd dsm2
cmake -E remove_directory BUILD
cmake -E make_directory BUILD
cd BUILD
cmake -DTHIRD_PARTY_DIR=%DSM2_THIRD_PARTY_DIR% -G "Visual Studio 14 2015" ..\src || goto :ERROR
cmake --build . --target ALL_BUILD --config Release  || goto :ERROR
rem cmake --build . --target ALL_BUILD --config Debug  || goto :ERROR
cpack
cd ../..
