@echo off

:: ConCygSys: Cygwin and ConEmu portable installer https://github.com/zhubanRuban/ConCygSys
:: This is the independent fork of https://github.com/vegardit/cygwin-portable-installer project

set CONCYGSYS_VERSION=180629


::####################### begin SCRIPT SETTINGS #######################::
:: You can customize the following variables to your needs before running the batch file

:: choose a user name under Cygwin, leave empty to use your Windows username
set CYGWIN_USERNAME=

:: home folder name e.g. /home/HOME_FOLDER, leave empty to use default one - concygsys
set HOME_FOLDER=

:: override processor architecture: setup-x86.exe for 32bit or setup-x86_64.exe for 64bit system, leave empty for autodetect
set CYGWIN_SETUP=

:: change the URL to the closest mirror: https://cygwin.com/mirrors.html
set CYGWIN_MIRROR=http://ftp.inf.tu-dresden.de/software/windows/cygwin32

:: select the packages to be installed automatically: https://cygwin.com/packages/package_list.html
set CYGWIN_PACKAGES=bind-utils,curl,inetutils,openssh,openssl,vim,whois

:: Cygwin uses ACLs to implement real Unix permissions which are not supported by Windows: https://cygwin.com/cygwin-ug-net/using-filemodes.html
:: However, if you move installation to different directory or PC, ACLs will be broken and will have troubles running Cygwin binaries
:: Set to 'yes' if you want real Unix permissions to the detriment of portability
:: Set to 'no' if you want fully portable environment
:: Minimal permissions you will be able to set with disabled ACLs: "-r--r--r--" or "444"
:: Maximal: "-rw-r--r--" or "644". Files with exe extension or beginning with shebang will automatically have 755 permissions
set INSTALL_ACL=no

:: install apt-cyg command line package manager: https://github.com/transcode-open/apt-cyg
set INSTALL_APT_CYG=yes

:: install bash-funk adaptive Bash prompt: https://github.com/vegardit/bash-funk
set INSTALL_BASH_FUNK=yes

:: install parallel ssh tool: https://github.com/zhubanRuban/cygwin-extras#pssh-parallelssh
set INSTALL_PSSH=yes

:: install parallel scp tool: https://github.com/zhubanRuban/cygwin-extras#pscp-parallelscp
set INSTALL_PSCP=yes

:: install SSH agent tweak https://github.com/zhubanRuban/cygwin-extras#ssh-agent-tweak
set INSTALL_SSH_AGENT_TWEAK=yes

:: install custom bashrc rules for better experience https://github.com/zhubanRuban/cygwin-extras#custom-bashrc
:: if set to 'yes', will disable bash-funk adaptive Bash prompt (see INSTALL_BASH_FUNK) to prevent conflicts
set INSTALL_BASHRC_CUSTOMS=yes

:: install WSLbridge to allowing to access WSL via Mintty https://github.com/rprichard/wslbridge
set INSTALL_WSLBRIDGE=yes

:: install multitab terminal https://conemu.github.io/
set INSTALL_CONEMU=yes
:: https://conemu.github.io/en/ConEmuArgs.html
set CONEMU_OPTIONS=-Title ConCygSys

:: set proxy if required (unfortunately Cygwin setup.exe does not have commandline options to specify proxy user credentials)
set PROXY_HOST=
set PROXY_PORT=8080

:: set Mintty options used in ConEmu task: https://cdn.rawgit.com/mintty/mintty/master/docs/mintty.1.html#CONFIGURATION
:: the main goal is to set options (they will overwrite whatyou configured in main Mintty window) to make Mintty working properly with ConEmu
set MINTTY_OPTIONS=-o FontHeight=10 ^
-o BoldAsFont=yes ^
-o AllowBlinking=yes ^
-o CopyOnSelect=yes ^
-o RightClickAction=paste ^
-o ScrollbackLines=5000 ^
-o Transparency=off ^
-o ConfirmExit=no
::####################### end SCRIPT SETTINGS #######################::


