# ConCygSys
![concygsys](https://raw.githubusercontent.com/zhubanRuban/ConCygSys/master/data/concygsys.png)

**ConEmu / CygWin Portable for SysAdmins**

-------------------

This is an independent fork of amazing [cygwin-portable-installer](https://github.com/vegardit/cygwin-portable-installer) project

**Modded specially for sysadmin purposes. Your Linux shell On Windows**

This will install portable [CygWin](https://www.cygwin.com/) environment and connect to portable [ConEmu](https://conemu.github.io/) console emulator, so you will have all required tools for server management in one folder which can be moved between PCs and/or run from USB stick

--------------------

## Installation

> In order to install ConCygSys successully, make sure you uninstalled any existing non-portable [CygWin](https://cygwin.com/faq/faq.html#faq.setup.uninstall-all) and [ConEmu](https://conemu.github.io/en/Installation.html) instances. Also disable antivirus software on your PC. [Why it is recommended](https://cygwin.com/faq/faq.html#faq.using.bloda)

- Create a folder on your PC where you want to store ConCygSys, let it be `D:\concygsys\`
- Download installer from [this link](https://raw.githubusercontent.com/zhubanRuban/ConCygSys/master/ConCygSys-installer.cmd) *(right click > save link as)* to `D:\concygsys\`
- Launch `ConCygSys-installer.cmd` you downloaded to `D:\concygsys\`
- Once the installation is finished, launch the desired shell (you can try them one-by-one to find the most suitable option for you):
  - `ConCygSys` to run CygWin via ConEmu *(if installed)* - awesome multitab quake-style console - **recommended**
  - `ConCygSys-cmd` to run CygWin in standard Windows console - **_helpful for CygWin behaviour troubleshooting_**
  - `ConCygSys-mintty` to run CygWin via [MinTTY](https://mintty.github.io/) terminal emulator - fully xterm-compatible, but without multitab and quake-style support - **_launch to access a server producing artefacts in ConEmu_**
- **have fun**
![concygsys-conemu](https://raw.githubusercontent.com/zhubanRuban/ConCygSys/master/data/concygsys-conemu.png)

## Default actions in ConEmu console

- **Ctrl+\`** - open/hide console
- **Select by Left Click and release** - copy
- **Right click** - paste
- **Double click on Tab** - rename a tab
- **Double click on Tab Panel** - open a new tab
- **Ctrl+Shift+E** - split tab to right 50/50
- **Ctrl+Shift+O** - split tab to bottom 50/50

## Customization

If you open `ConCygSys-installer.cmd` with [Notepad++](https://notepad-plus-plus.org/) *(forget about standard Notepad, it will mess everything up)* before installation, you will get a control over the installation settings.

**Available options:**

- `CYGWIN_USERNAME` - the desired username
> default: empty (meaning current Windows username is used)
- `HOME_FOLDER` - home folder name e.g. /home/HOME_FOLDER
> default: concygsys
- `CYGWIN_SETUP` - override processor architecture, for instance if you want to install 32bit CygWin on 64bit Windows
> default: empty
- `CYGWIN_MIRROR` - a [mirror](https://cygwin.com/mirrors.html) you would like to download CygWin from
> default: http://ftp.inf.tu-dresden.de/software/windows/cygwin32
- `CYGWIN_PACKAGES` - [packages to install](https://cygwin.com/packages/package_list.html)
> default: bind-utils,curl,inetutils,openssh,openssl,vim,whois
- `LOCALE` - [the language of your command prompt](https://docs.oracle.com/cd/E23824_01/html/E26033/glset.html)
> default: en_US.UTF-8
- `INSTALL_ACL` - enable or disable CygWin ACLs

CygWin uses ACLs to implement real Unix permissions (000, 777 etc.) which are not supported by Windows. However, if you move installation to different directory or PC, ACLs will be broken and will have troubles running binaries

Set to **yes** if you want real Unix permissions to the detriment of portability

Set to **no** if you want fully portable environment. Minimal permissions you will be able to set: `-r--r--r-- or 444`. Maximal: `-rw-r--r-- or 644`. Files with `exe` extension or beginning with shebang (`#!`) will automatically have 755 permissions

[More info](https://cygwin.com/cygwin-ug-net/using-filemodes.html)

> default: no
- `INSTALL_APT_CYG` - install [apt-cyg package manager](https://github.com/transcode-open/apt-cyg)
> default: yes
- `INSTALL_BASH_FUNK` - install [bash-funk - adaptive Bash prompt](https://github.com/vegardit/bash-funk)
> default: yes
- `INSTALL_PSSH` - install [Parallel SSH tool on bash](https://github.com/zhubanRuban/cygwin-extras#pssh-parallelssh)
> default: yes
- `INSTALL_PSCP` - install [Parallel SCP tool on bash](https://github.com/zhubanRuban/cygwin-extras#pscp-parallelscp)
> default: yes
- `INSTALL_SSH_AGENT_TWEAK` - install [SSH agent enhancements](https://github.com/zhubanRuban/cygwin-extras#re-use-ssh-agent)
> default: yes
- `INSTALL_BASHRC_CUSTOMS` - install [Bash prompt enhancements](https://github.com/zhubanRuban/cygwin-extras#custom-bashrc) *(disables bash-funk)*
> default: yes
- `INSTALL_CONEMU` - install [ConEmu](https://conemu.github.io/) console
> default: yes

## FAQ

> Is ConCygSys fully portable?

Yes, you can install it on USB stick, move installation to different folder and different PC

> What is the path to Windows drives when I'm in CygWin console?

/mnt/DRIVE

BTW, different Windows files are symlinked in CygWin environment, for instance:

- `/etc/hosts` file in CygWin is linked to `%WINDIR%\System32\drivers\etc\hosts`
- if you go to `/proc/registry` folder, you will see Windows registry structure

Many Windows programs can be executed from CygWin as well, for instance:

`ipconfig /flushdns` - to flush your local DNS cache

> Can I change username after installation?

Yes, just open your favourite installer cmd file (`ConCygSys`, `ConCygSys-cmd` or `ConCygSys-mintty`) with NotePad++ and set a new username in `CYGWIN_USERNAME=` line

> How can I install a package?

If you choose to install `apt-cyg` (enabled by default in installer) later you can istall packages from command line, for instance:

```
apt-cyg install nano
```
[More info about apt-cyg usage](https://github.com/transcode-open/apt-cyg)

[Available packages](https://cygwin.com/packages/package_list.html)

> How can I upgrade my environment?

ConCygSys contains two components:
- [CygWin](https://www.cygwin.com/) - "Linux envoronment" itself
- [ConEmu](https://conemu.github.io/) - multitab console you open "Linux envoronment" from

To update `CygWin`: run `updater` cmd file in `YOUR_CONCYGSYS_FOLDER\cygwin` directory

To update `ConEmu`: ConEmu is setup to check updates on ConEmu startup and update itself accordingly

[CygWin FAQ](https://cygwin.com/faq.html)

[ConEmu FAQ](https://conemu.github.io/en/ConEmuFAQ.html)

## License

All files are released under the [Apache License 2.0](https://github.com/vegardit/bash-funk/blob/master/LICENSE.txt).
