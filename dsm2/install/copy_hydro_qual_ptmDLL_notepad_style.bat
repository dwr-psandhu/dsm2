set version=v8_0b5

echo version "%version%" 

copy ..\..\..\..\branch\dsm2\build_vs2008sp1_ivf110066\qual\Release\qual.exe   ..\..\..\..\branch\dsm2_distribute\dsm2\bin\* 
copy ..\..\..\..\branch\dsm2\build_vs2008sp1_ivf110066\hydro\Release\hydro.exe ..\..\..\..\branch\dsm2_distribute\dsm2\bin\*
copy ..\..\..\..\branch\dsm2\build_vs2008sp1_ivf110066\all\DLL\ptm.dll         ..\..\..\..\branch\dsm2_distribute\dsm2\bin\* 

copy ..\..\..\..\branch\dsm2\build_vs2008sp1_ivf110066\qual\Release\qual.exe   ..\..\..\..\branch\dsm2_distribute\dsm2\bin\qual_%version%.exe
copy ..\..\..\..\branch\dsm2\build_vs2008sp1_ivf110066\hydro\Release\hydro.exe ..\..\..\..\branch\dsm2_distribute\dsm2\bin\hydro_%version%.exe
copy ..\..\..\..\branch\dsm2\build_vs2008sp1_ivf110066\all\DLL\ptm.dll         ..\..\..\..\branch\dsm2_distribute\dsm2\bin\ptm_%version%.dll 
copy ..\..\..\..\branch\dsm2_distribute\dsm2\bin\ptm.jar             ..\..\..\..\branch\dsm2_distribute\dsm2\bin\ptm_%version%.jar


copy /y ..\..\..\dsm2\src\input_storage\component.py .
copy /y ..\..\..\dsm2\src\input_storage\userDefineLangTemplate.xml .

start /wait python component.py notepad

copy /y .\userDefineLang.xml ..\..\..\dsm2_distribute\dsm2\extras\"notepad++"\*


del .\component.py
del .\userDefineLangTemplate.xml
del .\userDefineLang.xml
 


pause