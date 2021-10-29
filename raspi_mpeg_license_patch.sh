#!/bin/bash
#
# BASED AS SHELL PoC and HELPER ON:
# https://github.com/nucular/raspi-keygen
#
# !!!! IMPORTANT NOTE !!!!
# PLEASE BUY THE LICENSES - THIS IS JUST FOR RECOVER CASES!!!
#
# Tested on libreelec 9x & raspbian (Rpi1 -3)
#
# SEE MORE:
# https://codecs.raspberrypi.org/mpeg-2-license-key/
#
# Setting up here the wished replacing Hexstring
# On older Raspberry FW use this string here: 0x3C
#HS=3C
HS=1D #> 0x1d

# On Raspian uncomment this line:
#START_ELF=/boot/start.elf
# On libreElec uncomment this line:
START_ELF=/flash/start.elf

echo "___________________________________________________"
echo ""
echo "-- raspi_mpeg_license_patch v0.2 - (c)2021 suuhm --"
echo "___________________________________________________"
echo

echo "* First check mpeg2/vc activated?"
vcgencmd codec_enabled MPG2
vcgencmd codec_enabled WVC1
sleep 3 && echo
echo "* Getting some necessary tools.."
cp /var/media/root/usr/bin/xxd /storage/
cp /var/media/root/usr/bin/perl /storage/

echo
echo "* Getting Hexstring... May take some time..."
echo
HS=$(/storage/xxd /flash/start.elf | grep -i "47E9 3336 3248" | sed -re 's/.*47e9\ 3336\ 3248\ (..)(18|1f)\ .*/\1/')
HT=$(/storage/xxd /flash/start.elf | grep -i "47E9 3336 3248" | sed -re "s/.*47e9\ 3336\ 3248\ $HS(..)\ .*/\1/")

if [[ $HT == "1f" ]]; then
        echo "* Already Patched"
else
        echo "* Not patched continue..."
        sleep 2
fi

if [[ "$1" == "--check-only" ]]; then
        echo -e "\n* Check state xxd.."
        /storage/xxd $START_ELF | grep -i -B 1 -A 1 "47E9 3336 3248"
        echo
        echo "* get GPUtemp every 5 secs..."
        while true; do gputemp; sleep 5; done
        # bcmstat.sh d 23
        exit 0
        
elif [[ "$1" == "--patch-now" ]]; then
        mount -o remount,rw /flash
        # nano /flash/config.txt
        # decode_MPG2=0xa7fc0fff
        # decode_WVC1=0x6d1feeff
        # decode_DTS=0x00000000
        # decode_DDP=0x00000000
        echo "* set up patch now..."
        #cd /boot
        cp -a $START_ELF $START_ELF.BACKUP
        /storage/perl -pne "s/\x47\xE9362H\x$HS\x18/\x47\xE9362H\x$HS\x1F/g" < $START_ELF.BACKUP > $START_ELF

        echo "* Finished. success"
        echo "New md5sum: $(md5sum $START_ELF)"
        echo "Old md5sum: $(md5sum $START_ELF.BACKUP)"
        echo
        echo "* Now, pls restart your device and check again."
        
elif [[ "$1" == "--reset-to-original" ]]; then
        mount -o remount,rw /flash
        echo "* Reset now..."
        if [[ -e $START_ELF.BACKUP ]]; then
                echo "* Take old file.. $START_ELF.BACKUP"
                cp -a $START_ELF.BACKUP $START_ELF
        else
                echo "* Patching Back"
                cp -a $START_ELF $START_ELF.PATCHED
                /storage/perl -pne "s/\x47\xE9362H\x$HS\x1F/\x47\xE9362H\x$HS\x18/g" < $START_ELF.PATCHED > $START_ELF
        fi

        echo "* Finished. success"
        echo "New original md5sum: $(md5sum $START_ELF)"
        echo "Old Patched File md5sum: $(md5sum $START_ELF.PATCHED)"
        echo
        echo "* Now, pls restart your device and check again."

else 
        echo ; echo "* No Arguments set: $0 [--check-only | --patch-now | --reset-to-original]"
        exit 1
fi

exit 0
