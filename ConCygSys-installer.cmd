@echo off

:: ConCygSys: Cygwin and ConEmu portable installer https://github.com/zhubanRuban/ConCygSys-cygwin-portable
:: Copyright zhubanRuban: https://github.com/zhubanRuban
:: Licensed under the Apache License 2.0: http://www.apache.org/licenses/LICENSE-2.0
:: Independent fork of cygwin-portable-installer: https://github.com/vegardit/cygwin-portable-installer

set CONCYGSYS_VERSION=190907b1


::======================= begin SCRIPT SETTINGS =======================
:: If you want to use a Windows %variable% in setting, surround it by % - %%variable%%
:: Not required if you edit settings in update.cmd after Cygwin installation
:: Settings with (*) are considered optimal and should not be touched unless it is absolutely necessary

::+++++++++++++ Cygwin settings

:: Custom home folder path (!) without quotes ' "
:: Examples:
::   /home/cygwinhome
::   C:\cygwinhome
::   C:\Users\yourusername\Documents\cygwinhome
::   %%USERPROFILE%%\Documents\cygwinhome
:: Leave empty to use default one - /home/concygsys
set CYGWIN_HOME=

:: specify default launcher for Cygwin
:: if specified launcher is not available, defaults to next available one in the following order: conemu mintty cmd
set LAUNCHER_CYGWIN=conemu

:: Select the packages to be installed automatically: https://cygwin.com/packages/package_list.html
:: You will be able to install other packages later with apt-cyg if INSTALL_APT_CYG is set to yes below
set CYGWIN_PACKAGES=bind-utils,inetutils,openssh,vim,whois

:: You can choose the closest mirror: https://cygwin.com/mirrors.html
set CYGWIN_MIRROR=

:: Set proxy, if required, in the following format:	proxyip:port
:: Applies to installation process and to setting of installed cygwin instance
set PROXY_HOST=

:: Override OS architecture, if required: "32" bit or "64" bit system. Leave empty for autodetect
set CYGWIN_ARCH=

:: Cygwin uses ACLs to implement real Unix permissions which are not supported by Windows: https://cygwin.com/cygwin-ug-net/using-filemodes.html
:: However, if you move installation to different directory or PC, ACLs will be broken and will have troubles running Cygwin binaries
:: Set to 'yes' if you want real Unix permissions to the detriment of portability
:: Set to 'no' if you want fully portable environment
:: Min. permissions with disabled ACLs: "-r--r--r--" or "444". Max.: "-rw-r--r--" or "644". .*exe files or files with shebang will be 755
set INSTALL_ACL=no

::+++++++++++++ Addons

:: Install apt-cyg command line package manager for Cygwin: https://github.com/transcode-open/apt-cyg
:: Why not using https://github.com/kou1okada/apt-cyg :	https://github.com/kou1okada/apt-cyg#requirements https://github.com/kou1okada/apt-cyg/issues/24
set INSTALL_APT_CYG=yes

:: Space-separated list of additional scripts URL to execute after Cygwin installation
:: They will be downloaded with wget and passed to bash. Commands available to custom scripts: cygwin base + wget + apt-cyg
set INSTALL_ADDONS= ^
https://github.com/zhubanRuban/cygwin-extras/raw/master/inputrc_custom_bind_install.sh ^
https://github.com/zhubanRuban/cygwin-extras/raw/master/ssh-pageant_install.sh

::+++++++++++++ ConEmu settings

:: Install ConEmu quake-style terminal https://conemu.github.io/
set INSTALL_CONEMU=yes

:: https://conemu.github.io/en/ConEmuArgs.html
set CONEMU_OPTIONS=

:: How Cygwin or WSL will be launched in ConEmu multitab terminal, available options:
::   Mintty	: will be launched via mintty
::   Connector	: will be launched via ConEmu connector https://conemu.github.io/en/CygwinMsysConnector.html
::   Cmd	: will be launched via standard Windown console
set CONEMUTASK_DEFAULT=Mintty

::+++++++++++++ Settings for WSL

:: Install WSLbridge allowing to access WSL via Mintty https://github.com/rprichard/wslbridge (WSLtty emulation https://github.com/mintty/wsltty)
set INSTALL_WSLBRIDGE=yes

