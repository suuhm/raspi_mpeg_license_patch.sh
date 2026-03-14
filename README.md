# raspi_mpeg_license_patch.sh
Simple hack & proof of concept script to activate (forgotten) mpeg2 and VC codec licenses on raspberry pi 

[![Join Discord](https://img.shields.io/badge/Discord-Join%20Server-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/2tRn7GWTRm)
[![Stars](https://img.shields.io/github/stars/suuhm/raspi_mpeg_license_patch.sh?color=gold&style=for-the-badge&logo=github)](https://github.com/suuhm/raspi_mpeg_license_patch.sh)
[![Forks](https://img.shields.io/github/forks/suuhm/raspi_mpeg_license_patch.sh?color=silver&style=for-the-badge&logo=github)](https://github.com/suuhm/raspi_mpeg_license_patch.sh/network)
[![Issues](https://img.shields.io/github/issues/suuhm/raspi_mpeg_license_patch.sh?color=red&style=for-the-badge&logo=github)](https://github.com/suuhm/raspi_mpeg_license_patch.sh/issues)
[![PRs](https://img.shields.io/github/issues-pr/suuhm/raspi_mpeg_license_patch.sh?color=orange&style=for-the-badge&logo=github)](https://github.com/suuhm/raspi_mpeg_license_patch.sh/pulls)

### BASED AS SHELL Proof of Concept and HELPER ON:
https://github.com/nucular/raspi-keygen

<br/>

## How to run the script:
Simply run this one-liner: 
```
wget https://raw.githubusercontent.com/suuhm/raspi_mpeg_license_patch.sh/main/raspi_mpeg_license_patch.sh -qO- | bash -s -- --patch-now
```
<br/>

You can also easily patch/check with the additional ```--os=<raspbian|libreelec|osmc|xbian>``` parameters if you want to specificate your Raspi-Enviroment.
#### For Example, if you want to patch libreElec:
```raspi_mpeg_license_patch.sh --patch-now --os=libreelec```
<br/>
and reboot your Raspi.

<br/>
<hr>

## Tested on libreelec 9x & raspbian and OSMC (Rpi1 -3)
#### Functions:
- ```--check-only``` Only checking if yet patched
- ```--patch-now``` To Patch the system
- ```--reset-to-original``` Reset the start.elf to original state
- Autodetect of start.elf file in your system

(On Raspbian and other OS you have to replace ```START_ELF=/flash/start.elf``` with ```START_ELF=/boot/start.elf``` or something else keep in mind some directories can be variable!)

<br/>
<hr>

## !!!! IMPORTANT NOTE !!!!
### PLEASE BUY THE LICENSES - THIS SCRIPT IS JUST FOR RECOVER CASES!!!

### I don't take responsibility for any damages, you have to do your backup before!

#### SEE MORE:
https://codecs.raspberrypi.org/mpeg-2-license-key/