echo.
set CONCYGSYS_LINK=https://github.com/zhubanRuban/ConCygSys
set CONCYGSYS_INFO=ConCygSys v.%CONCYGSYS_VERSION% %CONCYGSYS_LINK%
echo [ %CONCYGSYS_INFO% ]
echo.

:: %~dp0 means current directory with backslash at the end
set INSTALL_ROOT=%~dp0

set CYGWIN_ROOT=%INSTALL_ROOT%cygwin
set Concygsys_settings_name=update.cmd
set Concygsys_settings=%INSTALL_ROOT%%Concygsys_settings_name%

:: to use 'set' in full in 'if' loop below: https://ss64.com/nt/delayedexpansion.html
setlocal EnableDelayedExpansion

if not exist "%CYGWIN_ROOT%" (
	echo Creating Cygwin folder [%CYGWIN_ROOT%]...
	md "%CYGWIN_ROOT%"
) else (
	echo Existing Cygwin folder detected [%CYGWIN_ROOT%], entering update mode...
	set UPDATEMODE=yes
	wmic process get ExecutablePath 2>NUL | find /I "%CYGWIN_ROOT%">NUL
	:: rem is used below instead of :: for commenting as loops produce "system cannot find disk" warning when using :: in miltiple lines
	rem for those wondering why I didn't use if "%ERRORLEVEL%"=="0"
	rem https://social.technet.microsoft.com/Forums/en-US/e72cb532-3da0-4c7f-a61e-9ffbf8050b55/batch-errorlevel-always-reports-back-level-0?forum=ITCG
	if not ErrorLevel 1 (
		echo.
		echo ^^!^^!^^! Active Cygwin processes detected, please close them and re-run update ^^!^^!^^!
		wmic process get ExecutablePath | find /I "%CYGWIN_ROOT%"
		goto :fail
	) else (
		if exist "%Concygsys_settings%" (
			call "%Concygsys_settings%" cygwinsettings
			call "%Concygsys_settings%" installoptions
		) else (
			set UPDATEFROMOLD=yes
		)
		echo.
		set /p UPDATECYGWINONLY=   [ 1 and ENTER] - update Cygwin only   [ ENTER ] - update everything 
		if not "!UPDATECYGWINONLY!" == "" goto :updatecygwinonly
		echo.
		echo ^^!^^!^^! Before you proceed with update... ^^!^^!^^!
		if "!UPDATEFROMOLD!" == "yes" (
			echo It seems that you are upgrading from one of the oldest ConCygSys releases
			echo Please BACKUP your personal records in .bashrc
			echo Hit ENTER when done
			echo.
			pause
		) else (
			echo To customize update process:
			echo - close this window
			echo - modify :installoptions section of [%Concygsys_settings%] file accordingly
			echo - re-run update
			echo.
			echo If you are good with existing setup, just hit ENTER
			echo.
			pause
		)
	)
)
:: not needed anymore and to prevent issues in bash script generation down below (they conatin ! which should have been escaped by ^^)
setlocal DisableDelayedExpansion

:updatecygwinonly
:: There is no true-commandline download tool in Windows
:: creating VB script that can download files...
:: not using PowerShell which may be blocked by group policies
set DOWNLOADER=%INSTALL_ROOT%downloader.vbs
echo.
echo Creating script that can download files [%DOWNLOADER%]...
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

echo.
echo Choosing correct version of Cygwin installer...
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

:: Removing existing setup.exe
del "%CYGWIN_ROOT%\%CYGWIN_SETUP%" >NUL 2>&1

:: downloading Cygwin installer
echo.
cscript //Nologo "%DOWNLOADER%" http://cygwin.org/%CYGWIN_SETUP% "%CYGWIN_ROOT%\%CYGWIN_SETUP%" || goto :fail
del "%DOWNLOADER%" >NUL 2>&1

:: Cygwin command line options: https://cygwin.com/faq/faq.html#faq.setup.cli
if "%PROXY_HOST%" == "" (
	set CYGWIN_PROXY=
) else (
	set CYGWIN_PROXY=--proxy "%PROXY_HOST%:%PROXY_PORT%"
)


