# ConCygSys <a href="https://github.com/zhubanRuban/ConCygSys/"><img height="30" src="https://camo.githubusercontent.com/7710b43d0476b6f6d4b4b2865e35c108f69991f3/68747470733a2f2f7777772e69636f6e66696e6465722e636f6d2f646174612f69636f6e732f6f637469636f6e732f313032342f6d61726b2d6769746875622d3235362e706e67"></a> <a href="https://mintty.github.io/" target="_blank"><img align="right" height="40" src="https://pbs.twimg.com/profile_images/1938877716/terminal-256.png"></a> <a href="https://conemu.github.io/" target="_blank"><img align="right" height="40" src="https://upload.wikimedia.org/wikipedia/commons/d/dc/ConEmu_icon.png"></a> <a href="https://www.cygwin.com/" target="_blank"><img align="right" height="40" src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Cygwin_logo.svg/128px-Cygwin_logo.svg.png"></a>

- [Description](#description)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Update](#update)
- [Customization](#customization)
- [FAQ](#faq)
- [License](#license)

## Description

**ConCygSys** is a tool that installs portable [Cygwin](https://www.cygwin.com/) Unix-like environment and connects to portable [ConEmu](https://conemu.github.io/) console emulator. All required software in one folder. Now also with [WSLtty](https://github.com/mintty/wsltty) support!

This is an independent fork of amazing [cygwin-portable-installer](https://github.com/vegardit/cygwin-portable-installer) project. At first minimally modified for sysadmin purposes, later on filled with improvements and new features.

## Features

- Downloads and installs the latest [Cygwin](https://www.cygwin.com/) and makes it **fully portable**, so you can:
  - move it to a different directory at any time
  - duplicate it by copying its folder
  - rename the folder
  - run from USB or network drive
  - use it in folders with spaces
- Downloads and installs the latest portable [ConEmu](https://conemu.github.io/)
- Only pure base with a couple of config files to make the installtion portable, no hacks with [Cygwin](https://www.cygwin.com/)/[ConEmu](https://conemu.github.io/) code
- The installer is flexible, you can customize the installation process per your requirements
- Being portable, the script can also **upgrade** itself and its components
- Windows 7+ supported

## Installation

> Disable antivirus software on your PC during installation. [Why it is recommended](https://cygwin.com/faq/faq.html#faq.using.bloda)

- Download the [latest ConCygSys release](https://github.com/zhubanRuban/ConCygSys/releases), extract the archive and go to the extracted folder

> **Optional:** Edit **`ConCygSys-installer`** to [customize](#customization) the installation per your requirements

- Launch **`ConCygSys-installer`**

> If Windows complains with a **Windows protected your PC** popup, you may need to click **Run anyway** to proceed with the installation.

- Once the installation is finished, you can run [Cygwin](https://www.cygwin.com/) via one of the following launchers:
  - <img align="middle" height="50" src="https://www.petri.com/images/03-Cygwin-ls.JPG"> **`CygWin-Cmd`** to run [Cygwin](https://www.cygwin.com/) in standard Windows console
  - <img align="middle" height="50" src="https://i.ytimg.com/vi/bamH8SIG0h8/maxresdefault.jpg"> **`CygWin-ConEmu`** to run [Cygwin](https://www.cygwin.com/) via [ConEmu](https://conemu.github.io/) - multitab quake-style console **(RECOMMENDED)**
  - <img align="middle" height="50" src="https://www.howtogeek.com/wp-content/uploads/2011/07/sshot-35.png"> **`CygWin-MinTTY`** to run [Cygwin](https://www.cygwin.com/) via [Mintty](https://mintty.github.io/) terminal emulator - fully xterm-compatible, but without multitab and quake-style support
  - <img align="middle" height="50" src="https://pbs.twimg.com/media/CuMUQhZWYAA8yDc.jpg"> **`CygWin-WSLtty`** to run [WSL](https://docs.microsoft.com/en-us/windows/wsl/about) via [Mintty](https://mintty.github.io/) terminal emulator
  
> You can try the launchers one-by-one to find the most suitable option

## Usage

Default behaviour of [Cygwin](https://www.cygwin.com/) console:

- **Select by Left Click and release** - copy
- **Right click** - paste

Shortcuts if using [Cygwin](https://www.cygwin.com/) via [ConEmu](https://conemu.github.io/) console:

- **Ctrl+\`** - open/hide console (quake style)
- **Double click on Tab** - rename a tab
- **Double click on Tab Panel** - open a new tab
- **Win+X** - open a new tab with standard Windows console

## Update

> ConCygSys consists of:
> - **[CygWin](https://www.cygwin.com/):** Unix-like environment itself
> - **[ConEmu](https://conemu.github.io/):** multitab console you open this Unix-like environment from
> - **ConCygSys core:** configuration files and settings keeping the installation portable

Use **`update`** launcher in the root of your ConCygSys directory to update the installation.

You will be able either to update **[Cygwin](https://www.cygwin.com/) only** or to perform a **full update**: [Cygwin](https://www.cygwin.com/) + ConCygSys core. [ConEmu](https://conemu.github.io/) is already set to check its updates on startup and can update itself independently.

> If you cannot find **`update`** launcher, this means that you are updating one of the earliest stable/beta releases, therefore you need to perfrom the update manually:
> - Download **`ConCygSys-installer.cmd`** from [this link](https://raw.githubusercontent.com/zhubanRuban/ConCygSys/master/ConCygSys-installer.cmd) *(right click > save link as)* to existing ConCygSys directory
> - Launch **`ConCygSys-installer`**

## Customization

Open **`ConCygSys-installer`** with text editor on your PC before installation to get a control over the installation process. Available options will be in **SCRIPT SETTINGS** section. All settings are accompanied with description. [Preview](https://github.com/zhubanRuban/ConCygSys/blob/8a60a599a4ad8bff3d28bd0e9370370621a2668d/ConCygSys-installer.cmd#L9-L76)

If you have existing ConCygSys installation and would like to add/remove some components during next update, edit **:installoptions** section of **`update`** launcher.

## FAQ

- **What is the path to Windows drives when I'm in [Cygwin](https://www.cygwin.com/) console?**

`/mnt/DRIVE`

BTW, different Windows files are symlinked in [Cygwin](https://www.cygwin.com/) environment. For instance, `/etc/hosts` file in [Cygwin](https://www.cygwin.com/) is linked to `%WINDIR%\System32\drivers\etc\hosts`. If you go to `/proc/registry` folder, you will see Windows registry structure. Many Windows programs can be executed from [Cygwin](https://www.cygwin.com/) as well, for instance:

`ipconfig /flushdns` - to flush your local DNS cache

- **How to change default task for new tab in [ConEmu](https://conemu.github.io/)?**

ConEmu settings>> Startup>> Tasks>> choose a desired task>> tick "Default task for new console">> Save settings

- **Can I change [Cygwin](https://www.cygwin.com/) username after installation?**

No problem, just edit `CYGWIN_USERNAME=` line in **:cygwinsettings** section of **`update`** launcher in your ConCygSys directory. Restart [Cygwin](https://www.cygwin.com/).

- **Сan I install a package from command line?**

If you've chosen to install `apt-cyg` *(enabled by default in installer)*, you can istall packages from command line, for instance:

```bash
apt-cyg install nano
```

[More info about apt-cyg usage](https://github.com/transcode-open/apt-cyg) | [Available packages](https://cygwin.com/packages/package_list.html)

- **I cannot find a desired package in [Cygwin](https://www.cygwin.com/) repository, what should I do?**

This can happen. Fortunately, the packages can still be built from source. `install <package> cygwin` search query will give you the right answer in most cases.
Below are some examples for the reference:

[MTR](https://github.com/traviscross/mtr)

[ipmitool](https://stackoverflow.com/questions/12907005/ipmitool-for-windows)

- **Can I try beta version?**

No problem. There is [beta tree](https://github.com/zhubanRuban/ConCygSys/tree/beta)
> - Download **`ConCygSys-installer.cmd`** from [this link](https://github.com/zhubanRuban/ConCygSys/raw/beta/ConCygSys-installer.cmd) *(right click > save link as)* to existing ConCygSys directory
> - Launch **`ConCygSys-installer`**

- **Where can I report an issue or get a support?**

[Here](https://github.com/zhubanRuban/ConCygSys/issues)

- **How to check ConCygSys version?**

The version can be found at the beginning of:
- README.txt file
- any launcher file

## License

All files are released under the [Apache License 2.0](https://github.com/zhubanRuban/ConCygSys/blob/master/LICENSE).
