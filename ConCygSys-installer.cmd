@echo off

:: ConCygSys: Cygwin and ConEmu portable installer: https://github.com/zhubanRuban/ConCygSys-cygwin-portable
:: Copyright zhubanRuban: https://github.com/zhubanRuban
:: Licensed under the Apache License 2.0: http://www.apache.org/licenses/LICENSE-2.0
:: Independent fork of cygwin-portable-installer: https://github.com/vegardit/cygwin-portable-installer

set CONCYGSYS_VERSION=190913b1


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

:: Comma-separated list of the packages to be installed automatically: https://cygwin.com/packages/package_list.html
:: You will be able to install other packages later with apt-cyg if INSTALL_APT_CYG is set to yes below
set CYGWIN_PACKAGES=bind-utils,inetutils,openssh,vim,whois

:: You can choose the closest mirror: https://cygwin.com/mirrors.html
set CYGWIN_MIRROR=

:: Set proxy, if required, in the following format:	proxyip:port
:: Applies to installation process and to setting of installed cygwin instance
set PROXY_HOST=

:: Override OS architecture, if required: "32" bit or "64" bit system. Leave empty for autodetect
set CYGWIN_ARCH=

::+++++++++++++ Addons

:: Install apt-cyg command line package manager for Cygwin: https://github.com/transcode-open/apt-cyg
:: Why not using https://github.com/kou1okada/apt-cyg :	https://github.com/kou1okada/apt-cyg#requirements https://github.com/kou1okada/apt-cyg/issues/24
set INSTALL_APT_CYG=yes

:: Install and configure ssh-pageant: https://github.com/cuviper/ssh-pageant
set INSTALL_SSH_PAGEANT=yes

:: Space-separated list of additional scripts URL to execute after Cygwin installation
:: They will be downloaded with wget and passed to bash. Commands available by default to custom scripts: cygwin base + wget + apt-cyg
:: The example can be found here: https://github.com/zhubanRuban/cygwin-extras/raw/master/ssh-pageant_install.sh
set INSTALL_ADDONS=
:: Alternatively you can create a folder called 'addons' near installer and place your sh scripts there
:: They will be executed during installation and during next update

::+++++++++++++ ConEmu settings

:: Install ConEmu quake-style terminal https://conemu.github.io/
set INSTALL_CONEMU=yes

:: How Cygwin or WSL will be launched in ConEmu multitab terminal, available options:
::   Mintty	: will be launched via mintty
::   Connector	: will be launched via ConEmu connector https://conemu.github.io/en/CygwinMsysConnector.html
::   Cmd	: will be launched via standard Windown console
set CONEMUTASK_DEFAULT=Mintty

::+++++++++++++ Settings for WSL

:: Install WSLbridge allowing to access WSL via Mintty https://github.com/rprichard/wslbridge (WSLtty emulation https://github.com/mintty/wsltty)
set INSTALL_WSLBRIDGE=no

:: Specify default launcher for WSL
:: If specified launcher is not available, defaults to next available one in the following order: conemu mintty cmd
set LAUNCHER_WSLBRIDGE=conemu

::======================= end SCRIPT SETTINGS =======================


echo.
set CONCYGSYS_LINK=https://github.com/zhubanRuban/ConCygSys-cygwin-portable
set CONCYGSYS_INFO=ConCygSys v.%CONCYGSYS_VERSION% %CONCYGSYS_LINK%
echo %CONCYGSYS_INFO%
echo.

set CYGWIN_DIR=cygwin
set CYGWIN_ROOT=%~dp0%CYGWIN_DIR%
set Concygsys_settings=update.cmd
set Concygsys_settings_temp=ConCygSys-%Concygsys_settings%
set "PATH=%CYGWIN_ROOT%\bin;PATH=%CYGWIN_ROOT%\usr\local\bin;%PATH%"
set BASH=bash --noprofile --norc -c

::==========================================================	