:: adding required packages for special software
if "%INSTALL_CONEMU%" == "yes" (
	set CYGWIN_PACKAGES=bsdtar,wget,%CYGWIN_PACKAGES%
)
if "%INSTALL_WSLBRIDGE%" == "yes" (
	set CYGWIN_PACKAGES=bsdtar,wget,%CYGWIN_PACKAGES%
)
if "%INSTALL_APT_CYG%" == "yes" (
	set CYGWIN_PACKAGES=wget,%CYGWIN_PACKAGES%
)
if "%INSTALL_BASHRC_CUSTOMS%" == "yes" (
	set INSTALL_BASH_FUNK=no
)
if "%INSTALL_BASH_FUNK%" == "yes" (
	set CYGWIN_PACKAGES=git,git-svn,subversion,%CYGWIN_PACKAGES%
)
if "%INSTALL_PSSH%" == "yes" (
	set CYGWIN_PACKAGES=wget,%CYGWIN_PACKAGES%
)
if "%INSTALL_PSCP%" == "yes" (
	set CYGWIN_PACKAGES=wget,%CYGWIN_PACKAGES%
)
if "%INSTALL_SSH_AGENT_TWEAK%" == "yes" (
	set CYGWIN_PACKAGES=openssh,%CYGWIN_PACKAGES%
)

:: all Cygwin installer commandline options: https://www.cygwin.com/faq/faq.html#faq.setup.cli
echo.
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

:: deleting standard Cygwin launcher
del "%CYGWIN_ROOT%\Cygwin.bat" >NUL 2>&1
echo %CONCYGSYS_INFO% >"%CYGWIN_ROOT%\DO-NOT-LAUNCH-CYGWIN-FROM-HERE"

if not "%UPDATECYGWINONLY%" == "" goto :aftercygwinupdate


echo.
echo Creating portable settings files...

set Portable_init_name=portable-init.sh
set Portable_init=%CYGWIN_ROOT%\%Portable_init_name%
echo Creating init script to keep the installation portable [%Portable_init%]...
(
	echo #!/usr/bin/env bash
	echo # %CONCYGSYS_INFO%
	echo.
	echo PATH=/usr/local/bin:/usr/bin
	echo.
	echo # Setting custom Cygwin username
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
) >"%Portable_init%" || goto :fail

"%CYGWIN_ROOT%\bin\dos2unix" "%Portable_init%" || goto :fail

