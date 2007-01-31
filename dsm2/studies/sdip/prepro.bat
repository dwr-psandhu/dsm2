@echo off
::  usage:  prepro hydro|qual|both config-file
:: 

if {%1%}=={} (
echo "usage:  prepro config-file"
echo Prepro is needed only when the CALSIM file changes.
goto fin
)

set CONFIGFILE=%1%

rem do not add spaces to the following command
if NOT EXIST %CONFIGFILE% GOTO noconfig
echo Prepro is needed only when the CALSIM file changes.
call vscript ../../scripts/planning_boundary_flow.py %CONFIGFILE%
call vscript prepro/prep_gates.py %CONFIGFILE%
call vscript prepro/prep_ec.py %CONFIGFILE%
rem call vscript prepro/prep_vamp.py %CONFIGFILE%

)

goto fin

:noconfig
echo %CONFIGFILE%
echo The configuration file must be specified on the command line
echo and be a valid file

:fin