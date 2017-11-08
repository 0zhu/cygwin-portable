# ConCygSys

- [Description](#description)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Update](#update)
- [Customization](#customization)
- [FAQ](#faq)
- [License](#license)

## Description

**ConCygSys** is a tool that installs portable [CygWin](https://www.cygwin.com/) environment and connects to portable [ConEmu](https://conemu.github.io/) console emulator. All required software in one folder

This is an independent fork of amazing [cygwin-portable-installer](https://github.com/vegardit/cygwin-portable-installer) project. At first minimally modified for sysadmin purposes, later on filled with improvements and new features

## Features

- downloads and installs the latest [CygWin](https://www.cygwin.com/) and makes it **fully portable**, so you can:
  - move ConCygSys folder to a diffent directory at any time
  - duplicate ConCygSys by copying its folder
  - rename the folder
  - run from USB or network drive
  - use it in folders with spaces
- downloads and installs the latest portable [ConEmu](https://conemu.github.io/) **([optional](#customization))**
- only pure base with a couple of config files to make the installtion portable, no hacks with CygWin/ConEmu code
- the installer is flexible, you can customize the installation process per your requirements (see [customization](#customization))

## Installation

> Disable antivirus software on your PC during installation. [Why it is recommended](https://cygwin.com/faq/faq.html#faq.using.bloda)

- Create a folder on your PC where you want to store the installation
- Download **`ConCygSys-installer.cmd`** from [this link](https://raw.githubusercontent.com/zhubanRuban/ConCygSys/master/ConCygSys-installer.cmd) *(right click > save link as)* to that folder
- **(Optional)** [Customize](#customization) installation per your requirements
- Launch **`ConCygSys-installer`**
- Once the installation is finished, run CygWin via one of the following launchers (you can try them one-by-one to find the most suitable option for you):
  - **`CygWin-Cmd`** to run CygWin in standard Windows console
    - [Screenshots](https://www.google.com/search?q=cygwin+cmd&tbm=isch)
  - **`CygWin-ConEmu`** to run CygWin via ConEmu - multitab quake-style console - **(RECOMMENDED)**
    - [Screenshots](https://www.google.com/search?q=conemu+cygwin&tbm=isch)
  - **`CygWin-MinTTY`** to run CygWin via [MinTTY](https://mintty.github.io/) terminal emulator - fully xterm-compatible, but without multitab and quake-style support
    - [Screenshots](https://www.google.com/search?q=mintty&tbm=isch)

## Usage

Default behaviour of CygWin console:

- **Select by Left Click and release** - copy
- **Right click** - paste

Shortcuts if using CygWin via ConEmu console:

- **Ctrl+\`** - open/hide console (quake style)
- **Double click on Tab** - rename a tab
- **Double click on Tab Panel** - open a new tab
- **Win+LShift+E** - split tab to right 50/50
- **Win+LShift+O** - split tab to bottom 50/50
- **Win+T** - open CygWin via [Connector](https://conemu.github.io/en/CygwinMsysConnector.html)
- **Win+B** - open CygWin via standard command line
- **Win+M** - open CygWin via MinTTY (default task)
- **Win+U** - open [WSL](https://msdn.microsoft.com/en-us/commandline/wsl/about) if installed

## Update

- Download **`ConCygSys-installer.cmd`** from [this link](https://raw.githubusercontent.com/zhubanRuban/ConCygSys/master/ConCygSys-installer.cmd) *(right click > save link as)* to existing ConCygSys directory
- Launch **`ConCygSys-installer`**

This will update CygWin, its packages and ConCygSys portable configuration files. ConEmu is already set to update itself regularily
> Backup your own .bashrc rules if you upgrade from very first release of ConCygSys

## Customization

If you open **`ConCygSys-installer.cmd`** with NotePad on your PC before installation, you will get a control over the installation settings. They can be found in **SCRIPT SETTINGS** section.

All settings are accompanied with description. [Preview](https://github.com/zhubanRuban/ConCygSys/blob/master/ConCygSys-installer.cmd)

## FAQ

- **What is the path to Windows drives when I'm in CygWin console?**

/mnt/DRIVE

BTW, different Windows files are symlinked in CygWin environment. For instance, `/etc/hosts` file in CygWin is linked to `%WINDIR%\System32\drivers\etc\hosts`; if you go to `/proc/registry` folder, you will see Windows registry structure

Many Windows programs can be executed from CygWin as well, for instance:

`ipconfig /flushdns` - to flush your local DNS cache

- **Can I change CygWin username after installation?**

Yes, just open your **`ConCygSys\cygwin\cygwin-settings.cmd`** file with NotePad and set a new username in `CYGWIN_USERNAME=` line

- **Can I change CygWin home folder after installation?**

Yes, just open your **`ConCygSys\cygwin\cygwin-settings.cmd`** file with NotePad and set a new username in `HOME_FOLDER=` line

- **How can I install a package from command line?**

If you choose to install `apt-cyg` (enabled by default in installer) later you can istall packages from command line, for instance:

```
apt-cyg install nano
```

[More info about apt-cyg usage](https://github.com/kou1okada/apt-cyg)

[Available packages](https://cygwin.com/packages/package_list.html)

- **I cannot find a package I require, what should I do?**

You can still build it from source, below are some examples for the reference:

[MTR](https://github.com/traviscross/mtr)

[ipmitool](https://stackoverflow.com/questions/12907005/ipmitool-for-windows)

## License

All files are released under the [Apache License 2.0](https://github.com/zhubanRuban/ConCygSys/blob/master/LICENSE).
