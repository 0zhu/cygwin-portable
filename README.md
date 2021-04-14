# ConCygSys <a href="https://docs.microsoft.com/en-us/windows/wsl/about" target="_blank"><img align="right" height="40" src="https://wsldownload.azureedge.net/ubuntu.ico"></a> <a href="https://conemu.github.io/" target="_blank"><img align="right" height="40" src="https://upload.wikimedia.org/wikipedia/commons/d/dc/ConEmu_icon.png"></a> <a href="https://www.cygwin.com/" target="_blank"><img align="right" height="40" src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Cygwin_logo.svg/128px-Cygwin_logo.svg.png"></a>

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/0zhu/cygwin-portable?style=flat-square)](../../releases)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/0zhu/cygwin-portable?style=flat-square)
![HitCount](http://hits.dwyl.io/0zhu/cygwin-portable.svg)
[![GitHub](https://img.shields.io/github/license/0zhu/cygwin-portable?style=flat-square)](LICENSE)

- [Description](#description)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Update](#update)
- [Customization](#customization)
- [FAQ](#faq)

## Description

**ConCygSys** is a lightweight tool that installs portable [Cygwin](https://www.cygwin.com/) Unix-like environment and connects to portable [ConEmu](https://conemu.github.io/) console emulator, with self-update feature.

> This is an independent fork of amazing [cygwin-portable-installer](https://github.com/vegardit/cygwin-portable-installer) project. At first minimally modified for sysadmin purposes, later on filled with improvements and new features.

## Features

- Downloads and installs the latest Cygwin and makes it **fully portable**, so you can:
  - move it to a different directory at any time
  - replicate it by copying its folder
  - rename the folder
  - run from USB or network drive
  - use it in folders with spaces
- Downloads and installs the latest portable ConEmu
- WSL support via WSLtty
- Only pure base with a couple of config files to make the installtion portable, no hacks with Cygwin/ConEmu code
- The installer is flexible, you can customize the installation process per your requirements
- You can add your own scripts to execute during installation/update (from URL or locally)
- Being portable, the script can also **upgrade** itself and its components
- Windows 7+ supported

## Installation

> **Optional:** Disable antivirus software on your PC during installation. [Why it is recommended](https://cygwin.com/faq/faq.html#faq.using.bloda)

- Download the [latest ConCygSys release](../../releases), extract the archive and go to the extracted folder

> **Optional:** Edit **`ConCygSys-installer.cmd`** to [customize](#customization) the installation per your requirements

- Launch **`ConCygSys-installer.cmd`**

> If Windows complains with a **Windows protected your PC** popup, you may need to click **Run anyway** to proceed with the installation.

- Once the installation is finished, use **`Launch-*.cmd`** to run Cygwin/WSL.

## Usage

Default behaviour of Cygwin console:

- **Select by Left Click and release** - copy
- **Right click** - paste

Shortcuts if using Cygwin via ConEmu console:

- **Ctrl+\`** - open/hide console (quake style)
- **Double click on Tab** - rename a tab
- **Double click on Tab Panel** - open a new tab
- **Win+X** - open a new tab with standard Windows console

## Update

Use **`update.cmd`** launcher in the root of your ConCygSys directory to update the installation.

You will be able either to update **Cygwin only** or to perform a **full update**: Cygwin + ConCygSys core making the installation protable. ConEmu is already set to check its updates on startup and can update itself independently.

> If you cannot find **`update`** launcher or something goes wrong:
> - Download [**`ConCygSys-installer.cmd`**](../../raw/master/ConCygSys-installer.cmd) *(right click > save link as)* to existing ConCygSys directory
> - Launch **`ConCygSys-installer.cmd`**

## Customization

Open **`ConCygSys-installer.cmd`** with text editor on your PC before installation to get a control over the installation process. Available options will be in **SCRIPT SETTINGS** section. All settings are accompanied with description.

[List of options](ConCygSys-installer.cmd#L11-L78)

After the installation, in order to change settings / add components, edit **:cygwinsettings** and **:installoptions** sections of **`update.cmd`** launcher (Right click > Edit).

[Cygwin extras collection](https://github.com/zhubanRuban/cygwin-extras)

## FAQ

### How much disk space does it take after installation?

If installed with default settings: `205M` zip: `70.3M` 7z: `40.3M`

### What is the path to Windows drives when I'm in Cygwin console?

`/cygdrive/DRIVE`

BTW, different Windows files are symlinked in Cygwin environment. For instance, `/etc/hosts` file in Cygwin is linked to `%WINDIR%\System32\drivers\etc\hosts`. If you go to `/proc/registry` folder, you will see Windows registry structure. Many Windows programs can be executed from Cygwin as well, for instance:

`ipconfig /flushdns` - to flush your local DNS cache
`cygstart "notepad"` - open Windows Notepad

### Сan I install a package from command line?

If you've chosen to install `apt-cyg` *(enabled by default in installer)*, you can istall packages from command line, for instance:

```
apt-cyg install nano
```

[More info about apt-cyg usage](https://github.com/transcode-open/apt-cyg) | [Available packages](https://cygwin.com/packages/package_list.html)

### I cannot find a desired package in Cygwin repository, what should I do?

This can happen. Fortunately, the packages can still be built from source.
Below are some examples for the reference:

[MTR](https://github.com/traviscross/mtr) | [ipmitool](https://stackoverflow.com/questions/12907005/ipmitool-for-windows)

Pre-built packages:

[MTR](https://github.com/zhubanRuban/mtr-mobaxterm-plugin-cygwin) | [ipmitool](https://github.com/zhubanRuban/ipmitool-mobaxterm-plugin-cygwin)

### Can I use this installation for organisation?

- change `CYGWIN_HOME` to `/%%H/SOMEFOLDER` in **`ConCygSys-installer.cmd`** (% must be escaped)
- install with admin rights to shared location, like C:\Program Files\cygwin

In this example every user who launched Cygwin will have own home folder in C:\Users\USER\SOMEFOLDER

For existing installation you can change home folder in [/etc/nsswitch.conf](https://cygwin.com/cygwin-ug-net/ntsec.html#ntsec-mapping-nsswitch-home). % sign does not need to be escaped in this case.

### How to check ConCygSys version?

The version can be found at the beginning of:
- README.txt file
- any launcher file

### Where can I report an issue or get a support?

[![GitHub issues](https://img.shields.io/github/issues-raw/zhubanRuban/cygwin-portable?style=flat-square) ![GitHub closed issues](https://img.shields.io/github/issues-closed-raw/zhubanRuban/cygwin-portable?style=flat-square) ![Contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](../../issues)
