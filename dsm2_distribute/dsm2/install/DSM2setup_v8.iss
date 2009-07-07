; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!



[Setup]
AppName=DSM2_v8
AppVerName=version 8_0_a4_1107
OutputBaseFilename=DSM2setup_8_0_a4_1107
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
ChangesEnvironment=yes
UninstallDisplayName=DSM2_v8
UninstallFilesDir={app}\bin\uninstall
UninstallLogMode=new
InfoBeforeFile=".\infoFile.rtf"
OutputDir="."
AlwaysRestart = no
PrivilegesRequired = admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Dirs]
Name: "{app}\common_input"
Name: "{app}\timeseries"
Name: "{app}\vista"
Name: "{app}\scripts"
Name: "{app}\bin"
Name: "{app}\ptm"
Name: "{app}\extras"

[Components]

Name: "main"; Description: "Main Files"; Types: full compact custom;
Name: "runtime_lib"; Description: "Runtime Libraries (Microsoft VC++2005 SP1 Redistributable)"; Types: full compact custom;
Name: "timeseries"; Description: "DSS Time Series Data"; Types: full

[Files]

;Source: "..\doc\*";                      DestDir: "{app}\documentation\";   Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
Source: "..\bin\*";                      DestDir: "{app}\bin\";             Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
;Source: "..\scripts\*";                  DestDir: "{app}\scripts\";         Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
;Source: "..\common_input\*";             DestDir: "{app}\common_input\";    Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
;Source: "..\tutorials\*";                Destdir: "{app}\tutorials";        Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
;Source: "..\studies\*";                  Destdir: "{app}\studies\";         Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
;Source: "..\study_templates\*";          Destdir: "{app}\study_templates\"; Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
;Source: "..\ptm\*";                      DestDir: "{app}\ptm\";             Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
;Source: "..\timeseries\*";               DestDir: "{app}\timeseries\";      Flags: ignoreversion recursesubdirs createallsubdirs ; Components: timeseries
;Source: "..\vista\*";                    DestDir: "{app}\vista\";           Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
;Source: "..\extras\*";                   DestDir: "{app}\extras\";          Flags: ignoreversion recursesubdirs createallsubdirs ; Components: main
;Source: "..\runtime\*";                  DestDir: "{tmp}";                  Flags: ignoreversion recursesubdirs createallsubdirs deleteafterinstall ; Components: runtime_lib


[Icons]

Name: "{app}\DSM2_documentation";   Filename: "{app}\documentation\html\toc.html"
Name: "{group}\DSM2_documentation"; Filename: "{app}\documentation\html\toc.html"
Name: "{group}\DSM2_v8";            Filename: "{app}\"
Name: "{group}\Uninstall";          Filename: "{uninstallexe}"
Name: "{userdesktop}\DSM2_v8";      Filename: "{app}\"; Tasks: desktopicon

[Registry]

Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: string; ValueName: "DSM2_HOME";   ValueData:  "{app}";         Flags: uninsdeletevalue;
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: string; ValueName: "VISTA_HOME";  ValueData:  "{app}\vista";   Flags: uninsdeletevalue;

Root: HKLM; Subkey: "SOFTWARE\DSM2\v8";      ValueType: dword;  ValueName: "Version";           ValueData: 80131107;                   Flags: uninsdeletevalue;
Root: HKLM; Subkey: "SOFTWARE\DSM2\v8\path"; ValueType: string; ValueName: "Vista";             ValueData: "%DSM2_HOME%\vista\bin;";   Flags: uninsdeletevalue;
Root: HKLM; Subkey: "SOFTWARE\DSM2\v8\path"; ValueType: string; ValueName: "DSM2";              ValueData: "%DSM2_HOME%\bin;";         Flags: uninsdeletevalue;
Root: HKLM; Subkey: "SOFTWARE\DSM2\v8\path"; ValueType: string; ValueName: "Uninstallexepath";  ValueData: "{uninstallexe}";           Flags: uninsdeletevalue;

[Run]

Filename: "{tmp}\vcredist_x86_2005sp1.exe"; Description: "Runtime Libraries"; Flags: skipifdoesntexist


[Code]

function UninstallerNotCalled(Uninstallexepath: string): Boolean;

var
  ResultCode: Integer;
  
begin

    if MsgBox('Previous DSM2_v8 version will be uninstalled before continue.', mbConfirmation, MB_YESNO or MB_DEFBUTTON1) = IDYES then
         begin
              Exec(Uninstallexepath, '/SILENT', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
              Result := False;  /// continue installation
         end
    else
         begin
              MsgBox('Current installation will be aborted.', mbInformation, MB_OK);
              Result := True;   /// To abort installation
         end;

end;


procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);

var
  OldPath: String;

begin

  RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path',       OldPath);

  case CurUninstallStep of
    usUninstall:
      begin

        /// clean double ;
        StringChangeEx(OldPath,       ';;',                 ';', True);
        
        /// clean path
        StringChangeEx(OldPath,        '%DSM2_HOME%\bin;',         '', True);
        StringChangeEx(OldPath,       ';%DSM2_HOME%\bin',          '', True);
        StringChangeEx(OldPath,        '%DSM2_HOME%\vista\bin;',   '', True);
        StringChangeEx(OldPath,       ';%DSM2_HOME%\vista\bin',    '', True);

        RegWriteExpandStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path',       OldPath);

      end;
  end;
