# raspi_mpeg_patch-companion.sh
Simple hack & proof of concept script to activate forgotten mpeg2 & and vc codec licenses on raspberry pi 

### BASED AS SHELL Proof of Conecpt and HELPER ON:
https://github.com/nucular/raspi-keygen

<br/>

## How to run the script:
Simply run this one-liner: 
```
wget https://raw.githubusercontent.com/suuhm/raspi_mpeg_patch-companion.sh/main/raspi_mpeg_patch-companion.sh -qO- | bash -s -- --patch-now
```
and reboot your Raspi.

<br/>

## Tested on libreelec 9x & raspbian (Rpi1 -3)
#### Functions:
- ```--check-only``` Only checking if yet patched
- ```--patch-now``` To Patch the system
- ```--reset-to-original``` Reset the start.elf to original state

On Raspbian and other OS you have to replace ```START_ELF=/flash/start.elf``` with ```START_ELF=/boot/start.elf``` or something else keep in mind some directories can be variable!


## !!!! IMPORTANT NOTE !!!!
### PLEASE BUY THE LICENSES - THIS SCRIPT IS JUST FOR RECOVER CASES!!!

#### SEE MORE:
https://codecs.raspberrypi.org/mpeg-2-license-key/
