@echo off
::
:: Cygwin and ConEmu portable installer: https://github.com/zhubanRuban/ConCygSys
:: This is the independent fork of https://github.com/vegardit/cygwin-portable-installer project
::
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
::
::      http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.

set CONCYGSYS_VERSION=171108


:: You can customize the following variables to your needs before running the batch file

::####################### begin SCRIPT SETTINGS #######################::
:: choose a user name under Cygwin, leave empty to use your Windows username
set CYGWIN_USERNAME=

:: home folder name e.g. /home/HOME_FOLDER, leave empty to use default one - concygsys
set HOME_FOLDER=

:: override processor architecture: setup-x86.exe for 32bit and setup-x86_64.exe for 64bit system, leave empty for autodetect
set CYGWIN_SETUP=

:: change the URL to the closest mirror https://cygwin.com/mirrors.html
set CYGWIN_MIRROR=http://ftp.inf.tu-dresden.de/software/windows/cygwin32

:: select the packages to be installed automatically: https://cygwin.com/packages/package_list.html
set CYGWIN_PACKAGES=bind-utils,curl,inetutils,openssh,openssl,vim,whois

:: select command line language: https://docs.oracle.com/cd/E23824_01/html/E26033/glset.html
set LOCALE=en_US.UTF-8

:: CygWin uses ACLs to implement real Unix permissions (000, 777 etc.) which are not supported by Windows: https://cygwin.com/cygwin-ug-net/using-filemodes.html
:: However, if you move installation to different directory or PC, ACLs will be broken and will have troubles running CygWin binaries.
:: Set to **yes** if you want real Unix permissions to the detriment of portability
:: Set to **no** if you want fully portable environment.
:: Minimal permissions you will be able to set with disabled ACLs: "-r--r--r--" or "444"
:: Maximal: "-rw-r--r--" or "644". Files with exe extension or beginning with shebang (#!) will automatically have 755 permissions
set INSTALL_ACL=no

:: if set to 'yes' the apt-cyg command line package manager (https://github.com/kou1okada/apt-cyg) will be installed
set INSTALL_APT_CYG=yes

:: if set to 'yes' the bash-funk adaptive Bash prompt (https://github.com/vegardit/bash-funk) will be installed
set INSTALL_BASH_FUNK=yes

:: install parallel ssh tool https://github.com/zhubanRuban/cygwin-extras#pssh-parallelssh
set INSTALL_PSSH=yes

:: install parallel scp tool https://github.com/zhubanRuban/cygwin-extras#pscp-parallelscp
set INSTALL_PSCP=yes

:: install SSH agent tweak https://github.com/zhubanRuban/cygwin-extras#ssh-agent-tweak
set INSTALL_SSH_AGENT_TWEAK=yes

:: install custom bashrc rules for better experience https://github.com/zhubanRuban/cygwin-extras#custom-bashrc
:: if set to 'yes', will disable bash-funk adaptive Bash prompt (see INSTALL_BASH_FUNK) to prevent conflicts
set INSTALL_BASHRC_CUSTOMS=yes

:: install multitab terminal https://conemu.github.io/
set INSTALL_CONEMU=yes
:: https://conemu.github.io/en/ConEmuArgs.html
set CONEMU_OPTIONS=-Title ConCygSys

:: paths where to look for binaries, add more path if required, but at the cost of runtime performance
set CYGWIN_PATH=%%SystemRoot%%\system32;%%SystemRoot%%;%%CYGWIN_ROOT%%\bin;%%CYGWIN_ROOT%%\usr\sbin;%%CYGWIN_ROOT%%\usr\local\sbin

:: set proxy if required (unfortunately Cygwin setup.exe does not have commandline options to specify proxy user credentials)
set PROXY_HOST=
set PROXY_PORT=8080

:: set Mintty options used in ConEmu task, see https://cdn.rawgit.com/mintty/mintty/master/docs/mintty.1.html#CONFIGURATION
:: the main goal is to set options (they will overwrite whatyou configured in main MinTTY window) to make MinTTY working properly with ConEmu
set MINTTY_OPTIONS=--nopin ^
--Border frame ^
-o BellType=5 ^
-o FontHeight=10 ^
-o AllowBlinking=yes ^
-o CopyOnSelect=yes ^
-o RightClickAction=paste ^
-o ScrollbackLines=5000 ^
-o Transparency=off ^
-o ConfirmExit=no
::####################### end SCRIPT SETTINGS #######################::


echo CONCYGSYS installer version %CONCYGSYS_VERSION%

echo.
echo ###########################################################
echo # Installing [Cygwin Portable]...
echo ###########################################################
echo.

:: %~dp0 means current directory with backslash at the end
set INSTALL_ROOT=%~dp0

set CYGWIN_ROOT=%INSTALL_ROOT%cygwin
set Start_cygwin_settings=%CYGWIN_ROOT%\cygwin-settings.cmd
set Start_cygwin_install_options=%CYGWIN_ROOT%\cygwin-install-options.cmd

if not exist "%CYGWIN_ROOT%" (
	echo Creating cygwin folder [%CYGWIN_ROOT%]...
	md "%CYGWIN_ROOT%"
) else (
	echo Existing CygWin folder detected [%CYGWIN_ROOT%], entering update mode...
	wmic process get ExecutablePath 2>NUL | find /I "%CYGWIN_ROOT%">NUL
	:: rem is used below instead of :: for commenting as cycles produce "system cannot find disk" when using :: in miltiple lines
	rem for those wondering why I didn't use if "%ERRORLEVEL%"=="0"
	rem https://social.technet.microsoft.com/Forums/en-US/e72cb532-3da0-4c7f-a61e-9ffbf8050b55/batch-errorlevel-always-reports-back-level-0?forum=ITCG
	if not ErrorLevel 1 (
		echo.
		echo !!! Active CygWin processes detected, please close them and re-run update:
		wmic process get ExecutablePath | find /I "%CYGWIN_ROOT%"
		goto :fail
	) else (
		if exist "%Start_cygwin_settings%" (
			call "%Start_cygwin_settings%"
		) else (
			set UPDATEFROMOLD=yes
		)
		if exist "%Start_cygwin_install_options%" (
			call "%Start_cygwin_install_options%"
		) else (
			set UPDATEFROMOLD=yes
		)
	)
)

:: There is no true-commandline download tool in Windows
:: creating VB script that can download files...
:: not using PowerShell which may be blocked by group policies
set DOWNLOADER=%INSTALL_ROOT%downloader.vbs
echo Creating [%DOWNLOADER%] script that can download files...
if "%PROXY_HOST%" == "" (
	set DOWNLOADER_PROXY=.
) else (
	set DOWNLOADER_PROXY= req.SetProxy 2, "%PROXY_HOST%:%PROXY_PORT%", ""
)
(
	echo url = Wscript.Arguments(0^)
	echo target = Wscript.Arguments(1^)
	echo WScript.Echo "Downloading '" ^& url ^& "' to '" ^& target ^& "'..."
	echo Set req = CreateObject("WinHttp.WinHttpRequest.5.1"^)
	echo%DOWNLOADER_PROXY%
	echo req.Open "GET", url, False
	echo req.Send
	echo If req.Status ^<^> 200 Then
	echo    WScript.Echo "FAILED to download: HTTP Status " ^& req.Status
	echo    WScript.Quit 1
	echo End If
	echo Set buff = CreateObject("ADODB.Stream"^)
	echo buff.Open
	echo buff.Type = 1
	echo buff.Write req.ResponseBody
	echo buff.Position = 0
	echo buff.SaveToFile target
	echo buff.Close
	echo.
) >"%DOWNLOADER%" || goto :fail

echo Choosing correct version of cygwin installer depending on system...
if "%CYGWIN_SETUP%" == "" (
echo CYGWIN_SETUP setting is empty, autodetecting...
	if "%PROCESSOR_ARCHITEW6432%" == "AMD64" (
		set CYGWIN_SETUP=setup-x86_64.exe
	) else (
		if "%PROCESSOR_ARCHITECTURE%" == "x86" (
			set CYGWIN_SETUP=setup-x86.exe
		) else (
			set CYGWIN_SETUP=setup-x86_64.exe
		)
	)
)
echo Chosen installer: %CYGWIN_SETUP%

if exist "%CYGWIN_ROOT%\%CYGWIN_SETUP%" (
	echo Removing existing setup.exe
	del "%CYGWIN_ROOT%\%CYGWIN_SETUP%" || goto :fail
)

:: downloading cygwin installer
cscript //Nologo "%DOWNLOADER%" http://cygwin.org/%CYGWIN_SETUP% "%CYGWIN_ROOT%\%CYGWIN_SETUP%" || goto :fail

:: Cygwin command line options: https://cygwin.com/faq/faq.html#faq.setup.cli
if "%PROXY_HOST%" == "" (
	set CYGWIN_PROXY=
) else (
	set CYGWIN_PROXY=--proxy "%PROXY_HOST%:%PROXY_PORT%"
)

:: add required packages if conemu install is selected (we need to be able to extract 7z archives)
if "%INSTALL_CONEMU%" == "yes" (
	set CYGWIN_PACKAGES=bsdtar,wget,%CYGWIN_PACKAGES%
)

:: add required packages if apt-cyg install is selected: https://github.com/kou1okada/apt-cyg#requirements
if "%INSTALL_APT_CYG%" == "yes" (
	set CYGWIN_PACKAGES=wget,ca-certificates,gnupg,%CYGWIN_PACKAGES%
)

:: disable INSTALL_BASH_FUNK if INSTALL_BASHRC_CUSTOMS is set to "yes", to prevent conflicts
if "%INSTALL_BASHRC_CUSTOMS%" == "yes" (
	set INSTALL_BASH_FUNK=no
)

:: if bash-funk install is selected, install required software
if "%INSTALL_BASH_FUNK%" == "yes" (
	set CYGWIN_PACKAGES=git,git-svn,subversion,%CYGWIN_PACKAGES%
)

:: if pssh install is selected, install required software
if "%INSTALL_PSSH%" == "yes" (
	set CYGWIN_PACKAGES=wget,%CYGWIN_PACKAGES%
)

:: if pscp install is selected, install required software
if "%INSTALL_PSCP%" == "yes" (
	set CYGWIN_PACKAGES=wget,%CYGWIN_PACKAGES%
)

:: all cygwin installer commandline options: https://www.cygwin.com/faq/faq.html#faq.setup.cli
echo Running Cygwin setup...
"%CYGWIN_ROOT%\%CYGWIN_SETUP%" --no-admin ^
--site %CYGWIN_MIRROR% %CYGWIN_PROXY% ^
--root "%CYGWIN_ROOT%" ^
--local-package-dir "%CYGWIN_ROOT%\pkg-cache" ^
--no-shortcuts ^
--no-desktop ^
--delete-orphans ^
--upgrade-also ^
--no-replaceonreboot ^
--quiet-mode ^
--packages dos2unix,wget,%CYGWIN_PACKAGES% || goto :fail

:: deleting standard CygWin launcher
set Cygwin_bat=%CYGWIN_ROOT%\Cygwin.bat
if exist "%Cygwin_bat%" (
	del "%Cygwin_bat%"
)

:: deleting CygWin updater if left by previous ConCygSys versions
if exist "%CYGWIN_ROOT%\updater.cmd" (
	del "%CYGWIN_ROOT%\updater.cmd"
)

set Init_sh=%CYGWIN_ROOT%\portable-init.sh
echo Creating [%Init_sh%] script to keep the installation portable...
(
	echo #!/usr/bin/env bash
	echo # https://github.com/zhubanRuban/ConCygSys
	echo # ConCygSys version %CONCYGSYS_VERSION%
	echo.
	echo # Setting custom CygWin username
	echo (
	echo mkpasswd -c^|awk -F: -v OFS=: "{\$1=\"$USERNAME\"; \$6=\"$HOME\"; print}"
	echo ^) ^>/etc/passwd
	echo.
	echo (
	if not "%INSTALL_ACL%" == "yes" (
		echo echo $(cygpath -m "$CYGWIN_ROOT"^|sed 's/\ /\\040/g'^)/bin /usr/bin none binary,auto,noacl 0 0
		echo echo $(cygpath -m "$CYGWIN_ROOT"^|sed 's/\ /\\040/g'^)/lib /usr/lib none binary,auto,noacl 0 0
		echo echo $(cygpath -m "$CYGWIN_ROOT"^|sed 's/\ /\\040/g'^) / none override,binary,auto,noacl 0 0
	)
	echo echo none /mnt cygdrive binary,noacl,posix=0,user 0 0
	echo ^) ^>/etc/fstab
	echo.
	echo # adjust Cygwin packages cache path
	echo pkg_cache_dir=$(cygpath -w "$CYGWIN_ROOT/pkg-cache"^)
	echo sed -i '/^^last-cache/!b;n;c\\t'"${pkg_cache_dir//\\/\\\\}"'' /etc/setup/setup.rc
) >"%Init_sh%" || goto :fail
	
set Install_sh=%CYGWIN_ROOT%\portable-install.sh
echo Creating [%Install_sh%] script to install required software...
(
	echo #!/usr/bin/env bash
	echo.
	if not "%PROXY_HOST%" == "" (
		echo if [[ $HOSTNAME == "%COMPUTERNAME%" ]]; then
		echo 	export http_proxy=http://%PROXY_HOST%:%PROXY_PORT%
		echo 	export https_proxy=$http_proxy
		echo fi
	)
	if "%INSTALL_CONEMU%" == "yes" (
		echo conemu_dir=$(cygpath -w "$CYGWIN_ROOT/../conemu"^)
		echo if [[ ! -e $conemu_dir ]]; then
		echo 	echo "Installing ConEmu..."
		echo 	conemu_url="https://github.com$(wget https://github.com/Maximus5/ConEmu/releases/latest -O - 2>/dev/null | egrep '/.*/releases/download/.*/.*7z' -o)"
		echo 	echo "Download URL=$conemu_url"
		echo 	wget -nv --show-progress -O "${conemu_dir}.7z" $conemu_url
		echo 	mkdir "$conemu_dir"
		echo 	bsdtar -xvf "${conemu_dir}.7z" -C "$conemu_dir"
		echo 	rm "${conemu_dir}.7z"
		echo fi
		echo echo https://github.com/zhubanRuban/ConCygSys ConCygSys version %CONCYGSYS_VERSION% ^> "$CYGWIN_ROOT/../conemu/DO-NOT-LAUNCH-CONEMU-FROM-HERE"
	) else (
		echo rm -rf $(cygpath -w "$CYGWIN_ROOT/../conemu"^)
	)
	if "%INSTALL_APT_CYG%" == "yes" (
		echo echo "Installing/updating apt-cyg..."
		echo wget -nv --show-progress -O /usr/local/bin/apt-cyg https://raw.githubusercontent.com/kou1okada/apt-cyg/master/apt-cyg
		echo chmod +x /usr/local/bin/apt-cyg
	) else (
		echo rm -f /usr/local/bin/apt-cyg
	)
	if "%INSTALL_PSSH%" == "yes" (
		echo echo "Installing/updating parallel ssh tool..."
		echo wget -nv --show-progress -O /usr/local/bin/pssh https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/pssh
		echo chmod +x /usr/local/bin/pssh
	) else (
		echo rm -f /usr/local/bin/pssh
	)
	if "%INSTALL_PSCP%" == "yes" (
		echo echo "Installing parallel scp tool..."
		echo wget -nv --show-progress -O /usr/local/bin/pscp https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/pscp
		echo chmod +x /usr/local/bin/pscp
	) else (
		echo rm -f /usr/local/bin/pscp
	)
	if "%INSTALL_BASH_FUNK%" == "yes" (
		echo if [[ ! -e /opt ]]; then mkdir /opt; fi
		echo if [[ ! -e /opt/bash-funk/bash-funk.sh ]]; then
		echo 	echo Installing [bash-funk]...
		echo 	if hash git ^&^>/dev/null; then
		echo 		git clone https://github.com/vegardit/bash-funk --branch master --single-branch /opt/bash-funk
		echo 		elif hash svn ^&^>/dev/null; then
		echo 			svn checkout https://github.com/vegardit/bash-funk/trunk /opt/bash-funk
		echo 	else
		echo 		mkdir /opt/bash-funk ^&^& \
		echo 		cd /opt/bash-funk ^&^& \
		echo 		wget -qO- --show-progress https://github.com/vegardit/bash-funk/tarball/master ^| tar -xzv --strip-components 1
		echo 	fi
		echo fi
	) else (
		echo rm -rf /opt/bash-funk
	)
) >"%Install_sh%" || goto :fail

:: converting scripts to unix format as they were created via cmd
"%CYGWIN_ROOT%\bin\dos2unix" "%Init_sh%" || goto :fail
"%CYGWIN_ROOT%\bin\dos2unix" "%Install_sh%" || goto :fail


echo Generating launcher files...

echo Generating [%Start_cygwin_install_options%]...
(
	echo :: https://github.com/zhubanRuban/ConCygSys#customization
	echo :: ConCygSys version %CONCYGSYS_VERSION%
	echo set CYGWIN_SETUP=%CYGWIN_SETUP%
	echo set CYGWIN_MIRROR=%CYGWIN_MIRROR%
	echo :: fill only if new packages should be installed during next update
	echo set CYGWIN_PACKAGES=
	echo set INSTALL_ACL=%INSTALL_ACL%
	echo set INSTALL_APT_CYG=%INSTALL_APT_CYG%
	echo set INSTALL_BASH_FUNK=%INSTALL_BASH_FUNK%
	echo set INSTALL_PSSH=%INSTALL_PSSH%
	echo set INSTALL_PSCP=%INSTALL_PSCP%
	echo set INSTALL_SSH_AGENT_TWEAK=%INSTALL_SSH_AGENT_TWEAK%
	echo set INSTALL_BASHRC_CUSTOMS=%INSTALL_BASHRC_CUSTOMS%
	echo set INSTALL_CONEMU=%INSTALL_CONEMU%
	echo set PROXY_HOST=%PROXY_HOST%
	echo set PROXY_PORT=%PROXY_PORT%
) >"%Start_cygwin_install_options%" || goto :fail

echo Generating [%Start_cygwin_settings%]...
(
	echo :: https://github.com/zhubanRuban/ConCygSys#customization
	echo :: ConCygSys version %CONCYGSYS_VERSION%
	echo set CYGWIN_USERNAME=%CYGWIN_USERNAME%
	echo set HOME_FOLDER=%HOME_FOLDER%
	echo set LOCALE=%LOCALE%
) >"%Start_cygwin_settings%" || goto :fail

:: generating launcher header
set Start_cmd_begin=%INSTALL_ROOT%Begin
(
	echo @echo off
	echo :: https://github.com/zhubanRuban/ConCygSys
	echo :: ConCygSys version %CONCYGSYS_VERSION%
	echo.
	echo set CYGWIN_DRIVE=%%~d0
	echo set CYGWIN_ROOT=%%~dp0cygwin
	echo.
	echo call "%%CYGWIN_ROOT%%\cygwin-settings.cmd"
	echo.
	echo set PATH=%CYGWIN_PATH%
	echo set ALLUSERSPROFILE=%%CYGWIN_ROOT%%\ProgramData
	echo set ProgramData=%%ALLUSERSPROFILE%%
	echo.
	echo if not "%%CYGWIN_USERNAME%%" == "" (
	echo 	set USERNAME=%%CYGWIN_USERNAME%%
	echo ^)
	echo if "%%HOME_FOLDER%%" == "" (
	echo 	set HOME_FOLDER=concygsys
	echo ^)
	echo set HOME=/home/%%HOME_FOLDER%%
	echo set HOMEPATH=%%CYGWIN_ROOT%%\home\%%HOME_FOLDER%%
	echo set HOMEDRIVE=%%CYGWIN_DRIVE%%
	echo.
	echo %%CYGWIN_DRIVE%%
	echo rd /s /q "%%CYGWIN_ROOT%%\pkg-cache" 2^>NUL
	echo type NUL ^>"%%CYGWIN_ROOT%%\etc\fstab"
	echo chdir "%%CYGWIN_ROOT%%\bin"
	echo bash "%%CYGWIN_ROOT%%\portable-init.sh"
	echo.
) >"%Start_cmd_begin%" || goto :fail

set Start_cmd=%INSTALL_ROOT%CygWin-ConEmu.cmd
if "%INSTALL_CONEMU%" == "yes" (
	echo Generating ConEmu launcher [%Start_cmd%]...
	(
		type "%Start_cmd_begin%"
		echo if "%%PROCESSOR_ARCHITEW6432%%" == "AMD64" (
		echo 	start "" "%%~dp0conemu\ConEmu64.exe" %CONEMU_OPTIONS%
		echo ^) else (
		echo 	if "%%PROCESSOR_ARCHITECTURE%%" == "x86" (
		echo 		start "" "%%~dp0conemu\ConEmu.exe" %CONEMU_OPTIONS%
		echo 	^) else (
		echo 		start "" "%%~dp0conemu\ConEmu64.exe" %CONEMU_OPTIONS%
		echo 	^)
		echo ^)
	) >"%Start_cmd%" || goto :fail
)

set Start_cmd_cmd=%INSTALL_ROOT%CygWin-Cmd.cmd
echo Generating cmd launcher [%Start_cmd_cmd%]...
(
	type "%Start_cmd_begin%"
	echo if "%%1" == "" (
	echo 	bash --login -i
	echo ^) else (
	echo 	bash --login -c %%*
	echo ^)
) >"%Start_cmd_cmd%" || goto :fail

set Start_cmd_mintty=%INSTALL_ROOT%CygWin-MinTTY.cmd
echo Generating MinTTy launcher [%Start_cmd_mintty%]...
(
	type "%Start_cmd_begin%"
	echo mintty --Title ConCygSys -
) >"%Start_cmd_mintty%" || goto :fail

:: generating install launcher
set Start_cmd_install=%INSTALL_ROOT%ConCygSys_install.cmd
(
	echo set CWD=%%cd%%
	type "%Start_cmd_begin%"
	echo bash "%%CYGWIN_ROOT%%\portable-install.sh"
	echo if "%%1" == "" (
	echo 	bash --login -i
	echo ^) else (
	echo 	bash --login -c %%*
	echo ^)
	echo.
	echo cd "%%CWD%%"
) >"%Start_cmd_install%" || goto :fail

echo Launching bash once to initialize user home dir...
call "%Start_cmd_install%" whoami
:: deleting temp files
del "%Install_sh%"
del "%Start_cmd_install%"


set conemu_config=%INSTALL_ROOT%conemu\ConEmu.xml
if "%INSTALL_CONEMU%" == "yes" (
	echo Replacing ConEmu config...
	(
		echo ^<?xml version="1.0" encoding="utf-8"?^>
		echo ^<!--
		echo Custom ConEmu config specially for CygWin+ConEmu portable build:
		echo https://github.com/zhubanRuban/ConCygSys
		echo ConCygSys version %CONCYGSYS_VERSION%
		echo --^>
		echo ^<key name="Software"^>
		echo 	^<key name="ConEmu"^>
		echo 		^<key name=".Vanilla"^>
		echo 			^<value name="StartTasksName" type="string" data="{CygWin::MinTTY}"/^>
		echo 			^<value name="WindowMode" type="dword" data="00000520"/^>
		echo 			^<value name="ShowScrollbar" type="hex" data="01"/^>
		echo 			^<value name="QuakeStyle" type="hex" data="01"/^>
		echo 			^<value name="QuakeAnimation" type="ulong" data="50"/^>
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
		echo 				^<value name="Multi.NewSplitV" type="dword" data="00a05b4f"/^>
		echo 				^<value name="Multi.NewSplitH" type="dword" data="00a05b45"/^>
		echo 			^</key^>
		echo 			^<key name="Tasks"^>
		echo 				^<value name="Count" type="long" data="4"/^>
		echo 				^<key name="Task1"^>
		echo 					^<value name="Name" type="string" data="{CygWin::Connector}"/^>
		echo 					^<value name="Flags" type="dword" data="00000004"/^>
		echo 					^<value name="Hotkey" type="dword" data="00005b54"/^>
		echo 					^<value name="GuiArgs" type="string" data=""/^>
		rem Removed path to icon to get more space for tabs
		rem Terminal changed to cygwin instead of xterm-256color to prevent issues in screen session over SSH
		if "%CYGWIN_SETUP%" == "setup-x86_64.exe" (
			echo 					^<value name="Cmd1" type="string" data="&quot;%%ConEmuBaseDirShort%%\conemu-cyg-64.exe&quot; -t cygwin -new_console:p1 -new_console:P:&quot;&lt;xterm&gt;&quot; -new_console:h5000"/^>
		)
		if "%CYGWIN_SETUP%" == "setup-x86.exe" (
			echo 					^<value name="Cmd1" type="string" data="&quot;%%ConEmuBaseDirShort%%\conemu-cyg-32.exe&quot; -t cygwin -new_console:p1 -new_console:P:&quot;&lt;xterm&gt;&quot; -new_console:h5000"/^>
		)
		echo 					^<value name="Active" type="long" data="0"/^>
		echo 					^<value name="Count" type="long" data="1"/^>
		echo 				^</key^>
		echo 				^<key name="Task2"^>
		echo 					^<value name="Name" type="string" data="{CygWin::Cmd}"/^>
		echo 					^<value name="Flags" type="dword" data="00000004"/^>
		echo 					^<value name="Hotkey" type="dword" data="00005b42"/^>
		echo 					^<value name="GuiArgs" type="string" data=""/^>
		echo 					^<value name="Cmd1" type="string" data="&quot;%%ConEmuDir%%\..\cygwin\bin\bash.exe&quot; --login -i -new_console:p1 -new_console:P:&quot;&lt;xterm&gt;&quot; -new_console:h5000"/^>
		echo 					^<value name="Active" type="long" data="0"/^>
		echo 					^<value name="Count" type="long" data="1"/^>
		echo 				^</key^>
		echo 				^<key name="Task3"^>
		echo 					^<value name="Name" type="string" data="{CygWin::MinTTY}"/^>
		echo 					^<value name="Flags" type="dword" data="00000005"/^>
		echo 					^<value name="Hotkey" type="dword" data="00005b4d"/^>
		echo 					^<value name="GuiArgs" type="string" data="/icon &quot; &quot;"/^>
		echo 					^<value name="Cmd1" type="string" data="&quot;%%ConEmuDir%%\..\cygwin\bin\mintty.exe&quot; %MINTTY_OPTIONS% - -new_console:P:&quot;&lt;xterm&gt;&quot;"/^>
		echo 					^<value name="Active" type="long" data="0"/^>
		echo 					^<value name="Count" type="long" data="1"/^>
		echo 				^</key^>
		echo 				^<key name="Task4"^>
		echo 					^<value name="Name" type="string" data="{WSL}"/^>
		echo 					^<value name="Flags" type="dword" data="00000004"/^>
		echo 					^<value name="Hotkey" type="dword" data="00005b55"/^>
		echo 					^<value name="GuiArgs" type="string" data="-icon &quot;%%USERPROFILE%%\AppData\Local\lxss\bash.ico&quot;"/^>
		echo 					^<value name="Cmd1" type="string" data="set &quot;PATH=%%ConEmuBaseDirShort%%\wsl;%%PATH%%&quot; &amp; &quot;%%ConEmuBaseDirShort%%\wsl\wslbridge.exe&quot; -cur_console:pm:/mnt"/^>
		echo 					^<value name="Active" type="long" data="0"/^>
		echo 					^<value name="Count" type="long" data="1"/^>
		echo 				^</key^>
		echo 			^</key^>
		echo 		^</key^>
		echo 	^</key^>
		echo ^</key^>
	)> "%conemu_config%" || goto :fail
)


set PostInstall_sh=%CYGWIN_ROOT%\post-install.sh
(
	echo echo #!/usr/bin/env bash
	echo mkdir -p /opt
	:: delete messy bashrc if updating from earliest ConCygSys versions
	if "%UPDATEFROMOLD%" == "yes" (
		echo cat /etc/skel/.bashrc ^> ${HOME}/.bashrc
	)
	:: inserting proxy settings to .bashrc
	if not "%PROXY_HOST%" == "" (
		echo echo Adding proxy settings for host [%COMPUTERNAME%] to [${HOME}/.bashrc]...
		echo (
		echo echo if [[ $HOSTNAME == "%COMPUTERNAME%" ]]; then
		echo echo	export http_proxy=http://%PROXY_HOST%:%PROXY_PORT%
		echo echo	export https_proxy=$http_proxy
		echo echo	export no_proxy="::1,127.0.0.1,localhost,169.254.169.254,%COMPUTERNAME%,*.%USERDNSDOMAIN%"
		echo echo	export HTTP_PROXY=$http_proxy
		echo echo	export HTTPS_PROXY=$http_proxy
		echo echo	export NO_PROXY=$no_proxy
		echo echo fi
		echo ^) ^> /opt/bash_proxy
		echo if grep -q '/opt/bash_proxy' "${HOME}/.bashrc"; then
		echo 	sed -i '/bash_proxy/c\if [ -f "/opt/bash_proxy" ]; then source "/opt/bash_proxy"; fi' "${HOME}/.bashrc"
		echo else
		echo 	echo 'if [ -f "/opt/bash_proxy" ]; then source "/opt/bash_proxy"; fi' ^>^> "${HOME}/.bashrc"
		echo fi
	) else (
		echo rm -f /opt/bash_proxy
		echo sed -i '/bash_proxy/d' "${HOME}/.bashrc"
	)
	:: inserting soursing bash-funk in .bashrc if one is selected to install
	if "%INSTALL_BASH_FUNK%" == "yes" (
		echo echo Adding bash-funk to [${HOME}/.bashrc]...
		echo if grep -q '/opt/bash-funk/bash-funk.sh' "${HOME}/.bashrc"; then
		echo 	sed -i '/bash-funk.sh/c\if [ -f "/opt/bash-funk/bash-funk.sh" ]; then source "/opt/bash-funk/bash-funk.sh"; fi' "${HOME}/.bashrc"
		echo else
		echo 	echo 'if [ -f "/opt/bash-funk/bash-funk.sh" ]; then source "/opt/bash-funk/bash-funk.sh"; fi' ^>^> "${HOME}/.bashrc"
		echo fi
	) else (
		echo sed -i '/bash-funk.sh/d' "${HOME}/.bashrc"
	)
	:: inserting custom .bashrc settings
	if "%INSTALL_BASHRC_CUSTOMS%" == "yes" (
		echo echo Adding .bashrc customizations to [${HOME}/.bashrc] and [${HOME}/.inputrc]...
		echo wget -nv --show-progress -O /opt/bashrc_custom https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/bashrc_custom
		echo if grep -q '/opt/bashrc_custom' "${HOME}/.bashrc"; then
		echo 	sed -i '/bashrc_custom/c\if [ -f "/opt/bashrc_custom" ]; then source "/opt/bashrc_custom"; fi' "${HOME}/.bashrc"
		echo else
		echo 	echo 'if [ -f "/opt/bashrc_custom" ]; then source "/opt/bashrc_custom"; fi' ^>^> "${HOME}/.bashrc"
		echo fi
		echo cat /etc/skel/.inputrc ^> "${HOME}/.inputrc"
		echo wget -nv --show-progress https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/inputrc_custom -O- ^>^> "${HOME}/.inputrc"
	) else (
		echo rm -f /opt/bashrc_custom
		echo sed -i '/bashrc_custom/d' "${HOME}/.bashrc"
		echo cat /etc/skel/.inputrc ^> "${HOME}/.inputrc"
	)
	:: inserting ssh-agent settings
	set ssh_agent_config=%INSTALL_ROOT%ssh_agent_config
	if "%INSTALL_SSH_AGENT_TWEAK%" == "yes" (
		echo echo Adding SSH agent tweak to [${HOME}/.bashrc]...
		echo wget -nv --show-progress -O /opt/ssh-agent-tweak https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/ssh-agent-tweak
		echo if grep -q '/opt/ssh-agent-tweak' "${HOME}/.bashrc"; then
		echo 	sed -i '/ssh-agent-tweak/c\if [ -f "/opt/ssh-agent-tweak" ]; then source "/opt/ssh-agent-tweak"; fi' "${HOME}/.bashrc"
		echo else
		echo 	echo 'if [ -f "/opt/ssh-agent-tweak" ]; then source "/opt/ssh-agent-tweak"; fi' ^>^> "${HOME}/.bashrc"
		echo fi
	) else (
		echo rm -f /opt/ssh-agent-tweak
		echo sed -i '/ssh-agent-tweak/d' "${HOME}/.bashrc"
	)
) > "%PostInstall_sh%" || goto :fail

:: converting postinstall script to unix format
"%CYGWIN_ROOT%\bin\dos2unix" "%PostInstall_sh%" || goto :fail

:: generating post install launcher
set Start_cmd_postinstall=%INSTALL_ROOT%ConCygSys_postinstall.cmd
(
	echo set CWD=%%cd%%
	type "%Start_cmd_begin%"
	echo bash "%%CYGWIN_ROOT%%\post-install.sh"
	echo cd "%%CWD%%"
) >"%Start_cmd_postinstall%" || goto :fail

echo Launching post install script...
call "%Start_cmd_postinstall%"

:: deleting temp files
del "%Start_cmd_begin%"
del "%Start_cmd_postinstall%"
del "%PostInstall_sh%"


:: cleaning up
:: deleting data folder if left from previous ConCygSys versions
rd /s /q "%INSTALL_ROOT%data" >NUL 2>&1
:: delting readme and licence files
del "%INSTALL_ROOT%LICENSE" >NUL 2>&1
del "%INSTALL_ROOT%README.md" >NUL 2>&1
:: deleting VB script that can download files
del "%DOWNLOADER%"

echo.
echo ###########################################################
echo # Installation succeeded.
echo ###########################################################
echo.
echo Use launchers in [%INSTALL_ROOT%] to run CygWin Portable.
echo.
pause
:: deleting installer and old launchers
del "%INSTALL_ROOT%ConCygSys*" >NUL 2>&1
goto :eof

:fail
	echo.
	echo ###########################################################
	echo #Installation FAILED!
	echo ###########################################################
	echo.
	pause
	exit /b 1
