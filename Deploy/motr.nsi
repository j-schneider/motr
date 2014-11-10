; basic script template for NSIS installers
;
; Written by Philip Chu
; Copyright (c) 2004-2005 Technicat, LLC
;
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
 
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it ; and redistribute
; it freely, subject to the following restrictions:
 
;    1. The origin of this software must not be misrepresented; you must not claim that
;       you wrote the original software. If you use this software in a product, an
;       acknowledgment in the product documentation would be appreciated but is not required.
 
;    2. Altered source versions must be plainly marked as such, and must not be
;       misrepresented as being the original software.
 
;    3. This notice may not be removed or altered from any source distribution.

!include "LogicLib.nsh"
!include SetCursor.nsh
 
!define setup "install_motr.exe"
 
; change this to wherever the files to be packaged reside
!define srcdir "."
 
!define company "Janelia"
 
!define prodname "Motr"
!define exec "motr.exe"
!define exec2 "catalytic.exe"
 
; optional stuff
 
; Set the text which prompts the user to enter the installation directory
; DirText "My Description Here."
 
; text file to open in notepad after installation
; !define notefile "README.txt"
 
; license text file
; !define licensefile license.txt
 
; icons must be Microsoft .ICO files
; !define icon "icon.ico"
 
; installer background screen
; !define screenimage background.bmp
 
; file containing list of file-installation commands
; !define files "files.nsi"
 
; file containing list of file-uninstall commands
; !define unfiles "unfiles.nsi"
 
; registry stuff
 
!define regkey "Software\${company}\${prodname}"
!define uninstkey "Software\Microsoft\Windows\CurrentVersion\Uninstall\${prodname}"
 
!define startmenu "$SMPROGRAMS\${prodname}"
!define uninstaller "uninstall.exe"
 
;-----------------------------------------------------------------------
 
XPStyle on
ShowInstDetails hide
ShowUninstDetails hide
 
Name "${prodname}"
Caption "${prodname}"
 
!ifdef icon
Icon "${icon}"
!endif
 
OutFile "${setup}"
 
SetDateSave on
SetDatablockOptimize on
CRCCheck on
SilentInstall normal
 
InstallDir "$PROGRAMFILES64\${prodname}"
InstallDirRegKey HKLM "${regkey}" ""
 
!ifdef licensefile
LicenseText "License"
LicenseData "${srcdir}\${licensefile}"
!endif
 
; pages
; we keep it simple - leave out selectable installation types
 
!ifdef licensefile
Page license
!endif
 
; Page components
Page directory
Page instfiles
 
UninstPage uninstConfirm
UninstPage instfiles
 
;-----------------------------------------------------------------------
 
AutoCloseWindow false
ShowInstDetails show
 
 
!ifdef screenimage
 
; set up background image
; uses BgImage plugin
 
Function .onGUIInit
	; extract background BMP into temp plugin directory
	InitPluginsDir
	File /oname=$PLUGINSDIR\1.bmp "${screenimage}"
 
	BgImage::SetBg /NOUNLOAD /FILLSCREEN $PLUGINSDIR\1.bmp
	BgImage::Redraw /NOUNLOAD
FunctionEnd
 
Function .onGUIEnd
	; Destroy must not have /NOUNLOAD so NSIS will be able to unload and delete BgImage before it exits
	BgImage::Destroy
FunctionEnd
 
!endif
 
;-----------------------------------------------------------------------
; beginning (invisible) section
Section
 
  WriteRegStr HKLM "${regkey}" "Install_Dir" "$INSTDIR"
  ; write uninstall strings
  WriteRegStr HKLM "${uninstkey}" "DisplayName" "${prodname}"
  WriteRegStr HKLM "${uninstkey}" "UninstallString" '"$INSTDIR\${uninstaller}"'
 
!ifdef filetype
  WriteRegStr HKCR "${filetype}" "" "${prodname}"
!endif
 
  WriteRegStr HKCR "${prodname}\Shell\open\command\" "" '"$INSTDIR\${exec} "%1"'
 
!ifdef icon
  WriteRegStr HKCR "${prodname}\DefaultIcon" "" "$INSTDIR\${icon}"
!endif
 
  SetOutPath $INSTDIR
 
 
