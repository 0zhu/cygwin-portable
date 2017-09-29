@echo off
::
:: This is the independent fork of https://github.com/vegardit/cygwin-portable-installer project
:: Specially for sysadmins purposes
:: @modified by zhubanRuban https://github.com/zhubanRuban
:: Forked project page https://github.com/zhubanRuban/ConCygSys
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

:: You can customize the following variables to your needs before running the batch file:


::####################### begin SCRIPT SETTINGS #######################::
:: choose a user name under Cygwin, leave empty to use your Windows username
set CYGWIN_USERNAME=

:: override processor architecture: setup-x86.exe for 32bit and setup-x86_64.exe for 64bit system, leave empty for autodetect
set CYGWIN_SETUP=

:: change the URL to the closest mirror https://cygwin.com/mirrors.html
set CYGWIN_MIRROR=http://ftp.inf.tu-dresden.de/software/windows/cygwin32

:: select the packages to be installed automatically: https://cygwin.com/packages/package_list.html
set CYGWIN_PACKAGES=bind-utils,curl,inetutils,openssh,openssl,whois

:: select command line language: https://docs.oracle.com/cd/E23824_01/html/E26033/glset.html
set LOCALE=en_US.UTF-8

:: if set to 'yes' the apt-cyg command line package manager (https://github.com/transcode-open/apt-cyg) will be installed automatically
set INSTALL_APT_CYG=yes

:: if set to 'yes' the bash-funk adaptive Bash prompt (https://github.com/vegardit/bash-funk) will be installed automatically
set INSTALL_BASH_FUNK=yes

:: install parallel ssh tool https://github.com/zhubanRuban/cygwin-extras
set INSTALL_PSSH=yes

:: install parallel scp tool https://github.com/zhubanRuban/cygwin-extras
set INSTALL_PSCP=yes

:: https://github.com/zhubanRuban/cygwin-extras
:: by default, CygWin asks for SSH key password on every SSH login
:: using an amazing workaround found at https://www.electricmonk.nl/log/2012/04/24/re-use-existing-ssh-agent-cygwin-et-al/ that is not a problem anymore
:: modified a bit for this build
:: if set to 'yes', re-use existing SSH agent
set INSTALL_SSH_AGENT_TWEAK=yes

:: https://github.com/zhubanRuban/cygwin-extras
:: install .bashrc customizations for convenience and speed
:: if set to 'yes', will disable bash-funk adaptive Bash prompt (see INSTALL_BASH_FUNK) to prevent conflicts
set INSTALL_BASHRC_CUSTOMS=yes

:: use ConEmu based tabbed terminal instead of Mintty based single window terminal, see https://conemu.github.io/
set INSTALL_CONEMU=yes
set CON_EMU_OPTIONS=-Title ConCygSys

:: add more path if required, but at the cost of runtime performance (e.g. slower forks)
set CYGWIN_PATH=%%SystemRoot%%\system32;%%SystemRoot%%

:: set proxy if required (unfortunately Cygwin setup.exe does not have commandline options to specify proxy user credentials)
set PROXY_HOST=
set PROXY_PORT=8080

:: set Mintty options, see https://cdn.rawgit.com/mintty/mintty/master/docs/mintty.1.html#CONFIGURATION
set MINTTY_OPTIONS=--Title ConCygSys ^
-o CursorBlinks=yes ^
-o CopyOnSelect=yes ^
-o RightClickAction=Paste ^
-o FontHeight=10 ^
-o ScrollbackLines=10000 ^
-o Transparency=off ^
-o Term=xterm ^
-o Charset=UTF-8
::####################### end SCRIPT SETTINGS #######################::


echo.
echo ###########################################################
echo # Installing [Cygwin Portable]...
echo ###########################################################
echo.

:: %~dp0 means current directory
set INSTALL_ROOT=%~dp0

echo Creating cygwin folder...
set CYGWIN_ROOT=%INSTALL_ROOT%cygwin
if not exist "%CYGWIN_ROOT%" (
	md "%CYGWIN_ROOT%"
)
echo %CYGWIN_ROOT%

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
if exist "%CYGWIN_ROOT%\%CYGWIN_SETUP%" (
	del "%CYGWIN_ROOT%\%CYGWIN_SETUP%" || goto :fail
)
echo Chosen installer: %CYGWIN_SETUP%

:: downloading cygwin installer
cscript //Nologo %DOWNLOADER% http://cygwin.org/%CYGWIN_SETUP% "%CYGWIN_ROOT%\%CYGWIN_SETUP%" || goto :fail

:: Cygwin command line options: https://cygwin.com/faq/faq.html#faq.setup.cli
if "%PROXY_HOST%" == "" (
	set CYGWIN_PROXY=
) else (
	set CYGWIN_PROXY=--proxy "%PROXY_HOST%:%PROXY_PORT%"
)

:: if conemu install is selected we need to be able to extract 7z archives
if "%INSTALL_CONEMU%" == "yes" (
	set CYGWIN_PACKAGES=bsdtar,wget,%CYGWIN_PACKAGES%
)

:: if apt-cyg install is selected we need to be able to extract 7z archives
if "%INSTALL_APT_CYG%" == "yes" (
	set CYGWIN_PACKAGES=wget,%CYGWIN_PACKAGES%
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
--local-package-dir "%CYGWIN_ROOT%-pkg-cache" ^
--no-shortcuts ^
--no-desktop ^
--delete-orphans ^
--upgrade-also ^
--no-replaceonreboot ^
--quiet-mode ^
--packages dos2unix,wget,%CYGWIN_PACKAGES% || goto :fail

 
echo Disabling stock Cygwin launcher...
set Cygwin_bat=%CYGWIN_ROOT%\Cygwin.bat
if exist "%Cygwin_bat%" (
	echo Disabling [%Cygwin_bat%]...
	if exist "%Cygwin_bat%.disabled" (
		del "%Cygwin_bat%.disabled" || goto :fail
	)
	rename %Cygwin_bat% Cygwin.bat.disabled || goto :fail
)


:configure
:: disable Cygwin's - apparently broken - special ACL treatment which prevents apt-cyg and other programs from working
echo Replacing etc/fstab
rename %CYGWIN_ROOT%\etc\fstab fstab.orig || goto :fail
echo none /cygdrive cygdrive binary,noacl,posix=0,user 0 0 > %CYGWIN_ROOT%\etc\fstab

:: creating portable-init.sh script to keep the installation portable
:: also sends commands to bash to install ConEmu and other software is selected in settings
set Init_sh=%CYGWIN_ROOT%\portable-init.sh
echo Creating [%Init_sh%] script to keep the installation portable...
(
	echo #!/usr/bin/env bash
	echo.
	echo # Modifying /etc/fstab to make the installation fully portable
	echo (
	echo echo $(cygpath -m $CYGWIN_ROOT^)/bin /usr/bin none binary,noacl,override 0 0
	echo echo $(cygpath -m $CYGWIN_ROOT^)/lib /usr/lib none binary,noacl,override 0 0
	echo echo $(cygpath -m $CYGWIN_ROOT^) / none binary,noacl,override 0 0
	echo echo none /mnt cygdrive binary,noacl,posix=0,user 0 0
	echo ^) ^>/etc/fstab
	echo.
	echo # Setting custom CygWin username
	echo (
	echo mkpasswd -c^|awk -F: -v OFS=: "{\$1=\"$USERNAME\"; \$6=\"$HOME\"; print}"
	echo ^) ^>/etc/passwd
	echo.
	echo # adjust Cygwin packages cache path
	echo pkg_cache_dir=$(cygpath -w "$CYGWIN_ROOT/../cygwin-pkg-cache"^)
	echo sed -i -E "s/.*\\\cygwin-pkg-cache/        ${pkg_cache_dir//\\/\\\\}/" /etc/setup/setup.rc
	echo.
	echo # remove apt-get cache
	echo rm -rf /http*
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
		echo #
		echo # Installing conemu if required
		echo #
		echo conemu_dir=$(cygpath -w "$CYGWIN_ROOT/../conemu"^)
		echo if [[ ! -e $conemu_dir ]]; then
		echo 	echo "Installing ConEmu..."
		echo 	conemu_url="https://github.com$(wget https://github.com/Maximus5/ConEmu/releases/latest -O - 2>/dev/null | egrep '/.*/releases/download/.*/.*7z' -o)" ^&^& \
		echo 	echo "Download URL=$conemu_url" ^&^& \
		echo 	wget -O "${conemu_dir}.7z" $conemu_url ^&^& \
		echo 	mkdir $conemu_dir ^&^& \
		echo 	bsdtar -xvf "${conemu_dir}.7z" -C "$conemu_dir" ^&^& \
		echo 	rm "${conemu_dir}.7z" ^&^& \
		echo fi
	)
	if "%INSTALL_APT_CYG%" == "yes" (
		echo #
		echo # Installing apt-cyg package manager if required
		echo #
		echo if [[ ! -x /usr/local/bin/apt-cyg ]]; then
		echo 	echo "Installing apt-cyg..."
		echo 	wget -O /usr/local/bin/apt-cyg https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
		echo 	chmod +x /usr/local/bin/apt-cyg
		echo fi
		echo.
	)
	if "%INSTALL_PSSH%" == "yes" (
		echo #
		echo # Installing parallel ssh tool
		echo #
		echo if [[ ! -x /usr/local/bin/pssh ]]; then
		echo 	echo "Installing parallel ssh tool..."
		echo 	wget -O /usr/local/bin/pssh https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/pssh
		echo 	chmod +x /usr/local/bin/pssh
		echo fi
		echo.
	)
	if "%INSTALL_PSCP%" == "yes" (
		echo #
		echo # Installing parallel scp tool
		echo #
		echo if [[ ! -x /usr/local/bin/pscp ]]; then
		echo 	echo "Installing parallel scp tool..."
		echo 	wget -O /usr/local/bin/pscp https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/pscp
		echo 	chmod +x /usr/local/bin/pscp
		echo fi
		echo.
	)
	if "%INSTALL_BASH_FUNK%" == "yes" (
		echo.
		echo #
		echo # Installing bash-funk if required
		echo #
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
	)
) >"%Install_sh%" || goto :fail

echo Converting [%Init_sh%] and [%Install_sh%] scripts to unix format...
"%CYGWIN_ROOT%\bin\dos2unix" "%Init_sh%" || goto :fail
"%CYGWIN_ROOT%\bin\dos2unix" "%Install_sh%" || goto :fail


echo Generating launcher files...
:: generating launcher header
set Start_cmd_begin=%INSTALL_ROOT%Begin
(
	echo @echo off
	echo.
	echo set CWD=%%cd%%
	echo set CYGWIN_DRIVE=%%~d0
	echo set CYGWIN_ROOT=%%~dp0cygwin
	echo.
	echo set PATH=%CYGWIN_PATH%;%%CYGWIN_ROOT%%\bin;%%CYGWIN_ROOT%%\usr\local\sbin
	echo set ALLUSERSPROFILE=%%CYGWIN_ROOT%%.ProgramData
	echo set ProgramData=%%ALLUSERSPROFILE%%
	echo.
	echo set CYGWIN_USERNAME=%CYGWIN_USERNAME%
	echo.
	echo if not "%%CYGWIN_USERNAME%%" == "" (
	echo 	set USERNAME=%%CYGWIN_USERNAME%%
	echo ^)
	echo set HOME=/home/concygsys
	echo set HOMEPATH=%%CYGWIN_ROOT%%\home\concygsys
	echo set SHELL=/bin/bash
	echo set HOMEDRIVE=%%CYGWIN_DRIVE%%
	echo set LANG=%LOCALE%
	echo.
	echo chdir "%%CYGWIN_ROOT%%\bin"
	echo bash "%%CYGWIN_ROOT%%\portable-init.sh"
	echo.
) >"%Start_cmd_begin%" || goto :fail

:: generating conemu launcher
set Start_cmd=%INSTALL_ROOT%ConCygSys.cmd
if "%INSTALL_CONEMU%" == "yes" (
	(
		type "%Start_cmd_begin%"
		echo if "%%PROCESSOR_ARCHITEW6432%%" == "AMD64" (
		echo 	start %%~dp0conemu\ConEmu64.exe %CON_EMU_OPTIONS%
		echo ^) else (
		echo 	if "%%PROCESSOR_ARCHITECTURE%%" == "x86" (
		echo 		start %%~dp0conemu\ConEmu.exe %CON_EMU_OPTIONS%
		echo 	^) else (
		echo 		start %%~dp0conemu\ConEmu64.exe %CON_EMU_OPTIONS%
		echo 	^)
		echo ^)
	) >"%Start_cmd%" || goto :fail
)

:: generating cmd launcher
set Start_cmd_cmd=%INSTALL_ROOT%ConCygSys_cmd.cmd
(
	type "%Start_cmd_begin%"
	echo if "%%1" == "" (
	echo 	bash --login -i
	echo ^) else (
	echo 	bash --login -c %%*
	echo ^)
) >"%Start_cmd_cmd%" || goto :fail

:: generating mintty launcher
set Start_cmd_mintty=%INSTALL_ROOT%ConCygSys_mintty.cmd
(
	type "%Start_cmd_begin%"
	echo mintty --nopin %MINTTY_OPTIONS% --icon %CYGWIN_ROOT%\Cygwin-Terminal.ico -
) >"%Start_cmd_mintty%" || goto :fail

:: generating install launcher
set Start_cmd_install=%INSTALL_ROOT%ConCygSys_install.cmd
(
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
call %Start_cmd_install% whoami
:: deleting temp files
del "%Start_cmd_begin%"
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
		echo --^>
		echo ^<key name="Software"^>
		echo 	^<key name="ConEmu"^>
		echo 		^<key name=".Vanilla"^>
		echo 			^<value name="StartTasksName" type="string" data="{Bash::CygWin bash}"/^>
		echo 			^<value name="ColorTable00" type="dword" data="00000000"/^>
		echo			^<value name="ColorTable01" type="dword" data="00ee0000"/^>
		echo 			^<value name="ColorTable02" type="dword" data="0000cd00"/^>
		echo 			^<value name="ColorTable03" type="dword" data="00cdcd00"/^>
		echo 			^<value name="ColorTable04" type="dword" data="000000cd"/^>
		echo 			^<value name="ColorTable05" type="dword" data="00cd00cd"/^>
		echo 			^<value name="ColorTable06" type="dword" data="0000cdcd"/^>
		echo 			^<value name="ColorTable07" type="dword" data="00e5e5e5"/^>
		echo 			^<value name="ColorTable08" type="dword" data="007f7f7f"/^>
		echo 			^<value name="ColorTable09" type="dword" data="00ff5c5c"/^>
		echo 			^<value name="ColorTable10" type="dword" data="0000ff00"/^>
		echo 			^<value name="ColorTable11" type="dword" data="00ffff00"/^>
		echo 			^<value name="ColorTable12" type="dword" data="000000ff"/^>
		echo 			^<value name="ColorTable13" type="dword" data="00ff00ff"/^>
		echo 			^<value name="ColorTable14" type="dword" data="0000ffff"/^>
		echo 			^<value name="ColorTable15" type="dword" data="00ffffff"/^>
		echo 			^<value name="WindowMode" type="dword" data="00000520"/^>
		echo 			^<value name="ShowScrollbar" type="hex" data="01"/^>
		echo 			^<value name="QuakeStyle" type="hex" data="01"/^>
		echo 			^<value name="QuakeAnimation" type="ulong" data="100"/^>
		echo 			^<value name="Min2Tray" type="hex" data="01"/^>
		echo 			^<value name="TryToCenter" type="hex" data="01"/^>
		echo 			^<value name="TabFontHeight" type="long" data="12"/^>
		echo 			^<value name="TabsLocation" type="hex" data="01"/^>
		echo 			^<value name="TabFontFace" type="string" data="Arial Black"/^>
		echo 			^<value name="TabConsole" type="string" data="%%m⬛m%%s"/^>
		echo 			^<value name="TabModifiedSuffix" type="string" data="*"/^>
		echo 			^<value name="TabDblClick" type="ulong" data="3"/^>
		echo 			^<value name="AlphaValue" type="hex" data="dd"/^>
		echo 			^<value name="StatusBar.Show" type="hex" data="00"/^>
		echo 			^<value name="CTS.IntelligentExceptions" type="string" data="far"/^>
		echo 			^<value name="CTS.ResetOnRelease" type="hex" data="01"/^>
		echo 			^<value name="KeyboardHooks" type="hex" data="01"/^>
		echo 			^<value name="UseInjects" type="hex" data="01"/^>
		echo 			^<value name="Update.CheckOnStartup" type="hex" data="00"/^>
		echo 			^<value name="Update.CheckHourly" type="hex" data="00"/^>
		echo 			^<value name="Update.UseBuilds" type="hex" data="02"/^>
		echo 			^<value name="FontUseUnits" type="hex" data="01"/^>
		echo 			^<value name="FontSize" type="ulong" data="14"/^>
		echo 			^<value name="StatusFontHeight" type="long" data="12"/^>
		echo 			^<value name="TabFontHeight" type="long" data="12"/^>
		echo 			^<value name="DefaultBufferHeight" type="long" data="9999"/^>
		echo 			^<key name="HotKeys"^>
		echo 				^<value name="MinimizeRestore" type="dword" data="000011c0"/^>
		echo 			^</key^>
		echo 			^<key name="Tasks"^>
		echo 				^<value name="Count" type="long" data="1"/^>
		echo 				^<key name="Task1"^>
		echo 					^<value name="Name" type="string" data="{CygWin via Connector}"/^>
		echo 					^<value name="Flags" type="dword" data="00000005"/^>
		echo 					^<value name="Hotkey" type="dword" data="0000a254"/^>
		echo 					^<value name="GuiArgs" type="string" data=""/^>
		echo 					^<!--
		echo 					Removed path to icon to get more space for tabs
		echo 					The latest ConEmu releases come with cygwin connector preinstalled
		echo 					Terminal changed to cygwin instead of xterm-256color to prevent issues in screen session over SSH
		echo 					--^>
		if "%CYGWIN_SETUP%" == "setup-x86_64.exe" (
		echo 					^<value name="Cmd1" type="string" data="%%ConEmuDir%%\ConEmu\conemu-cyg-64.exe -new_console:p1 -t cygwin"/^>
		)
		if "%CYGWIN_SETUP%" == "setup-x86.exe" (
		echo 					^<value name="Cmd1" type="string" data="%%ConEmuDir%%\ConEmu\conemu-cyg-32.exe -new_console:p1 -t cygwin"/^>
		)
		echo 					^<value name="Active" type="long" data="0"/^>
		echo 					^<value name="Count" type="long" data="1"/^>
		echo 				^</key^>
		echo 				^<key name="Task2"^>
		echo 					^<value name="Name" type="string" data="{CygWin Bash}"/>
		echo 					^<value name="Flags" type="dword" data="00000004"/^>
		echo 					^<value name="Hotkey" type="dword" data="0000a242"/^>
		echo 					^<value name="GuiArgs" type="string" data=""/^>
		echo 					^<value name="Cmd1" type="string" data="%%ConEmuDir%%\..\cygwin\bin\bash.exe --login -i"/^>
		echo 					^<value name="Active" type="long" data="0"/^>
		echo 					^<value name="Count" type="long" data="1"/^>
		echo 				^</key^>
		echo 			^</key^>
		echo 		^</key^>
		echo 	^</key^>
		echo ^</key^>
	)> "%conemu_config%" || goto :fail
)


:: setting path to .bashrc
set Bashrc_sh=%CYGWIN_ROOT%\home\%CYGWIN_USERNAME%\.bashrc

:: inserting proxy settings to .bashrc
if not "%PROXY_HOST%" == "" (
	echo Adding proxy settings for host [%COMPUTERNAME%] to [/home/%CYGWIN_USERNAME%/.bashrc]...
	find "export http_proxy" "%Bashrc_sh%" >NUL || (
	echo.
	echo if [[ $HOSTNAME == "%COMPUTERNAME%" ]]; then
	echo 	export http_proxy=http://%PROXY_HOST%:%PROXY_PORT%
	echo 	export https_proxy=$http_proxy
	echo 	export no_proxy="::1,127.0.0.1,localhost,169.254.169.254,%COMPUTERNAME%,*.%USERDNSDOMAIN%"
	echo 	export HTTP_PROXY=$http_proxy
	echo 	export HTTPS_PROXY=$http_proxy
	echo 	export NO_PROXY=$no_proxy
	echo fi
	) >>"%Bashrc_sh%" || goto :fail
)
:: inserting soursing bash-funk in .bashrc if one is selected to install
if "%INSTALL_BASH_FUNK%" == "yes" (
	echo Adding bash-funk to [/home/%CYGWIN_USERNAME%/.bashrc]...
	find "bash-funk" "%Bashrc_sh%" >NUL || (
		(
			echo.
			echo source /opt/bash-funk/bash-funk.sh
		) >>"%Bashrc_sh%" || goto :fail
	)
)
:: inserting custom .bashrc settings
set bashrc_custom_config=%INSTALL_ROOT%bashrc_custom_config
set Inputrc_sh=%CYGWIN_ROOT%\home\%CYGWIN_USERNAME%\.inputrc
set inputrc_custom_config=%INSTALL_ROOT%inputrc_custom_config
if "%INSTALL_BASHRC_CUSTOMS%" == "yes" (
	cscript //Nologo %DOWNLOADER% https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/bashrc_custom "%bashrc_custom_config%" || goto :fail
	cscript //Nologo %DOWNLOADER% https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/inputrc_custom "%inputrc_custom_config%" || goto :fail
	echo Adding .bashrc customizations to [/home/%CYGWIN_USERNAME%/.bashrc] and [/home/%CYGWIN_USERNAME%/.inputrc]...
	type "%bashrc_custom_config%" >> "%Bashrc_sh%"
	type "%inputrc_custom_config%" >> "%Inputrc_sh%"
	echo Deleting [%bashrc_custom_config%] and [%inputrc_custom_config%]...
	del "%bashrc_custom_config%"
	del "%inputrc_custom_config%"
)
:: inserting ssh-agent settings
set ssh_agent_config=%INSTALL_ROOT%ssh_agent_config
if "%INSTALL_SSH_AGENT_TWEAK%" == "yes" (
	cscript //Nologo %DOWNLOADER% https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/re-use-ssh-agent "%ssh_agent_config%" || goto :fail
	echo Adding SSH agent tweak to [/home/%CYGWIN_USERNAME%/.bashrc]...
	type "%ssh_agent_config%" >> "%Bashrc_sh%"
	echo Deleting [%ssh_agent_config%]...
	del "%ssh_agent_config%"
)
:: converting .bashrc and .inputrc to unix format
"%CYGWIN_ROOT%\bin\dos2unix" "%Bashrc_sh%" || goto :fail
"%CYGWIN_ROOT%\bin\dos2unix" "%Inputrc_sh%" || goto :fail


:: deleting package cache
rd /s /q "%INSTALL_ROOT%cygwin-pkg-cache"
:: deleting temp custom conemu config
if exist "%INSTALL_ROOT%ConEmu.xml" (
	del "%INSTALL_ROOT%ConEmu.xml"
)
:: rename readme and licence files to txt if exist
if exist "%INSTALL_ROOT%LICENSE" (
	rename "%INSTALL_ROOT%LICENSE" "license.txt"
)
if exist "%INSTALL_ROOT%README.md" (
	rename "%INSTALL_ROOT%README.md" "readme.txt"
)
:: deleting VB script that can download files
del "%DOWNLOADER%"

echo.
echo ###########################################################
echo # Installation succeeded.
echo ###########################################################
echo.
echo Use launchers in [%INSTALL_ROOT%] to run ConCygSys.
echo.
pause
:: deleting installer
del "%INSTALL_ROOT%ConCygSys-installer.cmd"
goto :eof

:fail
	echo.
	echo ###########################################################
	echo #Installation FAILED!
	echo ###########################################################
	echo.
	pause
	exit /b 1
