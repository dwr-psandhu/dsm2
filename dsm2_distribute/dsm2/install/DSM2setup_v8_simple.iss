; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!


[Setup]
AppName=DSM2_v8
AppVerName=version 8.0_a2_1064
OutputBaseFilename=DSM2setup_8.0_a2_1064
AppPublisher=CA DWR
AppPublisherURL=http://baydeltaoffice.water.ca.gov/modeling/deltamodeling/models/dsm2/dsm2.cfm
AppSupportURL=http://baydeltaoffice.water.ca.gov/modeling/deltamodeling/models/dsm2/dsm2.cfm
AppUpdatesURL=http://baydeltaoffice.water.ca.gov/modeling/deltamodeling/models/dsm2/dsm2.cfm
DefaultDirName=d:\delta\dsm2_v8
DefaultGroupName=DSM2_v8
AllowNoIcons=yes
;Compression=lzma/ultra
Compression=lzma/fast
CompressionThreads=auto
SolidCompression=no
UninstallDisplayName=DSM2_v8
UninstallFilesDir={app}\bin\uninstall
;UninstallLogMode=overwrite
InfoBeforeFile=".\infoFile.rtf"
OutputDir="."
AlwaysRestart = yes
PrivilegesRequired = admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[UninstallRun]
Filename: "{app}\bin\uninstall\uninstall_path.vbs"; Flags: shellexec waituntilterminated




[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked


[Dirs]
;Name: "{app}\timeseries"
;Name: "{app}\tutorials"
Name: "{app}\common_input"

[Components]
Name: "main"; Description: "Main Files"; Types: full compact custom;
Name: "runtime_lib"; Description: "Runtime Libraries (Microsoft VC++2005 SP1 Redistributable)"; Types: full compact custom;
Name: "timeseries"; Description: "DSS Time Series Data"; Types: full

[Files]
;files
;Source: "..\tutorials\pdf\Quick Reference Guide.pdf"; DestDir: "{app}"; Flags: isreadme
;Source: "..\tutorials\pdf\DSM2 tutorial.pdf";         Destdir: "{app}\tutorials";

Source: "..\bin\*";                      DestDir: "{app}\bin\";             Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
Source: "..\scripts\*";                  DestDir: "{app}\scripts\";         Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
Source: "..\tutorials\*";                Destdir: "{app}\tutorials";        Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
Source: "..\studies\*";                  Destdir: "{app}\studies\";         Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
Source: "..\study_templates\*";          Destdir: "{app}\study_templates\"; Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
Source: "..\ptm\*";                      DestDir: "{app}\ptm\";             Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
Source: "..\timeseries\*";               DestDir: "{app}\timeseries\";      Flags: ignoreversion recursesubdirs createallsubdirs ; Components: timeseries
Source: "..\vista\*";                    DestDir: "{app}\vista\";           Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
Source: "..\extras\*";                   DestDir: "{app}\extras\";          Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
Source: "..\runtime\*";                  DestDir: "{tmp}";                  Flags: ignoreversion recursesubdirs createallsubdirs ; Components: runtime_lib


;SVN repository files. A bit cheesy to have to do them all by hand, but we need to learn to detect hidden files
;Source: "..\studies\.svn\*"; Destdir: "{app}\studies\.svn"; Attribs: hidden;  Flags: recursesubdirs createallsubdirs
;Source: "..\studies\historic\.svn\*"; DestDir: "{app}\studies\historic\.svn"; Attribs: hidden; Flags: recursesubdirs createallsubdirs
;Source: "..\studies\sdip\.svn\*"; DestDir: "{app}\studies\sdip\.svn"; Attribs: hidden; Flags: recursesubdirs createallsubdirs
;Source: "..\scripts\.svn\*"; DestDir: "{app}\scripts\.svn"; Attribs: hidden; Flags: recursesubdirs createallsubdirs
;Source: "..\scripts\interpolator\.svn\*"; DestDir: "{app}\scripts\interpolator\.svn"; Attribs: hidden; Flags: recursesubdirs createallsubdirs



; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\DSM2_v8"; Filename: "{app}\"
Name: "{group}\Uninstall"; Filename: "{uninstallexe}"
Name: "{userdesktop}\DSM2_v8"; Filename: "{app}\"; Tasks: desktopicon

[Registry]

;Set enviroment variables in Registry:

Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: string; ValueName: "VISTA_HOME";   ValueData: "{app}\vista";              Flags: uninsdeletevalue;
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: string; ValueName: "DSM2_HOME";    ValueData: "{app}";                    Flags: uninsdeletevalue;
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: string; ValueName: "SCRIPTS_HOME"; ValueData: "{app}\scripts";            Flags: uninsdeletevalue;

Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "VISTA_HOME";   ValueData: "{app}\vista";              Flags: uninsdeletevalue;
Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "DSM2_HOME";    ValueData: "{app}";                    Flags: uninsdeletevalue;
Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "SCRIPTS_HOME"; ValueData: "{app}\scripts";            Flags: uninsdeletevalue;

;Check: myRegCheckEnv(ExpandConstant('SCRIPTS_HOME'))

;set environment variables using nested environment variables:

Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path";       ValueData: "%VISTA_HOME%\bin;{olddata}";
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "Path";       ValueData:  "%DSM2_HOME%\bin;{olddata}";
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; ValueName: "PYTHONPATH"; ValueData:   "%SCRIPTS_HOME%;{olddata}";

Root: HKCU; Subkey: "Environment"; ValueType: expandsz; ValueName: "Path";         ValueData: "%VISTA_HOME%\bin;{olddata}";
Root: HKCU; Subkey: "Environment"; ValueType: expandsz; ValueName: "Path";         ValueData:  "%DSM2_HOME%\bin;{olddata}";
Root: HKCU; Subkey: "Environment"; ValueType: expandsz; ValueName: "PYTHONPATH";   ValueData:   "%SCRIPTS_HOME%;{olddata}";


[Run]
Filename: "{tmp}\vcredist_x86_2005sp1.exe"; Description: "Runtime Libraries"; Flags: skipifdoesntexist