echo Generating one-file settings and updater file [%Concygsys_settings%]...
(
	echo @echo off
	echo :: %CONCYGSYS_INFO%
	echo.
	echo if "%%1" == "cygwinsettings" goto :cygwinsettings
	echo if "%%1" == "installoptions" goto :installoptions
	echo if "%%1" == "launcherheader" goto :launcherheader
	echo goto :update
	echo.
	echo :cygwinsettings
	echo :: %CONCYGSYS_LINK%#customization
	echo set CYGWIN_USERNAME=%CYGWIN_USERNAME%
	echo set HOME_FOLDER=%HOME_FOLDER%
	echo exit /b 0
	echo.
	echo :installoptions
	echo :: %CONCYGSYS_LINK%#customization
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
	echo exit /b 0
	echo.
	echo :launcherheader
	echo set CYGWIN_ROOT=%%~dp0cygwin
	echo call "%%~dp0%Concygsys_settings_name%" cygwinsettings
	echo set ALLUSERSPROFILE=%%CYGWIN_ROOT%%\ProgramData
	echo set ProgramData=%%ALLUSERSPROFILE%%
	echo if not "%%CYGWIN_USERNAME%%" == "" (
	echo 	set USERNAME=%%CYGWIN_USERNAME%%
	echo ^)
	echo if "%%HOME_FOLDER%%" == "" (
	echo 	set HOME_FOLDER=concygsys
	echo ^)
	echo set HOME=/home/%%HOME_FOLDER%%
	echo rd /s /q "%%CYGWIN_ROOT%%\pkg-cache" 2^>NUL
	echo type NUL ^>"%%CYGWIN_ROOT%%\etc\fstab"
	echo "%%CYGWIN_ROOT%%\bin\bash" "%%CYGWIN_ROOT%%\%Portable_init_name%"
	echo exit /b 0
	echo.
	echo :update
	echo echo [ %CONCYGSYS_INFO% ]
	echo set INSTALL_ROOT=%%~dp0
	echo set DOWNLOADER=%%INSTALL_ROOT%%downloader.vbs
	echo echo Creating a script that can download files [%%DOWNLOADER%%]...
	echo (
	echo 	echo url = Wscript.Arguments(0^^^)
	echo 	echo target = Wscript.Arguments(1^^^)
	echo 	echo WScript.Echo "Downloading '" ^^^& url ^^^& "' to '" ^^^& target ^^^& "'..."
	echo 	echo Set req = CreateObject("WinHttp.WinHttpRequest.5.1"^^^)
	echo 	echo req.Open "GET", url, False
	echo 	echo req.Send
	echo 	echo If req.Status ^^^<^^^> 200 Then
	echo 	echo    WScript.Echo "FAILED to download: HTTP Status " ^^^& req.Status
	echo 	echo    WScript.Quit 1
	echo 	echo End If
	echo 	echo Set buff = CreateObject("ADODB.Stream"^^^)
	echo 	echo buff.Open
	echo 	echo buff.Type = 1
	echo 	echo buff.Write req.ResponseBody
	echo 	echo buff.Position = 0
	echo 	echo buff.SaveToFile target
	echo 	echo buff.Close
	echo 	echo.
	echo ^) ^>"%%DOWNLOADER%%" ^|^| goto :fail
	echo set INSTALLER=ConCygSys-installer.cmd
	echo cscript //Nologo "%%DOWNLOADER%%" https://raw.githubusercontent.com/zhubanRuban/ConCygSys/master/%%INSTALLER%% "%%INSTALLER%%" ^|^| goto :fail
	echo start "" "%%INSTALLER%%" ^|^| goto :fail
	echo exit 0
	echo :fail
	echo del "%%DOWNLOADER%%" ^>NUL 2^>^&1
	echo echo.
	echo echo                       !!! Update FAILED !!!
	echo echo Try uploading installer manually from %CONCYGSYS_LINK%
	echo echo.
	echo pause
	echo exit 1
) >"%Concygsys_settings%" || goto :fail


echo.
echo Generating main launchers...

set Launch_cmd=%INSTALL_ROOT%Cygwin-Cmd.cmd
echo Generating cmd launcher [%Launch_cmd%]...
(
	echo @echo off
	echo :: %CONCYGSYS_INFO%
	echo call "%%~dp0%Concygsys_settings_name%" launcherheader
	echo if "%%1" == "" (
	echo 	"%%CYGWIN_ROOT%%\bin\bash.exe" --login -i
	echo ^) else (
	echo 	"%%CYGWIN_ROOT%%\bin\bash.exe" --login -c %%*
	echo ^)
) >"%Launch_cmd%" || goto :fail

set Launch_conemu=%INSTALL_ROOT%Cygwin-ConEmu.cmd
if "%INSTALL_CONEMU%" == "yes" (
	echo Generating ConEmu launcher [%Launch_conemu%]...
	(
		echo @echo off
		echo :: %CONCYGSYS_INFO%
		echo call "%%~dp0%Concygsys_settings_name%" launcherheader
		echo :: to be in win home dir if running cmd from conemu
		echo %%HOMEDRIVE%%
		echo cd %%HOMEPATH%%
		echo if "%%PROCESSOR_ARCHITEW6432%%" == "AMD64" (
		echo 	start "" "%%~dp0conemu\ConEmu64.exe" %CONEMU_OPTIONS%
		echo ^) else (
		echo 	if "%%PROCESSOR_ARCHITECTURE%%" == "x86" (
		echo 		start "" "%%~dp0conemu\ConEmu.exe" %CONEMU_OPTIONS%
		echo 	^) else (
		echo 		start "" "%%~dp0conemu\ConEmu64.exe" %CONEMU_OPTIONS%
		echo 	^)
		echo ^)
		echo exit 0
	) >"%Launch_conemu%" || goto :fail
) else (
	echo Removing ConEmu launcher [%Launch_conemu%]...
	del "%Launch_conemu%" >NUL 2>&1
)

