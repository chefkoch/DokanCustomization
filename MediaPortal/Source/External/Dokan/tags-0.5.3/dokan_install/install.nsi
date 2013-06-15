!define VERSION "0.5.3"

!include LogicLib.nsh
!include x64.nsh
!include WinVer.nsh
; chefkoch, Team MediaPortal, 2012-05-27:
; FileFunc is needed for GetSize comparison to check if the same version is already installed.
!include FileFunc.nsh

Name "DokanLibraryInstaller ${VERSION}"
OutFile "DokanInstall_${VERSION}.exe"

InstallDir $PROGRAMFILES32\Dokan\DokanLibrary
RequestExecutionLevel admin
LicenseData "licdata.rtf"
ShowUninstDetails show

Page license
Page components
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles


!macro X86Files os

  SetOutPath $PROGRAMFILES32\Dokan\DokanLibrary
 
    File ..\dokan\readme.txt
    File ..\dokan\readme.ja.txt
    File ..\dokan\dokan.h
    File ..\license.gpl.txt
    File ..\license.lgpl.txt
    File ..\license.mit.txt
    File ..\..\release-${VERSION}\${os}\dll\dokan.lib
    File ..\..\release-${VERSION}\${os}\dokanctrl\dokanctl.exe
    File ..\..\release-${VERSION}\${os}\mounter\mounter.exe

  SetOutPath $PROGRAMFILES32\Dokan\DokanLibrary\sample\mirror

    File ..\dokan_mirror\makefile
    File ..\dokan_mirror\mirror.c
    File ..\dokan_mirror\sources
    File ..\..\release-${VERSION}\${os}\mirror\mirror.exe

  SetOutPath $SYSDIR

    File ..\..\release-${VERSION}\${os}\dll\dokan.dll

!macroend

/*
!macro X64Files os

  SetOutPath $PROGRAMFILES64\Dokan\DokanLibrary

    File ..\dokan\readme.txt
    File ..\dokan\readme.ja.txt
    File ..\dokan\dokan.h
    File ..\license.gpl.txt
    File ..\license.lgpl.txt
    File ..\license.mit.txt
    File ..\dokan\objchk_${os}_amd64\amd64\dokan.lib
    File ..\dokan_control\objchk_${os}_amd64\amd64\dokanctl.exe
    File ..\dokan_mount\objchk_${os}_amd64\amd64\mounter.exe

  SetOutPath $PROGRAMFILES64\Dokan\DokanLibrary\sample\mirror

    File ..\dokan_mirror\makefile
    File ..\dokan_mirror\mirror.c
    File ..\dokan_mirror\sources
    File ..\dokan_mirror\objchk_${os}_amd64\amd64\mirror.exe

  ${DisableX64FSRedirection}

  SetOutPath $SYSDIR

    File ..\dokan\objchk_${os}_amd64\amd64\dokan.dll

  ${EnableX64FSRedirection}

!macroend
*/

