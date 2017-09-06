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
:: choose a user name under Cygwin
set CYGWIN_USERNAME=root

:: change the URL to the closest mirror https://cygwin.com/mirrors.html
set CYGWIN_MIRROR=http://ftp.inf.tu-dresden.de/software/windows/cygwin32

:: select the packages to be installed automatically via apt-cyg
set CYGWIN_PACKAGES=bind-utils,curl,inetutils,ipcalc,openssh,openssl,unzip,vim,whois,zip

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
:: that's what I talked about
if "%INSTALL_BASHRC_CUSTOMS%" == "yes" (
set INSTALL_BASH_FUNK=no
)

:: use ConEmu based tabbed terminal instead of Mintty based single window terminal, see https://conemu.github.io/
set INSTALL_CONEMU=yes
set CON_EMU_OPTIONS=-Title cygwin-portable ^
 -QuitOnClose

:: add more path if required, but at the cost of runtime performance (e.g. slower forks)
set CYGWIN_PATH=%%SystemRoot%%\system32;%%SystemRoot%%

:: set proxy if required (unfortunately Cygwin setup.exe does not have commandline options to specify proxy user credentials)
set PROXY_HOST=
set PROXY_PORT=8080

:: set Mintty options, see https://cdn.rawgit.com/mintty/mintty/master/docs/mintty.1.html#CONFIGURATION
set MINTTY_OPTIONS=--Title cygwin-portable ^
  -o Columns=160 ^
  -o Rows=50 ^
  -o BellType=0 ^
  -o ClicksPlaceCursor=yes ^
  -o CursorBlinks=yes ^
  -o CursorColour=96,96,255 ^
  -o CursorType=Block ^
  -o CopyOnSelect=yes ^
  -o RightClickAction=Paste ^
  -o Font="Courier New" ^
  -o FontHeight=10 ^
  -o FontSmoothing=None ^
  -o ScrollbackLines=10000 ^
  -o Transparency=off ^
  -o Term=xterm-256color ^
  -o Charset=UTF-8 ^
  -o Locale=C
::####################### end SCRIPT SETTINGS #######################::


echo.
echo ###########################################################
echo # Installing [Cygwin Portable]...
echo ###########################################################
echo.

set INSTALL_ROOT=%~dp0

set CYGWIN_ROOT=%INSTALL_ROOT%cygwin
if not exist "%CYGWIN_ROOT%" (
    md "%CYGWIN_ROOT%"
)


:: create VB script that can download files
:: not using PowerShell which may be blocked by group policies
set DOWNLOADER=%INSTALL_ROOT%downloader.vbs
echo Creating [%DOWNLOADER%] script...
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


:: download Cygwin 32 or 64 setup exe
if "%PROCESSOR_ARCHITEW6432%" == "AMD64" (
    set CYGWIN_SETUP=setup-x86_64.exe
) else (
    if "%PROCESSOR_ARCHITECTURE%" == "x86" (
        set CYGWIN_SETUP=setup-x86.exe
    ) else (
        set CYGWIN_SETUP=setup-x86_64.exe
    )
)
if exist "%CYGWIN_ROOT%\%CYGWIN_SETUP%" (
    del "%CYGWIN_ROOT%\%CYGWIN_SETUP%" || goto :fail
)
cscript //Nologo %DOWNLOADER% http://cygwin.org/%CYGWIN_SETUP% "%CYGWIN_ROOT%\%CYGWIN_SETUP%" || goto :fail


:: Cygwin command line options: https://cygwin.com/faq/faq.html#faq.setup.cli
if "%PROXY_HOST%" == "" (
    set CYGWIN_PROXY=
) else (
    set CYGWIN_PROXY=--proxy "%PROXY_HOST%:%PROXY_PORT%"
)


:: if conemu install is selected we need to be able to extract 7z archives
if "%INSTALL_APT_CYG%" == "yes" (
    set CYGWIN_PACKAGES=bsdtar,%CYGWIN_PACKAGES%
)

:: if bash-funk install is selected, install required software
if "%INSTALL_BASH_FUNK%" == "yes" (
    set CYGWIN_PACKAGES=git,git-svn,subversion,%CYGWIN_PACKAGES%
)