:: Specify default launcher for WSL
:: If specified launcher is not available, defaults to next available one in the following order: conemu mintty cmd
set LAUNCHER_WSLBRIDGE=conemu

::======================= end SCRIPT SETTINGS =======================


echo.
set CONCYGSYS_LINK=https://github.com/zhubanRuban/ConCygSys-cygwin-portable
set CONCYGSYS_INFO=ConCygSys v.%CONCYGSYS_VERSION% %CONCYGSYS_LINK%
echo %CONCYGSYS_INFO%
echo.

:: %~dp0 means current directory with backslash at the end
set INSTALL_ROOT=%~dp0
set CYGWIN_ROOT=%INSTALL_ROOT%cygwin
set Concygsys_settings_name=update.cmd
set Concygsys_settings=%INSTALL_ROOT%%Concygsys_settings_name%
set Concygsys_settings_temp=%INSTALL_ROOT%ConCygSys-update.cmd

if exist "%CYGWIN_ROOT%\bin" (
	set "PATH=%CYGWIN_ROOT%\bin;PATH=%CYGWIN_ROOT%\usr\local\bin;%PATH%"
	set BASH=bash --noprofile --norc -c
)
::==========================================================	

:retryupdate
setlocal EnableDelayedExpansion
if not exist "%CYGWIN_ROOT%" (
	echo Creating Cygwin folder %CYGWIN_ROOT%...
	md "%CYGWIN_ROOT%"
) else (
	echo Existing Cygwin folder detected: %CYGWIN_ROOT%
	echo Entering update mode...
	set UPDATEMODE=yes
	%SystemRoot%\System32\wbem\WMIC.exe process get ExecutablePath 2>NUL | find /I "%CYGWIN_ROOT%">NUL
	:: multiple :: in if loop cause"system cannot find disk" warning, using rem further
	rem why not using "%ERRORLEVEL%"=="0": https://social.technet.microsoft.com/Forums/en-US/e72cb532-3da0-4c7f-a61e-9ffbf8050b55/batch-errorlevel-always-reports-back-level-0?forum=ITCG
	if not ErrorLevel 1 (
		echo.
		echo ^^!^^!^^! Active Cygwin processes detected ^^!^^!^^!
		echo ==========================================
		%SystemRoot%\System32\wbem\WMIC.exe process get ExecutablePath | find /I "%CYGWIN_ROOT%"
		echo.
		echo The will be terminated during update, please make sure you saved everything before proceeding
		pause
		for /f "usebackq tokens=2" %%i in (`%SystemRoot%\System32\wbem\WMIC.exe process get ProcessId^, ExecutablePath ^| find /I "%CYGWIN_ROOT%"`) do taskkill /f /pid %%i
		goto :retryupdate
	) else (
		if exist "%Concygsys_settings%" (
			xcopy "%Concygsys_settings%" "%Concygsys_settings_temp%" /E /C /H /R /K /O /Y
			sed -i "/^set/ s/%/%%/g" "%Concygsys_settings_temp%"
			call "%Concygsys_settings_temp%" cygwinsettings
			call "%Concygsys_settings_temp%" installoptions
			:: making sure settings from previous versions are transferred properly
			if not "!PROXY_PORT!" == "" (if not "!PROXY_HOST!" == "" (set PROXY_HOST=!PROXY_HOST!:!PROXY_PORT!))
			if not "!HOME_FOLDER!" == "" (set CYGWIN_HOME=!HOME_FOLDER!)
		)
		echo.
		set /p UPDATECYGWINONLY=   [1] then [Enter] : update Cygwin only   [Enter] : update everything 
		echo.
		echo ^^!^^!^^! Before you proceed with update... ^^!^^!^^!
		echo =========================================
		echo.
		echo You may need to backup your cygwin home directory just in case
		echo.
		echo To customize update process:
		echo - close this window
		echo - modify :installoptions section of %Concygsys_settings% file
		echo - re-run update
		echo.
		echo If you are good with existing setup, just hit [Enter] to start update
		echo =======================================================================
		echo.
		pause
	)
)
setlocal DisableDelayedExpansion

