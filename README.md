# ConCygSys <a href="https://github.com/zhubanRuban/ConCygSys/"><img height="30" src="http://iconshow.me/media/images/ui/ios7-icons/png/128/social-github.png"></a> <a href="https://mintty.github.io/" target="_blank"><img align="right" height="40" src="https://pbs.twimg.com/profile_images/1938877716/terminal-256.png"></a> <a href="https://conemu.github.io/" target="_blank"><img align="right" height="40" src="https://upload.wikimedia.org/wikipedia/commons/d/dc/ConEmu_icon.png"></a> <a href="https://www.cygwin.com/" target="_blank"><img align="right" height="40" src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Cygwin_logo.svg/128px-Cygwin_logo.svg.png"></a>

- [Description](#description)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Update](#update)
- [Customization](#customization)
- [FAQ](#faq)
- [License](#license)

## Description

**ConCygSys** is a tool that installs portable [CygWin](https://www.cygwin.com/) Unix-like environment and connects to portable [ConEmu](https://conemu.github.io/) console emulator. All required software in one folder.

This is an independent fork of amazing [cygwin-portable-installer](https://github.com/vegardit/cygwin-portable-installer) project. At first minimally modified for sysadmin purposes, later on filled with improvements and new features.

## Features

- downloads and installs the latest [CygWin](https://www.cygwin.com/) and makes it **fully portable**, so you can:
  - move it to a different directory at any time
  - duplicate it by copying its folder
  - rename the folder
  - run from USB or network drive
  - use it in folders with spaces
- downloads and installs the latest portable [ConEmu](https://conemu.github.io/)
- only pure base with a couple of config files to make the installtion portable, no hacks with CygWin/ConEmu code
- the installer is flexible, you can customize the installation process per your requirements
- can upgrade itself and its components

## Installation

> Disable antivirus software on your PC during installation. [Why it is recommended](https://cygwin.com/faq/faq.html#faq.using.bloda)

- Download the [latest ConCygSys release](https://github.com/zhubanRuban/ConCygSys/releases), extract the archive and go to the extracted folder

> **Optional:** Edit **`ConCygSys-installer`** to [customize](#customization) the installation per your requirements

- Launch **`ConCygSys-installer`**

> If Windows complains with a **Windows protected your PC** popup, you may need to click **Run anyway** to proceed with the installation.

- Once the installation is finished, you can run CygWin via one of the following launchers:
  - <img align="middle" height="50" src="http://i1-win.softpedia-static.com/screenshots/Cygwin_2.png?1350904296"> **`CygWin-Cmd`** to run CygWin in standard Windows console
  - <img align="middle" height="50" src="https://i.ytimg.com/vi/bamH8SIG0h8/maxresdefault.jpg"> **`CygWin-ConEmu`** to run CygWin via ConEmu - multitab quake-style console **(RECOMMENDED)**
  - <img align="middle" height="50" src="https://www.howtogeek.com/wp-content/uploads/2011/07/sshot-35.png"> **`CygWin-MinTTY`** to run CygWin via [MinTTY](https://mintty.github.io/) terminal emulator - fully xterm-compatible, but without multitab and quake-style support
  
> You can try the launchers one-by-one to find the most suitable option

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

> ConCygSys consists of:
> - [CygWin](https://www.cygwin.com/): Unix-like environment itself
> - [ConEmu](https://conemu.github.io/): multitab console you open this Unix-like environment from
> - ConCygSys core: configuration files and settings keeping the installation portable

Use **`update`** launcher in the root of your ConCygSys directory to update the installation.

You will be able either to update **Cygwin only** or to perform a **full update**: CygWin + ConCygSys core. ConEmu is already set to check its updates on startup and can update itself independently.

<details><summary><strong>If you cannot find <code>update</code> launcher</strong></summary><p>

> This means that you are updating one of the earliest stable/beta releases, therefore you need to perfrom the update manually:

- Download **`ConCygSys-installer.cmd`** from [this link](https://raw.githubusercontent.com/zhubanRuban/ConCygSys/master/ConCygSys-installer.cmd) *(right click > save link as)* to existing ConCygSys directory

- Launch **`ConCygSys-installer`**

</p></details>

## Customization

Edit **`ConCygSys-installer`** on your PC before installation to get a control over the installation process. Available options will be in **SCRIPT SETTINGS** section. All settings are accompanied with description. [Preview](https://github.com/zhubanRuban/ConCygSys/blob/master/ConCygSys-installer.cmd)

If you have existing ConCygSys installation and would like to add/remove some components during next update, edit **:installoptions** section of **`update`** launcher.

## FAQ

- **What is the path to Windows drives when I'm in CygWin console?**

`/mnt/DRIVE`

BTW, different Windows files are symlinked in CygWin environment. For instance, `/etc/hosts` file in CygWin is linked to `%WINDIR%\System32\drivers\etc\hosts`. If you go to `/proc/registry` folder, you will see Windows registry structure. Many Windows programs can be executed from CygWin as well, for instance:

`ipconfig /flushdns` - to flush your local DNS cache

- **Can I change CygWin username after installation?**

No problem, just edit `CYGWIN_USERNAME=` line in **:cygwinsettings** section of **`update`** launcher in your ConCygSys directory. Restart CygWin.

- **Сan I install a package from command line?**

If you've chosen to install `apt-cyg` *(enabled by default in installer)*, you can istall packages from command line, for instance:

```bash
apt-cyg install nano
```

[More info about apt-cyg usage](https://github.com/transcode-open/apt-cyg) | [Available packages](https://cygwin.com/packages/package_list.html)

- **I cannot find a desired package in CygWin repository, what should I do?**

This can happen. Fortunately, the packages can still be built from source. `install <package> cygwin` search query will give you the right answer in most cases.
Below are some examples for the reference:

[MTR](https://github.com/traviscross/mtr)

[ipmitool](https://stackoverflow.com/questions/12907005/ipmitool-for-windows)

## License

All files are released under the [Apache License 2.0](https://github.com/zhubanRuban/ConCygSys/blob/master/LICENSE).