set Launch_mintty=%INSTALL_ROOT%Cygwin-Mintty.cmd
echo Generating Mintty launcher [%Launch_mintty%]...
(
	echo @echo off
	echo :: %CONCYGSYS_INFO%
	echo call "%%~dp0%Concygsys_settings_name%" launcherheader
	echo start "" "%%CYGWIN_ROOT%%\bin\mintty.exe" --Title ConCygSys -
	echo exit 0
) >"%Launch_mintty%" || goto :fail

set Launch_wsltty=%INSTALL_ROOT%Cygwin-WSLtty.cmd
if "%INSTALL_WSLBRIDGE%" == "yes" (
	echo Generating WSLtty launcher [%Launch_wsltty%]...
	(
		echo @echo off
		echo :: %CONCYGSYS_INFO%
		echo start "" "%%~dp0cygwin\bin\mintty.exe" --Title ConCygSysWSL --WSL=  -~
		echo exit 0
	) >"%Launch_wsltty%" || goto :fail
) else (
	echo Removing WSLtty launcher [%Launch_wsltty%]...
	del "%Launch_wsltty%" >NUL 2>&1
)

echo.
echo Launching bash once to initialize user home dir...
call "%Launch_cmd%" whoami || goto :fail


set Post_install=%CYGWIN_ROOT%\post-install.sh
echo.
echo Creating script to install required and additional software [%Post_install%]...
(
	echo #!/usr/bin/env bash
	echo PATH=/usr/local/bin:/usr/bin
	echo bashrc_f=${HOME}/.bashrc
	echo mkdir -p /opt
	:: delete messy bashrc if updating from earliest ConCygSys versions
	if "%UPDATEFROMOLD%" == "yes" (
		echo cat /etc/skel/.bashrc ^> "$bashrc_f"
	)
	if not "%PROXY_HOST%" == "" (
		echo if [ "${HOSTNAME^^}" == "%COMPUTERNAME%" ]; then
		echo 	export http_proxy=http://%PROXY_HOST%:%PROXY_PORT%
		echo 	export https_proxy=$http_proxy
		echo fi
		echo echo
		echo echo Adding proxy settings for host [%COMPUTERNAME%] to [$bashrc_f]...
		echo (
		echo echo if [ \"\${HOSTNAME^^}\" == \"%COMPUTERNAME%\" ]\; then
		echo echo	export http_proxy=http://%PROXY_HOST%:%PROXY_PORT%
		echo echo	export https_proxy=\$http_proxy
		echo echo	export no_proxy="::1,127.0.0.1,localhost,169.254.169.254,%COMPUTERNAME%,*.%USERDNSDOMAIN%"
		echo echo	export HTTP_PROXY=\$http_proxy
		echo echo	export HTTPS_PROXY=\$http_proxy
		echo echo	export NO_PROXY=\$no_proxy
		echo echo fi
		echo ^) ^> /opt/bash_proxy
		echo if grep -q '/opt/bash_proxy' "$bashrc_f"; then
		echo 	sed -i '/bash_proxy/c\if [ -f "/opt/bash_proxy" ]; then source "/opt/bash_proxy"; fi' "$bashrc_f"
		echo else
		echo 	echo 'if [ -f "/opt/bash_proxy" ]; then source "/opt/bash_proxy"; fi' ^>^> "$bashrc_f"
		echo fi
	) else (
		echo rm -f /opt/bash_proxy
		echo sed -i '/bash_proxy/d' "$bashrc_f"
	)
	echo conemu_dir=$(cygpath -w "$CYGWIN_ROOT/../conemu"^)
	if "%INSTALL_CONEMU%" == "yes" (
		echo if [ ! -e "$conemu_dir" ]; then
		echo 	echo
		echo 	conemu_url="https://github.com$(wget https://github.com/Maximus5/ConEmu/releases/latest -O - 2>/dev/null | egrep '/.*/releases/download/.*/.*7z' -o)" ^&^& \
		echo 	echo "Installing ConEmu from $conemu_url" ^&^& \
		echo 	wget -nv --show-progress -O "${conemu_dir}.7z" "$conemu_url" ^&^& \
		echo 	mkdir -p "$conemu_dir" ^&^& \
		echo 	echo "Extracting ConEmu from archive..." ^&^& \
		echo 	bsdtar -xf "${conemu_dir}.7z" -C "$conemu_dir" ^&^& \
		echo 	rm -f "${conemu_dir}.7z"
		echo fi
		echo echo %CONCYGSYS_INFO% ^> "$CYGWIN_ROOT/../conemu/DO-NOT-LAUNCH-CONEMU-FROM-HERE"
	) else (
		echo rm -rf "$conemu_dir"
	)
	if "%INSTALL_WSLBRIDGE%" == "yes" (
		echo echo
		if "%CYGWIN_SETUP%" == "setup-x86_64.exe" (
			echo wslbridge_url="https://github.com$(wget https://github.com/rprichard/wslbridge/releases/latest -O - 2>/dev/null | egrep '/.*/releases/download/.*/.*cygwin64.tar.gz' -o)"
		)
		if "%CYGWIN_SETUP%" == "setup-x86.exe" (
			echo wslbridge_url="https://github.com$(wget https://github.com/rprichard/wslbridge/releases/latest -O - 2>/dev/null | egrep '/.*/releases/download/.*/.*cygwin32.tar.gz' -o)"
		)
		echo echo "Installing WSLbridge from $wslbridge_url" ^&^& \
		echo wget -nv --show-progress -O "${CYGWIN_ROOT}.tar.gz" "$wslbridge_url" ^&^& \
		echo echo "Extracting WSLbridge from archive..." ^&^& \
		echo bsdtar -xf "${CYGWIN_ROOT}.tar.gz" --strip-components=1 -C "${CYGWIN_ROOT}/bin/" '*/wslbridge*' ^&^& \
		echo rm -f "${CYGWIN_ROOT}.tar.gz"
	) else (
		echo rm -f "${CYGWIN_ROOT}/bin/wslbridge"*
	)
	if "%INSTALL_APT_CYG%" == "yes" (
		echo echo
		echo echo "Installing/updating apt-cyg..."
		echo wget -nv --show-progress -O /usr/local/bin/apt-cyg https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
		echo chmod +x /usr/local/bin/apt-cyg
	) else (
		echo rm -f /usr/local/bin/apt-cyg
	)
	if "%INSTALL_PSSH%" == "yes" (
		echo echo
		echo echo "Installing/updating parallel ssh tool..."
		echo wget -nv --show-progress -O /usr/local/bin/pssh https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/pssh
		echo chmod +x /usr/local/bin/pssh
	) else (
		echo rm -f /usr/local/bin/pssh
	)
	if "%INSTALL_PSCP%" == "yes" (
		echo echo
		echo echo "Installing/updating parallel scp tool..."
		echo wget -nv --show-progress -O /usr/local/bin/pscp https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/pscp
		echo chmod +x /usr/local/bin/pscp
	) else (
		echo rm -f /usr/local/bin/pscp
	)
	if "%INSTALL_BASH_FUNK%" == "yes" (
		echo if [ ! -e "/opt/bash-funk/bash-funk.sh" ]; then
		echo 	echo
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
		echo echo Adding bash-funk to [$bashrc_f]...
		echo if grep -q '/opt/bash-funk/bash-funk.sh' "$bashrc_f"; then
		echo 	sed -i '/bash-funk.sh/c\if [ -f "/opt/bash-funk/bash-funk.sh" ]; then source "/opt/bash-funk/bash-funk.sh"; fi' "$bashrc_f"
		echo else
		echo 	echo 'if [ -f "/opt/bash-funk/bash-funk.sh" ]; then source "/opt/bash-funk/bash-funk.sh"; fi' ^>^> "$bashrc_f"
		echo fi
	) else (
		echo sed -i '/bash-funk.sh/d' "$bashrc_f"
		echo rm -rf /opt/bash-funk
	)
	if "%INSTALL_BASHRC_CUSTOMS%" == "yes" (
		echo echo
		echo echo Adding customizations to [$bashrc_f] and [${HOME}/.inputrc]...
		echo wget -nv --show-progress -O /opt/bashrc_custom https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/bashrc_custom
		echo if grep -q '/opt/bashrc_custom' "$bashrc_f"; then
		echo 	sed -i '/bashrc_custom/c\if [ -f "/opt/bashrc_custom" ]; then source "/opt/bashrc_custom"; fi' "$bashrc_f"
		echo else
		echo 	echo 'if [ -f "/opt/bashrc_custom" ]; then source "/opt/bashrc_custom"; fi' ^>^> "$bashrc_f"
		echo fi
		echo cat /etc/skel/.inputrc ^> "${HOME}/.inputrc"
		echo wget -nv --show-progress https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/inputrc_custom -O- ^>^> "${HOME}/.inputrc"
	) else (
		echo rm -f /opt/bashrc_custom
		echo sed -i '/bashrc_custom/d' "$bashrc_f"
		echo cat /etc/skel/.inputrc ^> "${HOME}/.inputrc"
	)
	set ssh_agent_config=%INSTALL_ROOT%ssh_agent_config
	if "%INSTALL_SSH_AGENT_TWEAK%" == "yes" (
		echo echo
		echo echo Adding SSH agent tweak to [$bashrc_f]...
		echo wget -nv --show-progress -O /opt/ssh-agent-tweak https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/ssh-agent-tweak
		echo if grep -q '/opt/ssh-agent-tweak' "$bashrc_f"; then
		echo 	sed -i '/ssh-agent-tweak/c\if [ -f "/opt/ssh-agent-tweak" ]; then source "/opt/ssh-agent-tweak"; fi' "$bashrc_f"
		echo else
		echo 	echo 'if [ -f "/opt/ssh-agent-tweak" ]; then source "/opt/ssh-agent-tweak"; fi' ^>^> "$bashrc_f"
		echo fi
	) else (
		echo rm -f /opt/ssh-agent-tweak
		echo sed -i '/ssh-agent-tweak/d' "$bashrc_f"
	)
) >"%Post_install%" || goto :fail

"%CYGWIN_ROOT%\bin\dos2unix" "%Post_install%" || goto :fail

echo Launching post-install script...
"%CYGWIN_ROOT%\bin\bash" "%Post_install%" || goto :fail
del "%Post_install%" >NUL 2>&1


set Conemu_config=%INSTALL_ROOT%conemu\ConEmu.xml
if "%INSTALL_CONEMU%" == "yes" (
	echo.
	echo Replacing ConEmu config...
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
		echo 					^<value name="Cmd1" type="string" data='"%%ConEmuDir%%\..\cygwin\bin\bash.exe" --login -i -cur_console:pm:"/mnt":P:"&lt;xterm&gt;":h5000'/^>
		echo 					^<value name="Active" type="long" data="0"/^>
		echo 					^<value name="Count" type="long" data="1"/^>
		echo 				^</key^>
		echo 				^<key name="Task2"^>
		echo 					^<value name="Name" type="string" data="{Cygwin::Connector}"/^>
		echo 					^<value name="Flags" type="dword" data="00000004"/^>
		echo 					^<value name="Hotkey" type="dword" data="00000000"/^>
		echo 					^<value name="GuiArgs" type="string" data=""/^>
		rem Removed path to icon to get more space for tabs
		rem Terminal changed to cygwin instead of xterm-256color to prevent issues in screen session over SSH
		if "%CYGWIN_SETUP%" == "setup-x86_64.exe" (
			echo 					^<value name="Cmd1" type="string" data='set "PATH=%%ConEmuDir%%\..\cygwin\bin;%%PATH%%" ^&amp; "%%ConEmuBaseDirShort%%\conemu-cyg-64.exe" "%%ConEmuDir%%\..\cygwin\bin\bash.exe" --login -i -cur_console:pm:"/mnt":P:"&lt;xterm&gt;":h5000'/^>
		)
		if "%CYGWIN_SETUP%" == "setup-x86.exe" (
			echo 					^<value name="Cmd1" type="string" data='set "PATH=%%ConEmuDir%%\..\cygwin\bin;%%PATH%%" ^&amp; "%%ConEmuBaseDirShort%%\conemu-cyg-32.exe" "%%ConEmuDir%%\..\cygwin\bin\bash.exe" --login -i -cur_console:pm:"/mnt":P:"&lt;xterm&gt;":h5000'/^>
		)
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
		if "%CYGWIN_SETUP%" == "setup-x86_64.exe" (
			echo 					^<value name="Cmd1" type="string" data='set "PATH=%%ConEmuBaseDirShort%%\wsl;%%PATH%%" ^&amp; "%%ConEmuBaseDirShort%%\conemu-cyg-64.exe" --wsl -C~ -cur_console:pm:"/mnt":P:"&lt;ubuntu&gt;":h5000'/^>
		)
		if "%CYGWIN_SETUP%" == "setup-x86.exe" (
			echo 					^<value name="Cmd1" type="string" data='set "PATH=%%ConEmuBaseDirShort%%\wsl;%%PATH%%" ^&amp; "%%ConEmuBaseDirShort%%\conemu-cyg-32.exe" --wsl -C~ -cur_console:pm:"/mnt":P:"&lt;ubuntu&gt;":h5000'/^>
		)
		echo 					^<value name="Active" type="long" data="0"/^>
		echo 					^<value name="Count" type="long" data="1"/^>
		echo 				^</key^>
		echo 				^<key name="Task6"^>
		echo 					^<value name="Name" type="string" data="{WSL::WSLtty}"/^>
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
	)> "%Conemu_config%" || goto :fail
)