::==========================================================

set DOWNLOADER=%INSTALL_ROOT%ConCygSys-downloader.vbs
set GENDOWNLOADER=%INSTALL_ROOT%ConCygSys-downloader-generator.vbs
echo.
if "%PROXY_HOST%" == "" (set DOWNLOADER_PROXY=.) else (
	set DOWNLOADER_PROXY= req.SetProxy 2, "%PROXY_HOST%", ""
	set http_proxy=http://%PROXY_HOST%
	set https_proxy=https://%PROXY_HOST%
	set ftp_proxy=ftp://%PROXY_HOST%
)
echo Creating script that can download files, not using PowerShell which may be blocked by group policies...
(
	echo url = Wscript.Arguments(0^)
	echo target = Wscript.Arguments(1^)
	echo WScript.Echo "Downloading '" ^& url ^& "' to '" ^& target ^& "'..."
	echo Set req = CreateObject("WinHttp.WinHttpRequest.5.1"^)
	echo%DOWNLOADER_PROXY%
	echo req.Open "GET", url, False
	echo req.Send
	echo If req.Status ^<^> 200 Then
	echo 	WScript.Echo "FAILED to download: HTTP Status " ^& req.Status
	echo 	WScript.Quit 1
	echo End If
	echo Set buff = CreateObject("ADODB.Stream"^)
	echo buff.Open
	echo buff.Type = 1
	echo buff.Write req.ResponseBody
	echo buff.Position = 0
	echo buff.SaveToFile target
	echo buff.Close
	echo.
) > "%DOWNLOADER%" || goto :fail

::==========================================================

echo.
if "%CYGWIN_ARCH%" == "" (
	echo CYGWIN_ARCH setting is empty, autodetecting...
	if "%PROCESSOR_ARCHITECTURE%" == "x86" (
		if defined PROCESSOR_ARCHITEW6432 (set CYGWIN_ARCH=64) else (set CYGWIN_ARCH=32)
	) else (set CYGWIN_ARCH=64)
)
echo Choosing correct version of Cygwin installer...
if "%CYGWIN_ARCH%" == "64" (set CYGWIN_SETUP=setup-x86_64.exe) else (set CYGWIN_SETUP=setup-x86.exe)
echo Chosen installer: %CYGWIN_SETUP%
del "%CYGWIN_ROOT%\setup-*.exe" >NUL 2>&1
cscript //Nologo "%DOWNLOADER%" "https://cygwin.org/%CYGWIN_SETUP%" "%CYGWIN_ROOT%\%CYGWIN_SETUP%" || goto :fail