:retryupdate
setlocal EnableDelayedExpansion
if exist %CYGWIN_DIR% (
	echo Existing Cygwin folder detected, switching to update mode...
	set UPDATEMODE=yes
	%SystemRoot%\System32\wbem\WMIC.exe process get ExecutablePath | findstr "%CYGWIN_ROOT%" >NUL 2>&1
	:: multiple :: in if loop cause"system cannot find disk" warning, using rem further
	rem why not using "%ERRORLEVEL%"=="0": https://social.technet.microsoft.com/Forums/en-US/e72cb532-3da0-4c7f-a61e-9ffbf8050b55/batch-errorlevel-always-reports-back-level-0?forum=ITCG
	if not ErrorLevel 1 (
		echo.
		echo ^^!^^!^^! Active Cygwin processes detected ^^!^^!^^!
		echo ==========================================
		%SystemRoot%\System32\wbem\WMIC.exe process where "ExecutablePath like '%%%CYGWIN_ROOT:\=\\%%%'" get ExecutablePath, ProcessId
		echo.
		echo They will be terminated during update, please make sure you saved everything before proceeding
		pause
		for /f "usebackq" %%p in (`%SystemRoot%\System32\wbem\WMIC.exe process where "ExecutablePath like '%%%CYGWIN_ROOT:\=\\%%%'" get ProcessId`) do taskkill /f /pid %%p >NUL 2>&1
		goto :retryupdate
	) else (
		if exist "%Concygsys_settings%" (
			copy /y "%Concygsys_settings%" "%Concygsys_settings_temp%" >NUL 2>&1
			:: escaping % in existing config
			sed -i '/^^set/ s/%%/%%%%/g' "%Concygsys_settings_temp%"
			echo Reading existing settings from %Concygsys_settings_temp% ...
			call "%Concygsys_settings_temp%" cygwinsettings
			call "%Concygsys_settings_temp%" installoptions
			del /f /q "%Concygsys_settings_temp%" >NUL 2>&1
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
) else (
	mkdir %CYGWIN_DIR% >NUL 2>&1
)
setlocal DisableDelayedExpansion

::==========================================================

set DOWNLOADER=ConCygSys-downloader.vbs
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
) > %DOWNLOADER% || goto :fail

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
set CYGWIN_SETUP_PATH=%CYGWIN_DIR%\%CYGWIN_SETUP%
cscript //Nologo %DOWNLOADER% https://cygwin.org/%CYGWIN_SETUP% %CYGWIN_SETUP_PATH% || goto :fail

:: https://cygwin.com/faq/faq.html#faq.setup.cli
if "%CYGWIN_MIRROR%" == ""	(set CYGWIN_MIRROR=ftp://ftp-stud.hs-esslingen.de/pub/Mirrors/sources.redhat.com/cygwin/)
if "%PROXY_HOST%" == ""		(set CYGWIN_PROXY=) else (set CYGWIN_PROXY=--proxy "%PROXY_HOST%")

:: adding required packages for special software
if "%INSTALL_CONEMU%" == "yes"		(set CYGWIN_PACKAGES=bsdtar,wget,%CYGWIN_PACKAGES%)
if "%INSTALL_WSLBRIDGE%" == "yes"	(set CYGWIN_PACKAGES=bsdtar,wget,%CYGWIN_PACKAGES%)
if "%INSTALL_APT_CYG%" == "yes"		(set CYGWIN_PACKAGES=wget,%CYGWIN_PACKAGES%)
if "%INSTALL_SSH_PAGEANT%" == "yes"	(set CYGWIN_PACKAGES=ssh-pageant,%CYGWIN_PACKAGES%)
if not "%INSTALL_ADDONS%" == ""		(set CYGWIN_PACKAGES=wget,%CYGWIN_PACKAGES%& set INSTALL_APT_CYG=yes)

:: https://www.cygwin.com/faq/faq.html#faq.setup.cli
echo.
echo Running Cygwin setup...
%CYGWIN_SETUP_PATH% ^
--allow-unsupported-windows ^
--delete-orphans ^
--local-package-dir "%TEMP%\cygwin-local-package-dir" ^
--no-admin ^
--no-desktop ^
--no-replaceonreboot ^
--no-shortcuts ^
--no-startmenu ^
--packages dos2unix,%CYGWIN_PACKAGES% ^
--quiet-mode ^
--root %CYGWIN_DIR% ^
--site %CYGWIN_MIRROR% %CYGWIN_PROXY% ^
--upgrade-also || goto :fail

del /f /q %CYGWIN_SETUP_PATH% >NUL 2>&1 & rmdir /s /q "%TEMP%\cygwin-local-package-dir" >NUL 2>&1
:: warning for standard Cygwin launcher
echo %CONCYGSYS_INFO% > %CYGWIN_DIR%\DO-NOT-LAUNCH-CYGWIN-FROM-HERE

:: permanent noacl to prevent issues
set FSTAB=%CYGWIN_ROOT:\=/%
set FSTAB=%FSTAB: =\040%
(
	echo # %CONCYGSYS_INFO%
 	echo %FSTAB%/bin /usr/bin none noacl,posix=0,user 0 0
 	echo %FSTAB%/lib /usr/lib none noacl,posix=0,user 0 0
 	echo %FSTAB% / none override,noacl 0 0
	echo none /tmp usertemp noacl,posix=0,user 0 0
 	echo none /cygdrive cygdrive noacl,user 0 0
	echo # %CONCYGSYS_INFO%
) > %CYGWIN_DIR%\etc\fstab & dos2unix -q %CYGWIN_DIR%\etc\fstab

:: inputrc fix for ctrl+left and ctrl+right to work as expected: https://github.com/zhubanRuban/cygwin-extras#custom-inputrc
copy /y %CYGWIN_DIR%\etc\defaults\etc\skel\.inputrc %CYGWIN_DIR%\etc\skel\.inputrc >NUL 2>&1
(
	echo.
	echo # %CONCYGSYS_INFO%
	echo "\e[1;5C": forward-word	# ctrl + right
	echo "\e[1;5D": backward-word	# ctrl + left
	echo # %CONCYGSYS_INFO%
) > %CYGWIN_DIR%\etc\skel\.inputrc & dos2unix -q %CYGWIN_DIR%\etc\skel\.inputrc

if not "%UPDATECYGWINONLY%" == "" goto :aftercygwinupdate
::==========================================================

if "%INSTALL_APT_CYG%" == "yes" (
	echo. & echo Installing apt-cyg...
	wget -nv --show-progress -O /usr/local/bin/apt-cyg https://github.com/transcode-open/apt-cyg/raw/master/apt-cyg
	chmod +x /usr/local/bin/apt-cyg
)

if "%INSTALL_SSH_PAGEANT%" == "yes" (
	echo. & echo Configuring ssh-pageant...
	echo eval $(/usr/bin/ssh-pageant -r -a "/tmp/.ssh-pageant-$USERNAME"^) > %CYGWIN_DIR%\etc\profile.d\ssh-pageant.sh
	dos2unix -q %CYGWIN_DIR%\etc\profile.d\ssh-pageant.sh
	:: removing previous possible ssh-agent implementations
	rm -f /opt/ssh-agent-tweak
	sed -i '/\/opt\/ssh-agent-tweak/d' ~/.bashrc >NUL 2>&1
)

set ADDONS_DIR=addons
if not "%INSTALL_ADDONS%" == "" (echo. & echo Downloading addons...
	for %%a in (%INSTALL_ADDONS%) do (wget -nv --show-progress -NP %ADDONS_DIR% %%a)
)
if exist "%ADDONS_DIR%" (
	for %%a in (%ADDONS_DIR%\*) do (echo. & echo Installing addon: %%a ... & bash --noprofile --norc %%a)
)

::==========================================================

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

set CONEMU_DIR=conemu
set CONEMU_ARCHIVE=%CONEMU_DIR%.7z
set CONEMU_CONFIG=%CONEMU_DIR%\ConEmu.xml

if "%INSTALL_CONEMU%" == "yes" (echo.
	if not exist %CONEMU_DIR% (
		echo Installing ConEmu...
		%BASH% "wget -nv --show-progress -O %CONEMU_ARCHIVE% https://github.com$(wget -qO- https://github.com/Maximus5/ConEmu/releases/latest|grep /.*/releases/download/.*/.*7z -o)" || goto :fail
		mkdir %CONEMU_DIR% >NUL 2>&1
		echo Extracting... & bsdtar -xf %CONEMU_ARCHIVE% -C %CONEMU_DIR% || goto :fail
		echo %CONCYGSYS_INFO% > %CONEMU_DIR%\DO-NOT-LAUNCH-CONEMU-FROM-HERE
		rm -f %CONEMU_ARCHIVE%
	)
	rem Commented until ConEmu allows importing tasks via command line without replacing the whole config
	rem if not exist "%CONEMU_CONFIG%" (
		echo Replacing ConEmu config...
		(
			echo ^<?xml version="1.0" encoding="utf-8"?^>
			echo ^<!--
			echo %CONCYGSYS_INFO%
			echo --^>
			echo ^<key name="Software"^>
			echo 	^<key name="ConEmu"^>
			echo 		^<key name=".Vanilla"^>
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
			echo 					^<value name="Cmd1" type="string" data='"%%ConEmuDir%%\..\%CYGWIN_DIR%\bin\bash.exe" -li -cur_console:pm:"/mnt":P:"&lt;xterm&gt;":h5000'/^>
			echo 					^<value name="Active" type="long" data="0"/^>
			echo 					^<value name="Count" type="long" data="1"/^>
			echo 				^</key^>
			echo 				^<key name="Task2"^>
			echo 					^<value name="Name" type="string" data="{Cygwin::Connector}"/^>
			echo 					^<value name="Flags" type="dword" data="00000004"/^>
			echo 					^<value name="Hotkey" type="dword" data="00000000"/^>
			echo 					^<value name="GuiArgs" type="string" data=""/^>
			echo 					^<value name="Cmd1" type="string" data='set "PATH=%%ConEmuDir%%\..\%CYGWIN_DIR%\bin;%%PATH%%" ^&amp; "%%ConEmuBaseDirShort%%\conemu-cyg-%CYGWIN_ARCH%.exe" "%%ConEmuDir%%\..\%CYGWIN_DIR%\bin\bash.exe" -li -cur_console:pm:"/mnt":P:"&lt;xterm&gt;":h5000'/^>
			echo 					^<value name="Active" type="long" data="0"/^>
			echo 					^<value name="Count" type="long" data="1"/^>
			echo 				^</key^>
			echo 				^<key name="Task3"^>
			echo 					^<value name="Name" type="string" data="{Cygwin::Mintty}"/^>
			echo 					^<value name="Flags" type="dword" data="00000004"/^>
			echo 					^<value name="Hotkey" type="dword" data="00000000"/^>
			echo 					^<value name="GuiArgs" type="string" data='/icon " "'/^>
			echo 					^<value name="Cmd1" type="string" data='"%%ConEmuDir%%\..\%CYGWIN_DIR%\bin\mintty.exe" %MINTTY_OPTIONS% - -cur_console:pm:"/mnt":P:"&lt;xterm&gt;"'/^>
			echo 					^<value name="Active" type="long" data="0"/^>
			echo 					^<value name="Count" type="long" data="1"/^>
			echo 				^</key^>
			if "%INSTALL_WSLBRIDGE%" == "yes" (
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
				echo 					^<value name="Cmd1" type="string" data='"%%ConEmuDir%%\..\%CYGWIN_DIR%\bin\mintty.exe" %MINTTY_OPTIONS% --WSL= -~ -cur_console:pm:"/mnt":P:"&lt;xterm&gt;"'/^>
				echo 					^<value name="Active" type="long" data="0"/^>
				echo 					^<value name="Count" type="long" data="1"/^>
				echo 				^</key^>
			)
			echo 			^</key^>
			echo 		^</key^>
			echo 	^</key^>
			echo ^</key^>
		) > %CONEMU_CONFIG% || goto :fail
	rem Commented until ConEmu allows importing tasks via command line without replacing the whole config
	rem )
) else (
	rmdir /s /q %CONEMU_DIR% >NUL 2>&1
	
)

::==========================================================

if "%INSTALL_WSLBRIDGE%" == "yes" (
	echo. & echo Installing WSLbridge...
	%BASH% "wget -nv --show-progress -O wslbridge.tar.gz https://github.com$(wget -qO- https://github.com/rprichard/wslbridge/releases/latest|grep /.*/releases/download/.*/.*cygwin%CYGWIN_ARCH%.tar.gz -o)" || goto :fail
	bsdtar -xf wslbridge.tar.gz --strip-components=1 -C %CYGWIN_DIR%\bin */wslbridge* || goto :fail
	rm -f wslbridge.tar.gz
) else (
	del /f /q %CYGWIN_DIR%\bin\wslbridge* >NUL 2>&1
)

::==========================================================

echo. & echo Generating the launchers...
:: files left by previous concygsys versions
del /f /q Cygwin-*.cmd Launch-*.cmd >NUL 2>&1
echo Generating Cygwin launcher...
(
	echo @echo off
	echo :: %CONCYGSYS_INFO%
	echo call %Concygsys_settings% launcherheader
	echo if not "%%LAUNCHER_CYGWIN%%" == "" (goto :%%LAUNCHER_CYGWIN%%^)
	echo.
	echo :conemu
	if "%INSTALL_CONEMU%" == "yes" (
		echo cd /d "%%USERPROFILE%%"
		echo if "%%CONEMUTASK_DEFAULT%%" == "" (set CONEMUTASK_DEFAULT=Mintty^)
		echo start "" "%%~dp0%CONEMU_DIR%\ConEmu%CYGWIN_ARCH:32=%.exe" -run {Cygwin::%%CONEMUTASK_DEFAULT%%}
		echo exit /b
	)
	echo.
	echo :mintty
	echo start "" %CYGWIN_DIR%\bin\mintty.exe -
	echo exit /b
	echo.
	echo :cmd
	echo start "" %CYGWIN_DIR%\bin\bash.exe" -li
	echo.
	echo exit /b
) > Launch-Cygwin.cmd || goto :fail

if "%INSTALL_WSLBRIDGE%" == "yes" (
	echo Generating WSL launcher...
	(
		echo @echo off
		echo :: %CONCYGSYS_INFO%
		echo call %Concygsys_settings% launcherheader
		echo if not "%%LAUNCHER_WSLBRIDGE%%" == "" (goto :%%LAUNCHER_WSLBRIDGE%%^)
		echo.
		echo :conemu
		if "%INSTALL_CONEMU%" == "yes" (
			echo if "%%CONEMUTASK_DEFAULT%%" == "" (set CONEMUTASK_DEFAULT=Mintty^)
			echo start "" "%%~dp0%CONEMU_DIR%\ConEmu%CYGWIN_ARCH:32=%.exe" -run {WSL::%%CONEMUTASK_DEFAULT%%}
			echo exit /b
		)
		echo.
		echo :mintty
		echo start "" %CYGWIN_DIR%\bin\mintty.exe --WSL= -~
		echo exit /b
		echo.
		echo :cmd
		echo start "" %%SystemRoot%%\system32\bash.exe ~
		echo.
		echo exit /b
	) > Launch-WSL.cmd || goto :fail
)

::==========================================================

echo Generating one-file settings and updater file...
(
	echo @echo off
	echo :: %CONCYGSYS_INFO%
	echo if "%%1" == "cygwinsettings" goto :cygwinsettings
	echo if "%%1" == "installoptions" goto :installoptions
	echo if "%%1" == "launcherheader" goto :launcherheader
	echo goto :update
	echo.
	echo ::====================================================
	echo :: Customization guide: %CONCYGSYS_LINK%#customization
	echo.
	echo :cygwinsettings
	echo :: these settings will be applied on next launcher run
	echo set CYGWIN_HOME=%CYGWIN_HOME%
	echo set LAUNCHER_CYGWIN=%LAUNCHER_CYGWIN%
	if "%INSTALL_WSLBRIDGE%" == "yes" (echo set LAUNCHER_WSLBRIDGE=%LAUNCHER_WSLBRIDGE%)
	if "%INSTALL_CONEMU%" == "yes" (echo set CONEMUTASK_DEFAULT=%CONEMUTASK_DEFAULT%)
	echo set PROXY_HOST=%PROXY_HOST%
	echo exit /b
	echo.
	echo :installoptions
	echo :: these settings will be applied after you run %Concygsys_settings%
	echo :: specify CYGWIN_PACKAGES only if you need new packages not installed at the moment
	echo set CYGWIN_PACKAGES=
	echo set CYGWIN_MIRROR=%CYGWIN_MIRROR%
	echo set CYGWIN_ARCH=%CYGWIN_ARCH%
	echo set INSTALL_APT_CYG=%INSTALL_APT_CYG%
	echo set INSTALL_ADDONS=
	echo set INSTALL_CONEMU=%INSTALL_CONEMU%
	echo set INSTALL_WSLBRIDGE=%INSTALL_WSLBRIDGE%
	echo exit /b
	echo ::====================================================
	echo.
	echo :launcherheader
	echo call %%~nx0 cygwinsettings
	echo.
	echo set "PATH=%%~dp0%CYGWIN_DIR%\bin;%%PATH%%"
	echo if "%%CYGWIN_HOME%%" == "" (set HOME=/home/concygsys^) else (set HOME=%%CYGWIN_HOME%%^)
	echo if not "%%PROXY_HOST%%" == "" (
	echo 	set http_proxy=http://%%PROXY_HOST%%
	echo 	set https_proxy=https://%%PROXY_HOST%%
	echo 	set ftp_proxy=ftp://%%PROXY_HOST%%
	echo ^)
	echo echo.
	echo setlocal enableextensions
	echo set TERM=
	echo set CYGWIN_ROOT=%%~dp0%CYGWIN_DIR%
	echo.
	echo set FSTAB=%%CYGWIN_ROOT:\=/%%
	echo set FSTAB=%%FSTAB: =\040%%
	echo (
	echo 	echo # %CONCYGSYS_INFO%
 	echo 	echo %%FSTAB%%/bin /usr/bin none noacl,posix=0,user 0 0
 	echo 	echo %%FSTAB%%/lib /usr/lib none noacl,posix=0,user 0 0
 	echo 	echo %%FSTAB%% / none override,noacl 0 0
	echo 	echo none /tmp usertemp noacl,posix=0,user 0 0
 	echo 	echo none /cygdrive cygdrive noacl,user 0 0
	echo 	echo # %CONCYGSYS_INFO%
	echo ^) ^> "%%CYGWIN_ROOT%%\etc\fstab" ^& dos2unix -q "%%CYGWIN_ROOT%%\etc\fstab"
	echo.
	echo sed -i '/^last-cache/!b;n;c\\\t%%TEMP:\=\\\%%\\\cygwin-local-package-dir' /etc/setup/setup.rc
	echo exit /b
	echo.
	echo :update
	echo echo %CONCYGSYS_INFO%
	echo set DOWNLOADER=%DOWNLOADER%
	echo call %%~nx0 cygwinsettings
	echo if "%%PROXY_HOST%%" == "" (set DOWNLOADER_PROXY=.^) else (set DOWNLOADER_PROXY= req.SetProxy 2, "%%PROXY_HOST%%", ""^)
	echo echo Creating a script that can download files...
	echo (
	echo 	echo url = Wscript.Arguments(0^^^)
	echo 	echo target = Wscript.Arguments(1^^^)
	echo 	echo WScript.Echo "Downloading '" ^^^& url ^^^& "' to '" ^^^& target ^^^& "'..."
	echo 	echo Set req = CreateObject("WinHttp.WinHttpRequest.5.1"^^^)
	echo 	echo%%DOWNLOADER_PROXY%%
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
	echo ^) ^> %%DOWNLOADER%% ^|^| goto :fail
	echo set INSTALLER=%~nx0
	echo set INSTALLER_URL=https://github.com/zhubanRuban/ConCygSys-cygwin-portable/raw/beta/%%INSTALLER%%
	echo cscript //Nologo %%DOWNLOADER%% %%INSTALLER_URL%% %%INSTALLER%% ^|^| goto :fail
	echo start "" %%INSTALLER%% ^|^| goto :fail
	echo exit /b
	echo :fail
	echo echo.
	echo echo ========================= Update FAILED ==========================
	echo echo Try uploading installer manually from %CONCYGSYS_LINK%
	echo echo.
	echo pause
	echo exit /b 1
) > %Concygsys_settings% || goto :fail

::==========================================================

echo. & echo Generating README.txt
(
	echo %CONCYGSYS_INFO%
	echo Change settings	: right click on %Concygsys_settings% ^> Edit
	echo Update		: launch %Concygsys_settings%
	echo More info	: %CONCYGSYS_LINK%#customization
) > README.md & move /y README.md README.txt >NUL 2>&1


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
del /f /q ConCygSys* >NUL 2>&1
exit /b 0


:fail
echo.
if "%UPDATEMODE%" == "yes" (
	echo ========================= Update FAILED ==========================
) else (
	echo ====================== Installation FAILED =======================
)
echo Please report this issue at %CONCYGSYS_LINK%/issues
echo with the copy of script output (do not forget to hide sensitive info)
echo.
pause
exit /b 1