end;
    
    
procedure CurStepChanged(CurStep: TSetupStep);

var
  Uninstallexepath: String;
  OldPath: String;
  OldPythonPath: String;

begin

case CurStep of
    ssInstall:

begin

    /// check if previous v8 exist
    if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\DSM2\v8\path',
     'Uninstallexepath', Uninstallexepath) then
       begin

          /// show message box to uninstall previous v8
          if UninstallerNotCalled(Uninstallexepath) then
            begin
              Abort;
            end;

       end;


    Sleep(3000);
			
		/// Read system environment path
    RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path',       OldPath);

        /// Clean double ;
        StringChangeEx(OldPath,       ';;',       ';', True);
        /// Clean path written by previous version
        StringChangeEx(OldPath,       '%VISTA_HOME%\bin;',       '', True);
        StringChangeEx(OldPath,       ';%VISTA_HOME%\bin',       '', True);
        StringChangeEx(OldPath,       '%PTM_HOME%\bin;',         '', True);
        StringChangeEx(OldPath,       ';%PTM_HOME%\bin',         '', True);
        StringChangeEx(OldPath,       '%DSM2_HOME%\bin;',        '', True);
        StringChangeEx(OldPath,       ';%DSM2_HOME%\bin',        '', True);
        StringChangeEx(OldPath,       '%DSM2_HOME%\vista\bin;',  '', True);
        StringChangeEx(OldPath,       ';%DSM2_HOME%\vista\bin',  '', True);

        ///Prepend path
        OldPath        := '%DSM2_HOME%\vista\bin;'  + OldPath;
        OldPath        := '%DSM2_HOME%\bin;'        + OldPath;

        RegWriteExpandStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'Path',       OldPath);


        ///clean unused system python path
        RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'PYTHONPATH', OldPythonPath);
        StringChangeEx(OldPythonPath, ';;',   ';', True);
        StringChangeEx(OldPythonPath, '%SCRIPTS_HOME%;',   '', True);
        StringChangeEx(OldPythonPath, ';%SCRIPTS_HOME%',   '', True);

        if OldPythonPath = '' then

          begin  ///delete value
            RegDeleteValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'PYTHONPATH');
          end
          
        else

          begin
            RegWriteExpandStringValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'PYTHONPATH', OldPythonPath);
          end;


        /// clean system environment written by previous version.
        RegDeleteValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'PTM_HOME');
        RegDeleteValue(HKEY_LOCAL_MACHINE, 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment', 'SCRIPTS_HOME');



    /// clean user environment path written by previous version.
    RegQueryStringValue(HKEY_CURRENT_USER, 'Environment', 'Path',       OldPath);

        /// Clean double ;
        StringChangeEx(OldPath,       ';;',       ';', True);
        /// clean user environment path written by previous version.
        StringChangeEx(OldPath,       '%PTM_HOME%\bin;',         '', True);
        StringChangeEx(OldPath,       ';%PTM_HOME%\bin',         '', True);
        StringChangeEx(OldPath,       '%VISTA_HOME%\bin;',       '', True);
        StringChangeEx(OldPath,       ';%VISTA_HOME%\bin',       '', True);
        StringChangeEx(OldPath,       '%DSM2_HOME%\bin;',        '', True);
        StringChangeEx(OldPath,       ';%DSM2_HOME%\bin',        '', True);
        StringChangeEx(OldPath,       '%DSM2_HOME%\vista\bin;',  '', True);
        StringChangeEx(OldPath,       ';%DSM2_HOME%\vista\bin',  '', True);

        RegWriteExpandStringValue(HKEY_CURRENT_USER, 'Environment', 'Path',       OldPath);

        ///clean unused python path
        RegQueryStringValue(HKEY_CURRENT_USER, 'Environment', 'PYTHONPATH', OldPythonPath);
        StringChangeEx(OldPythonPath, ';;',   ';', True);
        StringChangeEx(OldPythonPath, '%SCRIPTS_HOME%;',   '', True);
        StringChangeEx(OldPythonPath, ';%SCRIPTS_HOME%',   '', True);

        if OldPythonPath = '' then

          begin
            RegDeleteValue(HKEY_CURRENT_USER, 'Environment', 'PYTHONPATH');
          end
          
        else

          begin
            RegWriteExpandStringValue(HKEY_CURRENT_USER, 'Environment', 'PYTHONPATH', OldPythonPath);
          end;

        /// clean user environment written by previous version.
        RegDeleteValue(HKEY_CURRENT_USER, 'Environment', 'DSM2_HOME');
        RegDeleteValue(HKEY_CURRENT_USER, 'Environment', 'PTM_HOME');
        RegDeleteValue(HKEY_CURRENT_USER, 'Environment', 'VISTA_HOME');
        RegDeleteValue(HKEY_CURRENT_USER, 'Environment', 'SCRIPTS_HOME');

 end;
 end;
 end;