echo Running Cygwin setup...
"%CYGWIN_ROOT%\%CYGWIN_SETUP%" --no-admin ^
 --arch x86_64 ^
 --site %CYGWIN_MIRROR% %CYGWIN_PROXY% ^
 --root "%CYGWIN_ROOT%" ^
 --local-package-dir "%CYGWIN_ROOT%-pkg-cache" ^
 --no-shortcuts ^
 --no-desktop ^
 --delete-orphans ^
 --upgrade-also ^
 --no-replaceonreboot ^
 --quiet-mode ^
 --packages dos2unix,mintty,wget,%CYGWIN_PACKAGES% || goto :fail

 
:: disable stock Cygwin launcher
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
echo Creating [%Init_sh%]...
(
    echo #!/usr/bin/env bash
    echo.
    echo #
    echo # Map Current Windows User to root user
    echo #
    echo.
    echo # Check if current Windows user is in /etc/passwd
    echo USER_SID="$(mkpasswd -c | cut -d':' -f 5)"
    echo if ! grep -F "$USER_SID" /etc/passwd ^&^>/dev/null; then
    echo     echo "Mapping Windows user '$USER_SID' to cygwin '$USERNAME' in /etc/passwd..."
    echo     GID="$(mkpasswd -c | cut -d':' -f 4)"
    echo     echo $USERNAME:unused:1001:$GID:$USER_SID:$HOME:/bin/bash ^>^> /etc/passwd
    echo fi
    echo.
    echo # already set in cygwin-portable.cmd:
    echo # export CYGWIN_ROOT=$(cygpath -w /^)
    echo.
    echo #
    echo # adjust Cygwin packages cache path
    echo #
    echo pkg_cache_dir=$(cygpath -w "$CYGWIN_ROOT/../cygwin-pkg-cache"^)
    echo sed -i -E "s/.*\\\cygwin-pkg-cache/        ${pkg_cache_dir//\\/\\\\}/" /etc/setup/setup.rc
    echo.
    if not "%PROXY_HOST%" == "" (
        echo if [[ $HOSTNAME == "%COMPUTERNAME%" ]]; then
        echo     export http_proxy=http://%PROXY_HOST%:%PROXY_PORT%
        echo     export https_proxy=$http_proxy
        echo fi
    )
    if "%INSTALL_CONEMU%" == "yes" (
        echo #
        echo # Installing conemu if required
        echo #
        echo conemu_dir=$(cygpath -w "$CYGWIN_ROOT/../conemu"^)
        echo if [[ ! -e $conemu_dir ]]; then
        echo     echo "Installing ConEmu..."
        echo     conemu_url="https://github.com$(wget https://github.com/Maximus5/ConEmu/releases/latest -O - 2>/dev/null | egrep '/.*/releases/download/.*/.*7z' -o)" ^&^& \
        echo     echo "Download URL=$conemu_url" ^&^& \
        echo     wget -O "${conemu_dir}.7z" $conemu_url ^&^& \
        echo     mkdir $conemu_dir ^&^& \
        echo     bsdtar -xvf "${conemu_dir}.7z" -C "$conemu_dir" ^&^& \
        echo     rm "${conemu_dir}.7z" ^&^& \
        echo     echo "Installing ConEmu Cygwin Connector..." ^&^& \
        echo     conemu_connector_url="https://github.com$(wget https://github.com/Maximus5/cygwin-connector/releases/latest -O - 2>/dev/null | egrep '/.*/releases/download/.*/.*7z' -o)" ^&^& \
        echo     echo "Download URL=$conemu_connector_url" ^&^& \
        echo     wget -O "${conemu_dir}_cygwin_connector.7z" $conemu_connector_url ^&^& \
        echo     bsdtar -xvf "${conemu_dir}_cygwin_connector.7z" -C "/bin"  --include 'conemu-cyg-*.exe' ^&^& \
        echo     chmod 755 /bin/conemu-cyg-*.exe ^&^& \
        echo     rm "${conemu_dir}_cygwin_connector.7z"
        echo fi
    )
    if "%INSTALL_APT_CYG%" == "yes" (
        echo #
        echo # Installing apt-cyg package manager if required
        echo #
        echo if [[ ! -x /usr/local/bin/apt-cyg ]]; then
        echo     echo "Installing apt-cyg..."
        echo     wget -O /usr/local/bin/apt-cyg https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
        echo     chmod +x /usr/local/bin/apt-cyg
        echo fi
        echo.
    )
	if "%INSTALL_PSSH%" == "yes" (
        echo #
        echo # Installing parallel ssh tool
        echo #
        echo if [[ ! -x /usr/local/bin/pssh ]]; then
        echo     echo "Installing parallel ssh tool..."
        echo     wget -O /usr/local/bin/pssh https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/pssh
        echo     chmod +x /usr/local/bin/pssh
        echo fi
        echo.
    )
	if "%INSTALL_PSCP%" == "yes" (
        echo #
        echo # Installing parallel scp tool
        echo #
        echo if [[ ! -x /usr/local/bin/pscp ]]; then
        echo     echo "Installing parallel scp tool..."
        echo     wget -O /usr/local/bin/pscp https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/pscp
        echo     chmod +x /usr/local/bin/pscp
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
        echo   echo Installing [bash-funk]...
        echo   if hash git ^&^>/dev/null; then
        echo     git clone https://github.com/vegardit/bash-funk --branch master --single-branch /opt/bash-funk
        echo   elif hash svn ^&^>/dev/null; then
        echo     svn checkout https://github.com/vegardit/bash-funk/trunk /opt/bash-funk
        echo   else
        echo     mkdir /opt/bash-funk ^&^& \
        echo     cd /opt/bash-funk ^&^& \
        echo     wget -qO- --show-progress https://github.com/vegardit/bash-funk/tarball/master ^| tar -xzv --strip-components 1
        echo   fi
        echo fi
    )
) >"%Init_sh%" || goto :fail

