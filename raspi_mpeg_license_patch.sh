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

function _get_tools() {
        echo "* Getting some necessary tools, maybe this take some time..."
        mkdir -p /storage/sr-tools
        find / | grep -i -E "bin/xxd$|bin/perl$" | xargs -I Z cp Z /storage/sr-tools
        PATH=$PATH:/storage/sr-tools
        #ln -s /storage/{xxd,perl} /storage/.kodi/addons/service.ttyd/bin/
        #cp -ra /var/media/root/usr/bin/{xxd,perl}/storage/
}

function _check4patched() {
        _get_tools
        echo "* First check mpeg2/vc activated?"
        vcgencmd codec_enabled MPG2
        vcgencmd codec_enabled WVC1
        sleep 3 && echo

        echo
        echo "* Getting Hexstring... May take some time..."
        echo
        HS=$(xxd $START_ELF | grep -i "47 *E9 *33 *36 *32 *48" | sed -re 's/.*47\ *e9\ *33\ *36\ *32\ *48\ (..)(18|1f)\ .*/\1/')
        HT=$(xxd $START_ELF | grep -i "47 *E9 *33 *36 *32 *48" | sed -re "s/.*47\ *e9\ *33\ *36\ *32\ *48\ $HS(..)\ .*/\1/")

        if [[ ! "$1" == "--check-only" ]]; then
                if [[ $HT == "1f" ]]; then
                        echo "* Already Patched"
                        sleep 4 && exit 0;
                else
                        echo "* Not patched continue..."
                        sleep 2
                fi
        else
                if [[ $HT == "1f" ]]; then
                        echo "* Already Patched"
                else
                        echo "* Not patched!"
                        sleep 2
                fi  
        fi
}

function _get_startelf() {
        if [[ -f /boot/start.elf && "$2" == "--os=raspian" ]]; then
                # On Raspian:
                START_ELF=/boot/start.elf
        elif [[ -f /flash/start.elf && "$2" == "--os=libreelec" ]]; then
                # On libreElec:
                START_ELF=/flash/start.elf
                _get_tools
        elif [[ -f /boot/start_x.elf && "$2" == "--os=osmc" ]]; then
                # On OSMC:
                START_ELF=/boot/start_x.elf
                _get_tools
        elif [[ -f /boot/start.elf && "$2" == "--os=xbian" ]]; then
                # On Xbian
                START_ELF=/boot/start.elf
                _get_tools
        else
                echo "START.ELF not found searching possible file:"
                find / | grep -i -E "start.*.elf"
                echo -e "\nPlease enter the full Path to the START.ELF: "
                read START_ELF
                _get_tools
        fi
}

echo "   ___________________________________________________ "
echo "  |---------------------------------------------------|"
echo "  | raspi_mpeg_license_patch v0.3b - (c)2021 suuhm    |"
echo "  |___________________________________________________|"
echo "                                                       "

if [[ "$1" == "--check-only" ]]; then
        _get_startelf
        _check4patched
        echo -e "\n\n* Check state xxd.."
        xxd $START_ELF | grep -i -B 1 -A 1 "47 *E9 *33 *36 *32 *48"
        echo ""
        echo "* get GPUtemp every 5 secs..."
        while true; do gputemp; sleep 5; done
        # bcmstat.sh d 23
        exit 0
        
elif [[ "$1" == "--patch-now" ]]; then
        _get_startelf
        _check4patched
        mount -o remount,rw /flash
        # nano /flash/config.txt
        # decode_MPG2=0xa7fc0fff
        # decode_WVC1=0x6d1feeff
        # decode_DTS=0x00000000
        # decode_DDP=0x00000000
        echo "* set up patch now..."
        #cd /boot
        cp -a $START_ELF $START_ELF.BACKUP
        perl -pne "s/\x47\xE9362H\x$HS\x18/\x47\xE9362H\x$HS\x1F/g" < $START_ELF.BACKUP > $START_ELF

        echo "* Finished. success"
        echo "New md5sum: $(md5sum $START_ELF)"
        echo "Old md5sum: $(md5sum $START_ELF.BACKUP)"
        echo ""
        echo "* Now, pls restart your device and check again."
        
elif [[ "$1" == "--reset-to-original" ]]; then
        _get_startelf
        _check4patched
        mount -o remount,rw /flash
        echo "* Reset now..."
        if [[ -e $START_ELF.BACKUP ]]; then
                echo "* Take old file.. $START_ELF.BACKUP"
                cp -a $START_ELF.BACKUP $START_ELF
        else
                echo "* Patching Back"
                cp -a $START_ELF $START_ELF.PATCHED
                perl -pne "s/\x47\xE9362H\x$HS\x1F/\x47\xE9362H\x$HS\x18/g" < $START_ELF.PATCHED > $START_ELF
        fi

        echo "* Finished. success"
        echo "New original md5sum: $(md5sum $START_ELF)"
        echo "Old Patched File md5sum: $(md5sum $START_ELF.PATCHED)"
        echo
        echo "* Now, pls restart your device and check again."

else 
        echo ; echo "* No Arguments set: $0 [--check-only | --patch-now | --reset-to-original] [--os=<raspian|libreelec|osmc|xbian>]"
        exit 1
fi

exit 0