echo.
echo Cleaning up...
:: deleting obsolete files used by previous concygsys versions
rd /s /q "%INSTALL_ROOT%data" >NUL 2>&1
del "%CYGWIN_ROOT%\updater.cmd" >NUL 2>&1
del "%CYGWIN_ROOT%\cygwin-settings.cmd" >NUL 2>&1
del "%CYGWIN_ROOT%\cygwin-install-options.cmd" >NUL 2>&1
:: delting readme and licence files
del "%INSTALL_ROOT%LICENSE" >NUL 2>&1
del "%INSTALL_ROOT%README.md" >NUL 2>&1
(
	echo %CONCYGSYS_INFO%
	echo Project page and Documentation:
	echo %CONCYGSYS_LINK%
)> "%INSTALL_ROOT%README.txt" || goto :fail
:aftercygwinupdate


echo.
if "%UPDATEMODE%" == "yes" (
	echo                    [ Update SUCCEEDED! ]
) else (
	echo                 [ Installation SUCCEEDED! ]
)
echo.
echo  Use launchers in [%INSTALL_ROOT%] to run Cygwin Portable.
echo.
pause
:: deleting installer and old launchers
del "%INSTALL_ROOT%ConCygSys*" >NUL 2>&1
exit 0


:fail
echo.
if "%UPDATEMODE%" == "yes" (
	echo                         [ Update FAILED! ]
	echo Try uploading installer manually from %CONCYGSYS_LINK%
) else (
	echo                      [ Installation FAILED! ]
)
echo.
pause
exit 1