:: launching created portable-init.sh script
"%CYGWIN_ROOT%\bin\dos2unix" "%Init_sh%" || goto :fail


:: creating cygwin-portable.cmd that will keep the installation portable from Windows side
set Start_cmd=%INSTALL_ROOT%ConCygSys.cmd
echo Creating [%Start_cmd%]...
(
    echo @echo off
    echo set CWD=%%cd%%
    echo set CYGWIN_DRIVE=%%~d0
    echo set CYGWIN_ROOT=%%~dp0cygwin
    echo.
    echo set PATH=%CYGWIN_PATH%;%%CYGWIN_ROOT%%\bin
    echo set ALLUSERSPROFILE=%%CYGWIN_ROOT%%.ProgramData
    echo set ProgramData=%%ALLUSERSPROFILE%%
    echo set CYGWIN=nodosfilewarning
    echo.
    echo set USERNAME=%CYGWIN_USERNAME%
    echo set HOME=/home/%%USERNAME%%
    echo set SHELL=/bin/bash
    echo set HOMEDRIVE=%%CYGWIN_DRIVE%%
    echo set HOMEPATH=%%CYGWIN_ROOT%%\home\%%USERNAME%%
    echo set GROUP=None
    echo set GRP=
    echo.
    echo %%CYGWIN_DRIVE%%
    echo chdir "%%CYGWIN_ROOT%%\bin"
    echo bash "%%CYGWIN_ROOT%%\portable-init.sh"
    echo.
    echo if "%%1" == "" (
    if "%INSTALL_CONEMU%" == "yes" (
        echo if "%%PROCESSOR_ARCHITEW6432%%" == "AMD64" (
        echo     start %%~dp0conemu\ConEmu64.exe %CON_EMU_OPTIONS%
        echo ^) else (
        echo     if "%%PROCESSOR_ARCHITECTURE%%" == "x86" (
        echo         start %%~dp0conemu\ConEmu.exe %CON_EMU_OPTIONS%
        echo     ^) else (
        echo         start %%~dp0conemu\ConEmu64.exe %CON_EMU_OPTIONS%
        echo     ^)
        echo ^)
    ) else (
        echo   mintty --nopin %MINTTY_OPTIONS% --icon %CYGWIN_ROOT%\Cygwin-Terminal.ico -
    )
    echo ^) else (
    echo   if "%%1" == "no-mintty" (
    echo     bash --login -i
    echo   ^) else (
    echo     bash --login -c %%*
    echo   ^)
    echo ^)
    echo.
    echo cd "%%CWD%%"
) >"%Start_cmd%" || goto :fail


