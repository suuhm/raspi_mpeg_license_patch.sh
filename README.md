# raspi_mpeg_patch-companion.sh
Simple helper script and PoC to patch forgotten mpeg2 &amp; and vc codecs on raspberry pi

### BASED AS SHELL Proof of Conecpt and HELPER ON:
https://github.com/nucular/raspi-keygen


#### Testet on libreelec 9x & raspbian (Rpi1 -3)
#### Functions:
- ```--check-only``` Only checking if yet patched
- ```--patch-now``` To Patch the system
- ```--reset-to-original``` Reset the start.elf to original state

On Raspian and other OS you have to replace ```START_ELF=/flash/start.elf``` with ```START_ELF=/boot/start.elf``` or something else keep in mind some directories can be variable!


## !!!! IMPORTANT NOTE !!!!
### PLEASE BUY THE LICENSES - THIS SCRIPT IS JUST FOR RECOVER CASES!!!

#### SEE MORE:
https://codecs.raspberrypi.org/mpeg-2-license-key/