; package all files, recursively, preserving attributes
; assume files are in the correct places
;File /a "${srcdir}\MCR_R2013b_win64_installer.exe"
File /a "${srcdir}\${exec}"
File /a "${srcdir}\${exec2}"
 
!ifdef licensefile
File /a "${srcdir}\${licensefile}"
!endif
 
!ifdef notefile
File /a "${srcdir}\${notefile}"
!endif

!ifdef icon
File /a "${srcdir}\${icon}"
!endif

; any application-specific files
!ifdef files
!include "${files}"
!endif
 
  WriteUninstaller "${uninstaller}"
 
SectionEnd
 
;-----------------------------------------------------------------------
; create shortcuts
Section
 
  SetShellVarContext all

  CreateDirectory "${startmenu}"
  SetOutPath $INSTDIR ; for working directory
!ifdef icon
  CreateShortCut "${startmenu}\${prodname}.lnk" "$INSTDIR\${exec}" "" "$INSTDIR\${icon}"
!else
  CreateShortCut "${startmenu}\${prodname}.lnk" "$INSTDIR\${exec}"
!endif

!ifdef icon2
  CreateShortCut "${startmenu}\Catalytic.lnk" "$INSTDIR\${exec2}" "" "$INSTDIR\${icon2}"
!else
  CreateShortCut "${startmenu}\Catalytic.lnk" "$INSTDIR\${exec2}"
!endif
 
!ifdef notefile
  CreateShortCut "${startmenu}\Release Notes.lnk "$INSTDIR\${notefile}"
!endif
 
!ifdef helpfile
  CreateShortCut "${startmenu}\Documentation.lnk "$INSTDIR\${helpfile}"
!endif
 
!ifdef website
WriteINIStr "${startmenu}\web site.url" "InternetShortcut" "URL" ${website}
 ; CreateShortCut "${startmenu}\Web Site.lnk "${website}" "URL"
!endif



IfFileExists "$PROGRAMFILES64\MATLAB\MATLAB Compiler Runtime\v82\bin\win64\ctfxlauncher.exe" 0 +4
StrCpy $0 1
DetailPrint "Matlab Compiler Runtime is already installed."
Goto +3
StrCpy $0 0
DetailPrint "Matlab Compiler Runtime is not installed --- launching installer..."


${If} $0 == 0
  ${SetSystemCursor} OCR_WAIT
  File /a "${srcdir}\MCR_R2013b_win64_installer.exe"
  ExecWait "$INSTDIR\MCR_R2013b_win64_installer.exe" $3
  ;DetailPrint "MCR installer returned $3"
  ${SetSystemCursor} OCR_NORMAL
  ${If} $3 != 0
    MessageBox MB_OK "Matlab Compiler Runtime was not installed properly.  Motr will not run without it..."
  ${EndIf}
${EndIf}


 
!ifdef notefile
ExecShell "open" "$INSTDIR\${notefile}"
!endif
 
SectionEnd

 
;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
; Uninstaller
; All section names prefixed by "Un" will be in the uninstaller
 
UninstallText "This will uninstall ${prodname}."
 
!ifdef icon
UninstallIcon "${icon}"
!endif
 
;-----------------------------------------------------------------------
Section "Uninstall"
 
SetShellVarContext all

DeleteRegKey HKLM "${uninstkey}"
DeleteRegKey HKLM "${regkey}"
 
;DetailPrint "startmenu: ${startmenu}"
Delete "${startmenu}\*.*"
;DetailPrint "About to delete ${startmenu}..."
RMDir "${startmenu}"
;IfErrors 0 +2
;  DetailPrint "Seems like there was a problem deleting the start menu folder.."

;DetailPrint "Just deleted ${startmenu}, in theory."

!ifdef licensefile
Delete "$INSTDIR\${licensefile}"
!endif
 
!ifdef notefile
Delete "$INSTDIR\${notefile}"
!endif
 
!ifdef icon
Delete "$INSTDIR\${icon}"
!endif
 
Delete "$INSTDIR\${exec}"
Delete "$INSTDIR\${exec2}"
Delete "$INSTDIR\MCR_R2013b_win64_installer.exe"
 
!ifdef unfiles
!include "${unfiles}"
!endif
 
SectionEnd