:: launching bash once to initialize user home dir
call %Start_cmd% whoami


:: downloading and installing custom ConEmu config from https://github.com/zhubanRuban/cygwin-extras
set conemu_config=%INSTALL_ROOT%conemu\ConEmu.xml
set conemu_custom_config=%INSTALL_ROOT%conemu_custom_config
if "%INSTALL_CONEMU%" == "yes" (
	cscript //Nologo %DOWNLOADER% https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/ConEmu.xml "%conemu_custom_config%" || goto :fail
	echo Adding custom ConEmu config to [%conemu_config%]...
	type "%conemu_custom_config%" > "%conemu_config%"
	echo Deleting [%conemu_custom_config%]...
	del "%conemu_custom_config%"
)


:: setting path to .bashrc
set Bashrc_sh=%CYGWIN_ROOT%\home\%CYGWIN_USERNAME%\.bashrc


:: inserting proxy settings to .bashrc
if not "%PROXY_HOST%" == "" (
    echo Adding proxy settings for host [%COMPUTERNAME%] to [/home/%CYGWIN_USERNAME%/.bashrc]...
    find "export http_proxy" "%Bashrc_sh%" >NUL || (
        echo.
        echo if [[ $HOSTNAME == "%COMPUTERNAME%" ]]; then
        echo     export http_proxy=http://%PROXY_HOST%:%PROXY_PORT%
        echo     export https_proxy=$http_proxy
        echo     export no_proxy="::1,127.0.0.1,localhost,169.254.169.254,%COMPUTERNAME%,*.%USERDNSDOMAIN%"
        echo     export HTTP_PROXY=$http_proxy
        echo     export HTTPS_PROXY=$http_proxy
        echo     export NO_PROXY=$no_proxy
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
if "%INSTALL_BASHRC_CUSTOMS%" == "yes" (
	cscript //Nologo %DOWNLOADER% https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/bashrc_custom.sh "%bashrc_custom_config%" || goto :fail
	echo Adding .bashrc customizations to [/home/%CYGWIN_USERNAME%/.bashrc]...
	type "%bashrc_custom_config%" >> "%Bashrc_sh%"
	echo Deleting [%bashrc_custom_config%]...
	del "%bashrc_custom_config%"
)
:: inserting ssh-agent settings
set ssh_agent_config=%INSTALL_ROOT%ssh_agent_config
if "%INSTALL_SSH_AGENT_TWEAK%" == "yes" (
	cscript //Nologo %DOWNLOADER% https://raw.githubusercontent.com/zhubanRuban/cygwin-extras/master/re-use-ssh-agent.sh "%ssh_agent_config%" || goto :fail
	echo Adding SSH agent tweak to [/home/%CYGWIN_USERNAME%/.bashrc]...
	type "%ssh_agent_config%" >> "%Bashrc_sh%"
	echo Deleting [%ssh_agent_config%]...
	del "%ssh_agent_config%"
)
:: executing .bashrc to apply changes
"%CYGWIN_ROOT%\bin\dos2unix" "%Bashrc_sh%" || goto :fail


:: deleting VB script that can download files
del "%DOWNLOADER%"
:: deleting package cache
del "%CYGWIN_ROOT%-pkg-cache"
del "%INSTALL_ROOT%cygwin-pkg-cache"
:: renaming licence and readme file
rename "%INSTALL_ROOT%LICENSE" "%INSTALL_ROOT%LICENSE.txt"
rename "%INSTALL_ROOT%README.md" "%INSTALL_ROOT%README.txt"

echo.
echo ###########################################################
echo # Installing [Cygwin Portable] succeeded.
echo ###########################################################
echo.
echo Use [%Start_cmd%] to launch Cygwin Portable.
echo.
pause
:: deleting installer
del "%INSTALL_ROOT%ConCygSys-installer.cmd"
goto :eof

:fail
    if exist "%DOWNLOADER%" (
        del "%DOWNLOADER%"
    )
    echo.
    echo ###########################################################
    echo #Installing [Cygwin Portable] FAILED!
    echo ###########################################################
    echo.
    pause
    exit /b 1
