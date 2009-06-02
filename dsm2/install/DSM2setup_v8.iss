; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!


[Setup]
AppName=DSM2_v8
AppVerName=Version 8.0.2
AppPublisher=CA DWR
AppPublisherURL=http://baydeltaoffice.water.ca.gov/modeling/deltamodeling/models/dsm2/dsm2.cfm
AppSupportURL=http://baydeltaoffice.water.ca.gov/modeling/deltamodeling/models/dsm2/dsm2.cfm
AppUpdatesURL=http://baydeltaoffice.water.ca.gov/modeling/deltamodeling/models/dsm2/dsm2.cfm
DefaultDirName=d:\delta\dsm2_v8
DefaultGroupName=DSM2_v8
AllowNoIcons=yes
OutputBaseFilename=DSM2setup_8.0.2
;Compression=lzma/ultra
Compression=lzma/fast
CompressionThreads=auto
SolidCompression=no
UninstallDisplayName=DSM2_v8
UninstallFilesDir={app}\bin
InfoBeforeFile=".\infoFile.rtf"
OutputDir="."


[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked


[Dirs]
;Name: "{app}\timeseries"
Name: "{app}\tutorials"


[Components]
;Name: "main"; Description: "Main Files"; Types: full compact custom; Flags: fixed
Name: "main"; Description: "Main Files"; Types: full compact custom;
Name: "timeseries"; Description: "DSS Time Series Data"; Types: full


[Files]
;files
;Source: "..\tutorials\pdf\Quick Reference Guide.pdf"; DestDir: "{app}"; Flags: isreadme
;Source: "..\tutorials\pdf\DSM2 tutorial.pdf";         Destdir: "{app}\tutorials";
;folders
Source: "..\bin\*";                      DestDir: "{app}\bin\";
Source: "..\scripts\*";                  DestDir: "{app}\scripts\";  Flags: ignoreversion recursesubdirs createallsubdirs
;Source: "..\tutorials\simulations\*";    Destdir: "{app}\tutorials"; Flags: ignoreversion recursesubdirs createallsubdirs   ; Components: templates
Source: "..\studies\*";                  Destdir: "{app}\studies\"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\study_templates\*";          Destdir: "{app}\study_templates\"; Flags: ignoreversion recursesubdirs createallsubdirs;
Source: "..\ptm\*";                      DestDir: "{app}\ptm\"; Flags: recursesubdirs createallsubdirs
Source: "..\timeseries\*";               DestDir: "{app}\timeseries\"; Flags: recursesubdirs createallsubdirs ; Components: timeseries
Source: "..\vista\*";                    DestDir: "{app}\vista\"; Flags: recursesubdirs createallsubdirs


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


;Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: string; ValueName: "Path"; ValueData: "{app}\vista\bin;{olddata}";
;Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: string; ValueName: "Path"; ValueData: "{app}\bin;{olddata}";
;Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "Path"; ValueData: "{app}\vista\bin;{olddata}";
;Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "Path"; ValueData: "{app}\bin;{olddata}";


Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "DSM2_HOME";    ValueData: "{app}";                    Flags: uninsdeletevalue;
Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "VISTA_HOME";   ValueData: "{app}\vista";              Flags: uninsdeletevalue;
Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "PTM_HOME";     ValueData: "{app}\ptm";                Flags: uninsdeletevalue;
Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "SCRIPTS_HOME"; ValueData: "{app}\scripts";            Flags: uninsdeletevalue;

;Check: myRegCheckEnv(ExpandConstant('SCRIPTS_HOME'))

;set environment variables using nested environment variables:
Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "Path";         ValueData: "%DSM2_HOME%\bin;{olddata}";
Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "Path";         ValueData: "%VISTA_HOME%\bin;{olddata}";
Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "Path";         ValueData: "%PTM_HOME%\bin;{olddata}";
Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "PYTHONPATH";   ValueData: "{olddata};%SCRIPTS_HOME%";
;Check: myRegCheckEnv(ExpandConstant('DSM2_HOME'))
;Check: myRegCheckEnv(ExpandConstant('VISTA_HOME'))
;checks need to the added to the previous 3 for patches.
;Check: myRegCheckEnv(ExpandConstant('PTM_HOME'))


;Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "DSM2_HOME"; ValueData: "{app}";
;Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "VISTA_HOME"; ValueData: "{app}\vista";
;Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "PTM_HOME"; ValueData: "{app}\ptm";
;Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "SCRIPTS_HOME"; ValueData: "{app}\scripts";
;Root: HKCU; Subkey: "Environment"; ValueType: string; ValueName: "PYTHONPATH"; ValueData: "{olddata};%SCRIPTS_HOME%";  Check: myRegCheckEnv(ExpandConstant('SCRIPTS_HOME'))




[Code]
function checkForConnection(SubKey: String): Boolean;
begin
    Result := not RegKeyExists(HKEY_CURRENT_USER, SubKey)
end;

function myRegCheckEnv(keyName: String): Boolean;
begin
   Result := not RegValueExists(HKEY_CURRENT_USER, 'Environment',keyName)

end;
