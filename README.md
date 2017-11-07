# ConCygSys

- [Description](#description)
- [Features](#features)
- [Installation](#installation)
- [Usage](#default-actions-in-conemu-console)
- [Update](#update)
- [Customization](#customization)
- [FAQ](#faq)
- [License](#license)

## Description

This Windows batch script installs portable [CygWin](https://www.cygwin.com/) environment and connects to portable [ConEmu](https://conemu.github.io/) console emulator

ConCygSys is an independent fork of amazing [cygwin-portable-installer](https://github.com/vegardit/cygwin-portable-installer) project. At first minimally modified for sysadmin purposes, later on filled with improvements and new features

## Features

- fully portable CygWin, so you can:
  - move ConCygSys folder to diffent directory at any time
  - rename the folder
  - run from USB or network drive
  - use it in folders with spaces
- portable ConEmu (optional)
- only pure base with a couple of config files to make the installtion portable, no hacks with CygWin/ConEmu code

## Installation

> Disable antivirus software on your PC during installation. [Why it is recommended](https://cygwin.com/faq/faq.html#faq.using.bloda)

- Create a folder on your PC where you want to store the installation
- Download `ConCygSys-installer` from [this link](https://raw.githubusercontent.com/zhubanRuban/ConCygSys/master/ConCygSys-installer.cmd) *(right click > save link as)* to that folder
- Launch `ConCygSys-installer`
- Once the installation is finished, launch the desired shell (you can try them one-by-one to find the most suitable option for you):
  - `CygWin-Cmd` to run CygWin in standard Windows console
    - [Screenshots](https://www.google.com/search?q=cygwin+cmd&tbm=isch)
  - `CygWin-ConEmu` to run CygWin via ConEmu - multitab quake-style console - **recommended**
    - [Screenshots](https://www.google.com/search?q=conemu+cygwin&tbm=isch)
  - `CygWin-MinTTY` to run CygWin via [MinTTY](https://mintty.github.io/) terminal emulator - fully xterm-compatible, but without multitab and quake-style support
    - [Screenshots](https://www.google.com/search?q=mintty&tbm=isch)

## Default actions in ConEmu console

- **Select by Left Click and release** - copy
- **Right click** - paste

- **Ctrl+\`** - open/hide console
- **Double click on Tab** - rename a tab
- **Double click on Tab Panel** - open a new tab
- **Win+LShift+E** - split tab to right 50/50
- **Win+LShift+O** - split tab to bottom 50/50

- **Win+T** - open CygWin via [Connector](https://conemu.github.io/en/CygwinMsysConnector.html)
- **Win+B** - open CygWin via standard command line
- **Win+M** - open CygWin via MinTTY
- **Win+U** - open [WSL](https://msdn.microsoft.com/en-us/commandline/wsl/about) if installed

## Update

- Download `ConCygSys-installer` from [this link](https://raw.githubusercontent.com/zhubanRuban/ConCygSys/master/ConCygSys-installer.cmd) *(right click > save link as)* to existing ConCygSys directory
- Launch `ConCygSys-installer`

This will update CygWin, its packages and ConCygSys portable configuration files. ConEmu is already set to update itself regularily
> Backup .bashrc if you upgrade from very first release of ConCygSys

## Customization

If you open `ConCygSys-installer.cmd` with NotePad before installation, you will get a control over the installation settings.

**Available options:**

- `CYGWIN_USERNAME` - the desired username
  - default: empty (meaning current Windows username is used)
  
- `HOME_FOLDER` - home folder name e.g. /home/HOME_FOLDER
  - default: concygsys
  
- `CYGWIN_SETUP` - override processor architecture, for instance if you want to install 32bit CygWin on 64bit Windows
  - default: empty
  
- `CYGWIN_MIRROR` - a [mirror](https://cygwin.com/mirrors.html) you would like to download CygWin from
  - default: http://ftp.inf.tu-dresden.de/software/windows/cygwin32
  
- `CYGWIN_PACKAGES` - [packages to install](https://cygwin.com/packages/package_list.html)
  - default: bind-utils,curl,inetutils,openssh,openssl,vim,whois
  
- `LOCALE` - [the language of your command prompt](https://docs.oracle.com/cd/E23824_01/html/E26033/glset.html)
  - default: en_US.UTF-8
  
- `INSTALL_ACL` - enable or disable CygWin ACLs

CygWin uses ACLs to implement real Unix permissions (000, 777 etc.) which are not supported by Windows. However, if you move installation to different directory or PC, ACLs will be broken and will have troubles running binaries

Set to **yes** if you want real Unix permissions to the detriment of portability

Set to **no** if you want fully portable environment. Minimal permissions you will be able to set: `-r--r--r-- or 444`. Maximal: `-rw-r--r-- or 644`. Files with `exe` extension or beginning with shebang (`#!`) will automatically have 755 permissions

[More info](https://cygwin.com/cygwin-ug-net/using-filemodes.html)

  - default: no
  
- `INSTALL_APT_CYG` - install [apt-cyg package manager](https://github.com/kou1okada/apt-cyg)
  - default: yes
  
- `INSTALL_BASH_FUNK` - install [bash-funk - adaptive Bash prompt](https://github.com/vegardit/bash-funk)
  - default: yes
  
- `INSTALL_PSSH` - install [Parallel SSH tool on bash](https://github.com/zhubanRuban/cygwin-extras#pssh-parallelssh)
  - default: yes
  
- `INSTALL_PSCP` - install [Parallel SCP tool on bash](https://github.com/zhubanRuban/cygwin-extras#pscp-parallelscp)
  - default: yes
  
- `INSTALL_SSH_AGENT_TWEAK` - install [SSH agent enhancements](https://github.com/zhubanRuban/cygwin-extras#re-use-ssh-agent)
  - default: yes
  
- `INSTALL_BASHRC_CUSTOMS` - install [Bash prompt enhancements](https://github.com/zhubanRuban/cygwin-extras#custom-bashrc) *(disables bash-funk)*
  - default: yes
  
- `INSTALL_CONEMU` - install [ConEmu](https://conemu.github.io/) console
  - default: yes
  
- `CONEMU_OPTIONS` - set ConEmu launcher options https://conemu.github.io/en/ConEmuArgs.html
  - default: -Title ConCygSys
  
- `CYGWIN_PATH` - paths where to look for binaries, add more path if required, but at the cost of runtime performance
  - default: %%SystemRoot%%\system32;%%SystemRoot%%;%%CYGWIN_ROOT%%\bin;%%CYGWIN_ROOT%%\usr\sbin;%%CYGWIN_ROOT%%\usr\local\sbin
  
- `PROXY_HOST` and `PROXY_PORT` - set proxy if required
  - default: empty
  
- `MINTTY_OPTIONS` - set Mintty options used in ConEmu task, see https://cdn.rawgit.com/mintty/mintty/master/docs/mintty.1.html#CONFIGURATION . The main goal is to set options (they will overwrite whatyou configured in main MinTTY window) to make MinTTY working properly with ConEmu
  - default: --nopin --Border frame -o BellType=5 -o FontHeight=10 -o AllowBlinking=yes -o CopyOnSelect=yes -o RightClickAction=paste -o ScrollbackLines=5000 -o Transparency=off -o ConfirmExit=no

## FAQ

> What is the path to Windows drives when I'm in CygWin console?

/mnt/DRIVE

BTW, different Windows files are symlinked in CygWin environment, for instance:

- `/etc/hosts` file in CygWin is linked to `%WINDIR%\System32\drivers\etc\hosts`
- if you go to `/proc/registry` folder, you will see Windows registry structure

Many Windows programs can be executed from CygWin as well, for instance:

`ipconfig /flushdns` - to flush your local DNS cache

> Can I change username after installation?

Yes, just open your ConCygSys\cygwin\cugwin-settings.cmd file with NotePad and set a new username in `CYGWIN_USERNAME=` line

> Can I change username after installation?

Yes, just open your ConCygSys\cygwin\cugwin-settings.cmd file with NotePad and set a new username in `CYGWIN_USERNAME=` line

> How can I install a package from command line?

If you choose to install `apt-cyg` (enabled by default in installer) later you can istall packages from command line, for instance:

```
apt-cyg install nano
```

[More info about apt-cyg usage](https://github.com/kou1okada/apt-cyg)

[Available packages](https://cygwin.com/packages/package_list.html)

> I cannot find a package I require, what should I do?

You can still build it from source, below are some examples for the reference:

[MTR](https://github.com/traviscross/mtr)

[ipmitool](https://stackoverflow.com/questions/12907005/ipmitool-for-windows)

## License

All files are released under the [Apache License 2.0](https://github.com/zhubanRuban/ConCygSys/blob/master/LICENSE).
