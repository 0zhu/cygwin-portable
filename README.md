# ConCygSys
![ConCygSys](https://github.com/zhubanRuban/cygwin-extras/raw/master/img/concygsys.png)

**ConEmu / CygWin Portable for SysAdmins**

-------------------

This is an independent fork of amazing [cygwin-portable-installer](https://github.com/vegardit/cygwin-portable-installer) project

**Modded specially for sysadmin purposes. Your Linux shell On Windows**

This will install portable [CygWin](https://www.cygwin.com/) environment and connect to portable [ConEmu](https://conemu.github.io/) console emulator, so you will have all required tools for server management in one folder which can be moved between PCs and/or run from USB stick

--------------------

## Installation

- Create a folder on your PC where you want to store ConCygSys, let it be `D:\concygsys\`
- Download installer from [this link](https://raw.githubusercontent.com/zhubanRuban/ConCygSys/master/ConCygSys-installer.cmd) (right click > save link as) to `D:\concygsys\`
- Launch `ConCygSys-installer.cmd` you downloaded to `D:\concygsys\`
- Once the installation is finished, launch the desired shell:
  - `ConCygSys.cmd` to run CygWin via ConEmu (if installed) - awesome multitab quake-style console - **recommended**
  - `ConCygSys-bash.cmd` to run CygWin in standard Windows console - **_helpful for CygWin behaviour troubleshooting_**
  - `ConCygSys-bash.cmd` to run CygWin via [MinTTY](https://mintty.github.io/) terminal emulator (if installed) - fully xterm-compatible, but without multitab and quake-style support - **_launch to access a server producing artefacts in ConEmu_**
- **have fun**
![source: https://i.ytimg.com/vi/bamH8SIG0h8/maxresdefault.jpg](https://i.ytimg.com/vi/bamH8SIG0h8/maxresdefault.jpg)

## Customization

If you open `ConCygSys-installer.cmd` with [Notepad++](https://notepad-plus-plus.org/) (forget about standard Notepad, it will mess everything up), you will get a control over the installation settings.

**Available options:**

- `CYGWIN_USERNAME` - the desired username (defaults to root)
- `CYGWIN_MIRROR` - a [mirror](https://cygwin.com/mirrors.html) you would like to download CygWin from
- `CYGWIN_PACKAGES` - [packages to install](https://cygwin.com/packages/package_list.html)
- `LOCALE` - [the language of your command prompt](https://docs.oracle.com/cd/E23824_01/html/E26033/glset.html)
- `INSTALL_APT_CYG` - install [apt-cyg package manager](https://github.com/transcode-open/apt-cyg)
- `INSTALL_BASH_FUNK` - install [bash-funk - adaptive Bash prompt](https://github.com/vegardit/bash-funk)
- `INSTALL_PSSH` - install [Parallel SSH tool on bash](https://github.com/zhubanRuban/cygwin-extras#pssh-parallelssh)
- `INSTALL_PSCP` - install [Parallel SCP tool on bash](https://github.com/zhubanRuban/cygwin-extras#pscp-parallelscp)
- `INSTALL_SSH_AGENT_TWEAK` - install [SSH agent enhancements](https://github.com/zhubanRuban/cygwin-extras#re-use-ssh-agent)
- `INSTALL_BASHRC_CUSTOMS` - install [Bash prompt enhancements](https://github.com/zhubanRuban/cygwin-extras#custom-bashrc) (disables bash-funk)
- `INSTALL_CONEMU` - install [ConEmu](https://conemu.github.io/) console
- `INSTALL_MINTTY` - install [MinTTY](https://mintty.github.io/) terminal emulator

## Important Note

In order to install ConCygSys successully, make sure you uninstalled any existing non-portable [CygWin](https://cygwin.com/faq/faq.html#faq.setup.uninstall-all) and [ConEmu](https://conemu.github.io/en/Installation.html) instances.

## License

All files are released under the [Apache License 2.0](https://github.com/vegardit/bash-funk/blob/master/LICENSE.txt).

## Where can I report an issue?

[Here](https://github.com/zhubanRuban/ConCygSys/issues)