:: https://cygwin.com/faq/faq.html#faq.setup.cli
if "%CYGWIN_MIRROR%" == ""	(set CYGWIN_MIRROR=http://ftp.inf.tu-dresden.de/software/windows/cygwin32)
if "%PROXY_HOST%" == ""		(set CYGWIN_PROXY=) else (set CYGWIN_PROXY=--proxy "%PROXY_HOST%")

:: adding required packages for special software
if "%INSTALL_CONEMU%" == "yes"		(set CYGWIN_PACKAGES=bsdtar,wget,%CYGWIN_PACKAGES%)
if "%INSTALL_WSLBRIDGE%" == "yes"	(set CYGWIN_PACKAGES=bsdtar,wget,%CYGWIN_PACKAGES%)
if "%INSTALL_APT_CYG%" == "yes"		(set CYGWIN_PACKAGES=wget,%CYGWIN_PACKAGES%)
if not "%INSTALL_ADDONS%" == ""		(set CYGWIN_PACKAGES=wget,%CYGWIN_PACKAGES%& set INSTALL_APT_CYG=yes)

:: https://www.cygwin.com/faq/faq.html#faq.setup.cli
echo.
echo Running Cygwin setup...
"%CYGWIN_ROOT%\%CYGWIN_SETUP%" ^
--allow-unsupported-windows ^
--delete-orphans ^
--local-package-dir "%CYGWIN_ROOT%\pkg-cache" ^
--no-admin ^
--no-desktop ^
--no-replaceonreboot ^
--no-shortcuts ^
--no-startmenu ^
--packages dos2unix,%CYGWIN_PACKAGES% ^
--quiet-mode ^
--root "%CYGWIN_ROOT%" ^
--site %CYGWIN_MIRROR% %CYGWIN_PROXY% ^
--upgrade-also || goto :fail

:: warning for standard Cygwin launcher
echo %CONCYGSYS_INFO% > "%CYGWIN_ROOT%\DO-NOT-LAUNCH-CYGWIN-FROM-HERE"

if not "%UPDATECYGWINONLY%" == "" goto :aftercygwinupdate
::==========================================================

set CONEMU_DIR=%INSTALL_ROOT%conemu
set CONEMU_CONFIG=%CONEMU_DIR%\ConEmu.xml
:: Mintty options for ConEmu task: https://cdn.rawgit.com/mintty/mintty/master/docs/mintty.1.html#CONFIGURATION
:: for better experience in running Mintty via ConEmu
set MINTTY_OPTIONS= ^
-o FontHeight=10 ^
-o BoldAsFont=yes ^
-o AllowBlinking=yes ^
-o CopyOnSelect=yes ^
-o RightClickAction=paste ^
-o ScrollbackLines=5000 ^
-o Transparency=off ^
-o ConfirmExit=no

if "%INSTALL_CONEMU%" == "yes" (
	if not exist "%CONEMU_DIR%" (
		echo. & echo Installing ConEmu...
		%BASH% "wget -nv --show-progress -O conemu.7z https://github.com$(wget -qO- https://github.com/Maximus5/ConEmu/releases/latest|grep '/.*/releases/download/.*/.*7z' -o)" || goto :fail
		mkdir -p "%CONEMU_DIR%"
		bsdtar -xf conemu.7z -C "%CONEMU_DIR%" || goto :fail
		echo %CONCYGSYS_INFO% > "%CONEMU_DIR%\DO-NOT-LAUNCH-CONEMU-FROM-HERE"
		rm -f conemu.7z
	)
	if not exist "%CONEMU_CONFIG%" (
		echo. & echo Exporting custom ConEmu config...
		(
			echo ^<?xml version="1.0" encoding="utf-8"?^>
			echo ^<!--
			echo %CONCYGSYS_INFO%
			echo --^>
			echo ^<key name="Software"^>
			echo 	^<key name="ConEmu"^>
			echo 		^<key name=".Vanilla"^>
			echo 			^<value name="StartTasksName" type="string" data="{Cygwin::Mintty}"/^>
			echo 			^<value name="WindowMode" type="dword" data="00000520"/^>
			echo 			^<value name="ShowScrollbar" type="hex" data="01"/^>
			echo 			^<value name="QuakeStyle" type="hex" data="01"/^>
			echo 			^<value name="QuakeAnimation" type="ulong" data="0"/^>
			echo 			^<value name="Min2Tray" type="hex" data="01"/^>
			echo 			^<value name="TryToCenter" type="hex" data="01"/^>
			echo 			^<value name="TabFontHeight" type="long" data="12"/^>
			echo 			^<value name="TabsLocation" type="hex" data="01"/^>
			echo 			^<value name="TabFontFace" type="string" data="Arial Black"/^>
			echo 			^<value name="TabConsole" type="string" data="%%m⬛ m%%s"/^>
			echo 			^<value name="TabModifiedSuffix" type="string" data="*"/^>
			echo 			^<value name="TabDblClick" type="ulong" data="3"/^>
			echo 			^<value name="AlphaValue" type="hex" data="dd"/^>
			echo 			^<value name="StatusBar.Show" type="hex" data="00"/^>
			echo 			^<value name="CTS.IntelligentExceptions" type="string" data="far"/^>
			echo 			^<value name="CTS.ResetOnRelease" type="hex" data="01"/^>
			echo 			^<value name="KeyboardHooks" type="hex" data="01"/^>
			echo 			^<value name="UseInjects" type="hex" data="01"/^>
			echo 			^<value name="Update.CheckOnStartup" type="hex" data="01"/^>
			echo 			^<value name="Update.UseBuilds" type="hex" data="02"/^>
			echo 			^<value name="FontUseUnits" type="hex" data="01"/^>
			echo 			^<value name="FontSize" type="ulong" data="14"/^>
			echo 			^<value name="StatusFontHeight" type="long" data="12"/^>
			echo 			^<value name="KillSshAgent" type="hex" data="00"/^>
			echo 			^<key name="HotKeys"^>
			echo 				^<value name="MinimizeRestore" type="dword" data="000011c0"/^>
			echo 			^</key^>
			echo			^<key name="Colors"^>
			echo				^<value name="Count" type="long" data="0"/^>
			echo			^</key^>
			echo 			^<key name="Tasks"^>
			echo 				^<value name="Count" type="long" data="6"/^>
			echo 				^<key name="Task1"^>
			echo 					^<value name="Name" type="string" data="{Cygwin::Cmd}"/^>
			echo 					^<value name="Flags" type="dword" data="00000004"/^>
			echo 					^<value name="Hotkey" type="dword" data="00000000"/^>
			echo 					^<value name="GuiArgs" type="string" data=""/^>
			echo 					^<value name="Cmd1" type="string" data='"%%ConEmuDir%%\..\cygwin\bin\bash.exe" -li -cur_console:pm:"/mnt":P:"&lt;xterm&gt;":h5000'/^>
			echo 					^<value name="Active" type="long" data="0"/^>
			echo 					^<value name="Count" type="long" data="1"/^>
			echo 				^</key^>
			echo 				^<key name="Task2"^>
			echo 					^<value name="Name" type="string" data="{Cygwin::Connector}"/^>
			echo 					^<value name="Flags" type="dword" data="00000004"/^>
			echo 					^<value name="Hotkey" type="dword" data="00000000"/^>
			echo 					^<value name="GuiArgs" type="string" data=""/^>
			echo 					^<value name="Cmd1" type="string" data='set "PATH=%%ConEmuDir%%\..\cygwin\bin;%%PATH%%" ^&amp; "%%ConEmuBaseDirShort%%\conemu-cyg-%CYGWIN_ARCH%.exe" "%%ConEmuDir%%\..\cygwin\bin\bash.exe" -li -cur_console:pm:"/mnt":P:"&lt;xterm&gt;":h5000'/^>
			echo 					^<value name="Active" type="long" data="0"/^>
			echo 					^<value name="Count" type="long" data="1"/^>
			echo 				^</key^>
			echo 				^<key name="Task3"^>
			echo 					^<value name="Name" type="string" data="{Cygwin::Mintty}"/^>
			echo 					^<value name="Flags" type="dword" data="00000005"/^>
			echo 					^<value name="Hotkey" type="dword" data="00000000"/^>
			echo 					^<value name="GuiArgs" type="string" data='/icon " "'/^>
			echo 					^<value name="Cmd1" type="string" data='"%%ConEmuDir%%\..\cygwin\bin\mintty.exe" %MINTTY_OPTIONS% - -cur_console:pm:"/mnt":P:"&lt;xterm&gt;"'/^>
			echo 					^<value name="Active" type="long" data="0"/^>
			echo 					^<value name="Count" type="long" data="1"/^>
			echo 				^</key^>
			echo 				^<key name="Task4"^>
			echo 					^<value name="Name" type="string" data="{WSL::Cmd}"/^>
			echo 					^<value name="Flags" type="dword" data="00000004"/^>
			echo 					^<value name="Hotkey" type="dword" data="00000000"/^>
			echo 					^<value name="GuiArgs" type="string" data=""/^>
			echo 					^<value name="Cmd1" type="string" data='"%%SystemRoot%%\system32\bash.exe" ~ -cur_console:pm:"/mnt":P:"&lt;ubuntu&gt;":h5000'/^>
			echo 					^<value name="Active" type="long" data="0"/^>
			echo 					^<value name="Count" type="long" data="1"/^>
			echo 				^</key^>
			echo 				^<key name="Task5"^>
			echo 					^<value name="Name" type="string" data="{WSL::Connector}"/^>
			echo 					^<value name="Flags" type="dword" data="00000004"/^>
			echo 					^<value name="Hotkey" type="dword" data="00000000"/^>
			echo 					^<value name="GuiArgs" type="string" data=""/^>
			echo 					^<value name="Cmd1" type="string" data='set "PATH=%%ConEmuBaseDirShort%%\wsl;%%PATH%%" ^&amp; "%%ConEmuBaseDirShort%%\conemu-cyg-%CYGWIN_ARCH%.exe" --wsl -C~ -cur_console:pm:"/mnt":P:"&lt;ubuntu&gt;":h5000'/^>
			echo 					^<value name="Active" type="long" data="0"/^>
			echo 					^<value name="Count" type="long" data="1"/^>
			echo 				^</key^>
			echo 				^<key name="Task6"^>
			echo 					^<value name="Name" type="string" data="{WSL::Mintty}"/^>
			echo 					^<value name="Flags" type="dword" data="00000004"/^>
			echo 					^<value name="Hotkey" type="dword" data="00000000"/^>
			echo 					^<value name="GuiArgs" type="string" data='/icon " "'/^>
			echo 					^<value name="Cmd1" type="string" data='"%%ConEmuDir%%\..\cygwin\bin\mintty.exe" %MINTTY_OPTIONS% --WSL=  -~ -cur_console:pm:"/mnt":P:"&lt;xterm&gt;"'/^>
			echo 					^<value name="Active" type="long" data="0"/^>
			echo 					^<value name="Count" type="long" data="1"/^>
			echo 				^</key^>
			echo 			^</key^>
			echo 		^</key^>
			echo 	^</key^>
			echo ^</key^>
		) > "%CONEMU_CONFIG%" || goto :fail
	)
) else (
	rm -rf "%CONEMU_DIR%"
)

::==========================================================

if "%INSTALL_WSLBRIDGE%" == "yes" (
	echo. & echo Installing WSLbridge...
	%BASH% "wget -nv --show-progress -O wslbridge.tar.gz https://github.com$(wget -qO- https://github.com/rprichard/wslbridge/releases/latest|/bin/grep '/.*/releases/download/.*/.*cygwin%CYGWIN_ARCH%.tar.gz' -o)" || goto :fail
	bsdtar -xf wslbridge.tar.gz --strip-components=1 -C "%CYGWIN_ROOT%\bin\\" */wslbridge* || goto :fail
	rm -f wslbridge.tar.gz
) else (
	rm -f /bin/wslbridge*
)

::==========================================================

echo. & echo Generating the launchers...
del "%INSTALL_ROOT%Cygwin-*.cmd" "%INSTALL_ROOT%*-Launcher.cmd" >NUL 2>&1
echo Generating Cygwin launcher...
(
	echo @echo off
	echo :: %CONCYGSYS_INFO%
	echo call "%%~dp0%Concygsys_settings_name%" cygwinsettings
	echo if "%%CYGWIN_HOME%%" == "" (set HOME=/home/concygsys^) else (set HOME=%%CYGWIN_HOME%%^)
	echo if not "%%PROXY_HOST%%" == "" (
	echo 	set http_proxy=http://%%PROXY_HOST%%
	echo 	set https_proxy=https://%%PROXY_HOST%%
	echo 	set ftp_proxy=ftp://%%PROXY_HOST%%
	echo ^)
	echo set "PATH=%%~dp0cygwin\bin;%%PATH%%"
	echo echo.
	echo setlocal enableextensions
	echo set TERM=
	echo set CYGWIN_ROOT=%%~dp0cygwin
	echo sed -i '/^last-cache/!b;n;c\\\t%%CYGWIN_ROOT:\=\\\%%\\\.pkg-cache' /etc/setup/setup.rc
	echo rm -rf "%%CYGWIN_ROOT%%\*pkg-cache"
	if not "%INSTALL_ACL%" == "yes" (
		echo.
		echo set FSTAB=%%CYGWIN_ROOT:\=/%% ^& set=%%FSTAB: =\040%%
		echo (
		echo 	echo %%FSTAB%%/bin /usr/bin none noacl 0 0
		echo 	echo %%FSTAB%%/lib /usr/lib none noacl 0 0
		echo 	echo %%FSTAB%% / none override,noacl 0 0
		echo 	echo none /cygdrive cygdrive noacl,user 0 0
		echo ^) ^> "%%CYGWIN_ROOT%%\etc\fstab" ^& dos2unix /etc/fstab
	) else (
		rm -f /etc/fstab
	)
	echo if not "%%LAUNCHER_CYGWIN%%" == "" (goto :%%LAUNCHER_CYGWIN%%^)
	echo.
	echo :conemu
	if "%INSTALL_CONEMU%" == "yes" (
		echo cd /d "%%USERPROFILE%%"
		echo start "" "%%CYGWIN_ROOT%%\..\conemu\ConEmu%CYGWIN_ARCH:32=%.exe" %%CONEMU_OPTIONS%% -run {Cygwin::%%CONEMUTASK_DEFAULT%%}
		echo exit
	)
	echo :mintty
	echo start "" "%%CYGWIN_ROOT%%\bin\mintty.exe" -
	echo exit
	echo :cmd
	echo start "" "%%CYGWIN_ROOT%%\bin\bash.exe" -li
	echo exit
) > "%INSTALL_ROOT%Cygwin-Launcher.cmd" || goto :fail

if "%INSTALL_WSLBRIDGE%" == "yes" (
	echo Generating WSL launcher...
	(
		echo @echo off
		echo :: %CONCYGSYS_INFO%
		echo if not "%%LAUNCHER_WSLBRIDGE%%" == "" (goto :%%LAUNCHER_WSLBRIDGE%%^)
		echo.
		echo :conemu
		if "%INSTALL_CONEMU%" == "yes" (
			echo start "" "%%~dp0conemu\ConEmu%%CYGWIN_ARCH:32=%%.exe" %%CONEMU_OPTIONS%% -run {WSL::%%CONEMUTASK_DEFAULT%%}
			echo exit
		)
		echo :mintty
		echo start "" "%%~dp0cygwin\bin\mintty.exe" --WSL=  -~
		echo exit
		echo :cmd
		echo start "" "%%~dp0cygwin\bin\mintty.exe" --WSL=  -~
		echo exit
	) > "%INSTALL_ROOT%WSL-Launcher.cmd" || goto :fail
)

::==========================================================

echo Generating one-file settings and updater file...
(
	echo @echo off
	echo :: %CONCYGSYS_INFO%
	echo if "%%1" == "cygwinsettings" goto :cygwinsettings
	echo if "%%1" == "installoptions" goto :installoptions
	echo goto :update
	echo.
	echo :: %CONCYGSYS_LINK%#customization
	echo.
	echo :cygwinsettings
	echo :: these settings will be applied on next launcher run
	echo set CYGWIN_HOME=%CYGWIN_HOME%
	echo set LAUNCHER_CYGWIN=%LAUNCHER_CYGWIN%
	echo set PROXY_HOST=%PROXY_HOST%
	echo set CONEMU_OPTIONS=%CONEMU_OPTIONS%
	echo set CONEMUTASK_DEFAULT=%CONEMUTASK_DEFAULT%
	echo set LAUNCHER_WSLBRIDGE=%LAUNCHER_WSLBRIDGE%
	echo exit /b
	echo.
	echo :installoptions
	echo :: these settings will be applied after you run %Concygsys_settings_name%
	echo :: specify CYGWIN_PACKAGES only if you need new packages not installed at the moment
	echo set CYGWIN_PACKAGES=
	echo set CYGWIN_MIRROR=%CYGWIN_MIRROR%
	echo set CYGWIN_ARCH=%CYGWIN_ARCH%
	echo set INSTALL_ACL=%INSTALL_ACL%
	echo set INSTALL_APT_CYG=%INSTALL_APT_CYG%
	echo set INSTALL_ADDONS=%INSTALL_ADDONS%
	echo set INSTALL_CONEMU=%INSTALL_CONEMU%
	echo set INSTALL_WSLBRIDGE=%INSTALL_WSLBRIDGE%
	echo exit /b
	echo.
	echo :update
	echo echo %CONCYGSYS_INFO%
	echo set DOWNLOADER=%%~dp0downloader.vbs
	echo call "%0" cygwinsettings
	echo if "%%PROXY_HOST%%" == "" (set DOWNLOADER_PROXY=.^) else (set DOWNLOADER_PROXY= req.SetProxy 2, "%%PROXY_HOST%%", ""^)
	echo echo Creating a script that can download files...
	echo (
	echo 	echo url = Wscript.Arguments(0^^^)
	echo 	echo target = Wscript.Arguments(1^^^)
	echo 	echo WScript.Echo "Downloading '" ^^^& url ^^^& "' to '" ^^^& target ^^^& "'..."
	echo 	echo Set req = CreateObject("WinHttp.WinHttpRequest.5.1"^^^)
	echo 	echo%DOWNLOADER_PROXY%
	echo 	echo req.Open "GET", url, False
	echo 	echo req.Send
	echo 	echo If req.Status ^^^<^^^> 200 Then
	echo 	echo 	WScript.Echo "FAILED to download: HTTP Status " ^^^& req.Status
	echo 	echo 	WScript.Quit 1
	echo 	echo End If
	echo 	echo Set buff = CreateObject("ADODB.Stream"^^^)
	echo 	echo buff.Open
	echo 	echo buff.Type = 1
	echo 	echo buff.Write req.ResponseBody
	echo 	echo buff.Position = 0
	echo 	echo buff.SaveToFile target
	echo 	echo buff.Close
	echo 	echo.
	echo ^) ^> "%%DOWNLOADER%%" ^|^| goto :fail
	echo set INSTALLER=ConCygSys-installer.cmd
	echo set INSTALLER_URL=https://github.com/zhubanRuban/ConCygSys-cygwin-portable/raw/beta/%%INSTALLER%%
	echo cscript //Nologo "%%DOWNLOADER%%" "%%INSTALLER_URL%%" "%%INSTALLER%%" ^|^| goto :fail
	echo start "" "%%INSTALLER%%" ^|^| goto :fail
	echo exit 0
	echo :fail
	echo echo.
	echo echo FAIL. Try uploading installer manually from %CONCYGSYS_LINK%
	echo echo.
	echo pause
	echo exit 1
) > "%Concygsys_settings%" || goto :fail

::==========================================================

if "%INSTALL_APT_CYG%" == "yes" (
	echo. & echo Installing apt-cyg...
	wget -nv --show-progress -O /usr/local/bin/apt-cyg https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
	chmod +x /usr/local/bin/apt-cyg
) else (
	rm -f /usr/local/bin/apt-cyg /bin/apt-cyg
)

if not "%INSTALL_ADDONS%" == "" (
	echo. & echo Installing addons: ...
	for %%addon in (%INSTALL_ADDONS%) do (
		wget -nv --show-progress -O ConCygSys-addon.sh "%%addon" || goto :fail
		bash --noprofile --norc ConCygSys-addon.sh
	)
)

::==========================================================

echo. & echo Cleaning up...
:: files left by previous concygsys versions
rd /s /q "%INSTALL_ROOT%data" >NUL 2>&1 & del "%CYGWIN_ROOT%\updater.cmd" "%CYGWIN_ROOT%\cygwin-*.cmd" "%CYGWIN_ROOT%\portable-init.sh" >NUL 2>&1
:: writing README
(
	echo %CONCYGSYS_INFO%
	echo Change settings:	right click on "%Concygsys_settings_name%" ^> Edit
	echo Update:		launch "%Concygsys_settings_name%"
	echo More info:	%CONCYGSYS_LINK%#customization
) > "%INSTALL_ROOT%README.md" & rename "%INSTALL_ROOT%README.md" "%INSTALL_ROOT%README.txt"


:aftercygwinupdate
::==========================================================

echo.
if "%UPDATEMODE%" == "yes" (
	echo ======================== Update SUCCEEDED ========================
) else (
	echo ===================== Installation SUCCEEDED =====================
)
echo.
pause
del "%INSTALL_ROOT%ConCygSys*" >NUL 2>&1
exit 0


:fail
echo.
if "%UPDATEMODE%" == "yes" (
	echo ========================= Update FAILED ==========================
	echo Try uploading installer manually from %CONCYGSYS_LINK%
) else (
	echo ====================== Installation FAILED =======================
)
echo.
pause
exit 1