!macro DokanSetup
  ExecWait '"$PROGRAMFILES32\Dokan\DokanLibrary\dokanctl.exe" /i a' $0
  DetailPrint "dokanctl returned $0"
  WriteUninstaller $PROGRAMFILES32\Dokan\DokanLibrary\DokanUninstall.exe

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DokanLibrary" "DisplayName" "Dokan Library ${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DokanLibrary" "UninstallString" '"$PROGRAMFILES32\Dokan\DokanLibrary\DokanUninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DokanLibrary" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DokanLibrary" "NoRepair" 1

!macroend

!macro X86Driver os
  SetOutPath $SYSDIR\drivers
    File ..\..\release-${VERSION}\${os}\sys\dokan.sys
!macroend

!macro X64Driver os
  ${DisableX64FSRedirection}

  SetOutPath $SYSDIR\drivers

    File ..\..\release-${VERSION}\x64\${os}\sys\dokan.sys

  ${EnableX64FSRedirection}
!macroend


Section "Dokan Library x86" section_x86
  ${If} ${IsWin7}
    !insertmacro X86Files "win7"
  ${ElseIf} ${IsWin2008R2}
    !insertmacro X86Files "win7"
  ${ElseIf} ${IsWinVista}
    !insertmacro X86Files "wlh"
  ${ElseIf} ${IsWin2008}
    !insertmacro X86Files "wlh"
  ${ElseIf} ${IsWin2003}
    !insertmacro X86Files "wnet"
  ${ElseIf} ${IsWinXp}
    !insertmacro X86Files "wxp"
  ${EndIf}
SectionEnd

Section "Dokan Driver x86" section_x86_driver
  ${If} ${IsWin7}
    !insertmacro X86Driver "win7"
  ${ElseIf} ${IsWinVista}
    !insertmacro X86Driver "wlh"
  ${ElseIf} ${IsWin2008}
    !insertmacro X86Driver "wlh"
  ${ElseIf} ${IsWin2003}
    !insertmacro X86Driver "wnet"
  ${ElseIf} ${IsWinXp}
    !insertmacro X86Driver "wxp"
  ${EndIf}
  !insertmacro DokanSetup
SectionEnd

Section "Dokan Driver x64" section_x64_driver
  ${If} ${IsWin7}
    !insertmacro X64Driver "win7"
  ${ElseIf} ${IsWin2008R2}
    !insertmacro X64Driver "win7"
  ${ElseIf} ${IsWinVista}
    !insertmacro X64Driver "wlh"
  ${ElseIf} ${IsWin2008}
    !insertmacro X64Driver "wlh"
  ${ElseIf} ${IsWin2003}
    !insertmacro X64Driver "wnet"
  ${EndIf}
  !insertmacro DokanSetup
SectionEnd

/*
Section "Dokan Library x64" section_x64
  ${If} ${IsWin7}
    !insertmacro X64Files "win7"
  ${ElseIf} ${IsWinVista}
    !insertmacro X64Files "wlh"
  ${ElseIf} ${IsWin2008}
    !insertmacro X64Files "wlh"
  ${ElseIf} ${IsWin2003}
    !insertmacro X64Files "wnet"
  ${EndIf}
SectionEnd
*/

Section "Uninstall"
  ExecWait '"$PROGRAMFILES32\Dokan\DokanLibrary\dokanctl.exe" /r a' $0
  DetailPrint "dokanctl.exe returned $0"

  RMDir /r $PROGRAMFILES32\Dokan\DokanLibrary
  RMDir $PROGRAMFILES32\Dokan
  Delete $SYSDIR\dokan.dll

  ${If} ${RunningX64}
    ${DisableX64FSRedirection}
      Delete $SYSDIR\drivers\dokan.sys
    ${EnableX64FSRedirection}
  ${Else}
    Delete $SYSDIR\drivers\dokan.sys
  ${EndIf}

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DokanLibrary"

; chefkoch, Team MediaPortal, 2012-05-27:
; Show message box only if uninstaller is not started silently.
${IfNot} ${Silent}
  MessageBox MB_YESNO "A reboot is required to finish the uninstallation. Do you wish to reboot now?" IDNO noreboot
    Reboot
  noreboot:
${EndIf}

SectionEnd

Function .onInit
  IntOp $0 ${SF_SELECTED} | ${SF_RO}
  ${If} ${RunningX64}
    SectionSetFlags ${section_x86} $0
    SectionSetFlags ${section_x86_driver} ${SF_RO}  ; disable
    SectionSetFlags ${section_x64_driver} $0
  ${Else}
    SectionSetFlags ${section_x86} $0
    SectionSetFlags ${section_x86_driver} $0
    SectionSetFlags ${section_x64_driver} ${SF_RO}  ; disable
  ${EndIf}

; chefkoch, Team MediaPortal, 2012-05-27: START
; Don't show message boxes if installer is started silently.
; The operating system checks are done within the parent installer.
${If} ${Silent}

  ${If} ${RunningX64}
    ${DisableX64FSRedirection}

    ${GetSize} "$SYSDIR\drivers" "/M=dokan.sys /S=0B /G=0" $0 $1 $2
    ;<!-- 106888 is the exact filesize of dokan.sys v0.53 on Windows 64 -->
    ${If} ${FileExists} "$SYSDIR\drivers\dokan.sys"
      StrCpy $4 "DokanIsInstalled"
      ${If} $0 = 106888
        StrCpy $5 "SameVersion"
      ${EndIf}
    ${EndIf}

    ${EnableX64FSRedirection}
  ${Else}

    ${GetSize} "$SYSDIR\drivers" "/M=dokan.sys /S=0B /G=0" $0 $1 $2
    ;<!-- 84992 is the exact filesize of dokan.sys v0.53 on Windows 32 -->
    ${If} ${FileExists} "$SYSDIR\drivers\dokan.sys"
      StrCpy $4 "DokanIsInstalled"
      ${If} $0 = 84992
        StrCpy $5 "SameVersion"
      ${EndIf}
    ${EndIf}

  ${EndIf}

  ${If} $4 == "DokanIsInstalled"
    ${If} $5 == "SameVersion" 
      ; nothing to do, simply stop the installer
    ${Else}
      ; different version is installed, uninstall current one
      ; clearerrors, to catch if uninstall fails
      ClearErrors
      ; copy uninstaller to temp, to make sure uninstaller.exe in instdir is deleted, too
      CopyFiles "$PROGRAMFILES32\Dokan\DokanLibrary\DokanUninstall.exe" "$TEMP\uninstall-temp.exe"
      ; launch uninstaller
      ExecWait '"$TEMP\uninstall-temp.exe" /S _?=$PROGRAMFILES32\Dokan\DokanLibrary'
    ${EndIf}
  ${EndIf}

${Else}
; chefkoch, Team MediaPortal, 2012-05-27: END

  ; Windows Version check

  ${If} ${RunningX64}
    ${If} ${IsWin2003}
    ${ElseIf} ${IsWinVista}
    ${ElseIf} ${IsWin2008}
    ${ElseIf} ${IsWin2008R2}
    ${ElseIf} ${IsWin7}
    ${Else}
      MessageBox MB_OK "Your OS is not supported. Dokan library supports Windows 2003, Vista, 2008, 2008R2 and 7 for x64."
      Abort
    ${EndIf}
  ${Else}
    ${If} ${IsWinXP}
    ${ElseIf} ${IsWin2003}
    ${ElseIf} ${IsWinVista}
    ${ElseIf} ${IsWin2008}
    ${ElseIf} ${IsWin7}
    ${Else}
      MessageBox MB_OK "Your OS is not supported. Dokan library supports Windows XP, 2003, Vista, 2008 and 7 for x86."
      Abort
    ${EndIf}
  ${EndIf}

  ; Previous version
  ${If} ${RunningX64}
    ${DisableX64FSRedirection}
      IfFileExists $SYSDIR\drivers\dokan.sys HasPreviousVersionX64 NoPreviousVersionX64
      ; To make EnableX64FSRedirection called in both cases, needs duplicated MessageBox code. How can I avoid this?
      HasPreviousVersionX64:
        MessageBox MB_OK "Please unstall the previous version and restart your computer before running this installer."
        Abort
      NoPreviousVersionX64:
    ${EnableX64FSRedirection}
  ${Else}
    IfFileExists $SYSDIR\drivers\dokan.sys HasPreviousVersion NoPreviousVersion
    HasPreviousVersion:
      MessageBox MB_OK "Please unstall the previous version and restart your computer before running this installer."
      Abort
    NoPreviousVersion:
  ${EndIf}

; chefkoch, Team MediaPortal, 2012-05-27
${EndIf}

FunctionEnd

Function .onInstSuccess
  ; chefkoch, Team MediaPortal, 2012-05-27:
  ; Don't open the Explorer window at the end of the
  ; Dokan installation, if the installer is used silently
  ${IfNot} ${Silent}
    ExecShell "open" "$PROGRAMFILES32\Dokan\DokanLibrary"
  ${EndIf}
FunctionEnd
