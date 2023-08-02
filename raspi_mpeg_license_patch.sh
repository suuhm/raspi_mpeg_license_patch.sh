#!/bin/bash
#
# raspi_mpeg_license_patch v0.4.2b - (c) 2023 suuhm 
#
# Changelog: 27.02.2023
#
# [*] Fixed some output bugs with hexdump/xxd
# [*] Find / error handling performance fixes
# [*] Some other performance updates
#
# Changelog: 27.02.2023
#
# [+] Added: check4tools function for better performance
# [+] Added: hexdump function for better grepping of hexstrings
# [*] Modified Logo banner screen.
# [*] Modified some bugfixes.
#
# Force Checking with hexdump and/or patching with sed:
# sed "s/command -v xxd/command -v xxd-false/g" -i raspi_mpeg_license_patch.sh
# sed "s/command -v perl/command -v perl-false/g" -i raspi_mpeg_license_patch.sh
# ---
# sed "s/command -v xxd-false/command -v xxd/g" -i raspi_mpeg_license_patch.sh
# sed "s/command -v perl/command -v perl-false/g" -i raspi_mpeg_license_patch.sh
#
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

function _get_startelf() {
        if [[ -f /boot/start.elf && "$2" == "--os=raspbian" ]]; then
                # On Raspbian:
                START_ELF=/boot/start.elf
        elif [[ -f /flash/start.elf && "$2" == "--os=libreelec" ]]; then
                # On libreElec:
                START_ELF=/flash/start.elf
                _check4tools
        elif [[ -f /boot/start_x.elf && "$2" == "--os=osmc" ]]; then
                # On OSMC:
                START_ELF=/boot/start_x.elf
                _check4tools
        elif [[ -f /boot/start.elf && "$2" == "--os=xbian" ]]; then
                # On Xbian
                START_ELF=/boot/start.elf
                _check4tools
        else
                echo "START.ELF not found. Searching for possible files:"
                echo -e "---------------------------------------------\n"
                find / 2>&1 | grep -i -E "start.*.elf"
                TSTARTELF=$(find / 2>&1 | grep -i -E "start.*.elf" | head)
                echo -e "\n---------------------------------------------"
                echo -en "\nPlease enter the full Path to the START.ELF [$TSTARTELF]: "
                read START_ELF
                if [ -z $START_ELF ]; then
                        START_ELF=$TSTARTELF
                fi
                echo; _check4tools
        fi
}

function _check4tools() {
        echo "[*] Checking for necessary tools, maybe this take some time..."
        #not yet needable for export bin-path:
        #mkdir -p /storage/sr-tools
        #export PATH=$PATH:/storage/sr-tools
        TM=0

        if [[ ! $(command -v xxd) ]] && [[ ! $(command -v hexdump) ]]; then
                echo "xxd / hexdump not found; try to get it from disk..."
                TM=1
        fi

        if [[ ! $(command -v perl) ]] && [[ ! $(command -v sed) ]]; then
                echo "perl / sed not found; try to get it from disk..."
                TM=1
        fi

        if [[ $TM -gt 0 ]]; then
                _get_tools
        else
                echo -e "\n[*] Found tools, continue."
        fi
}

function _get_tools() {
        echo "[*] Getting some necessary tools, maybe this take some time..."
        echo; sleep 1
        mkdir -p /storage/sr-tools
        export PATH=$PATH:/storage/sr-tools

        if [[ $(command -v xxd) ]] && [[ $(command -v perl) ]]; then
                echo "Tools already just here, continue..."
                return 1
        fi

        # checking full ssd/sd/hdd for [s]bin directories and binaries
        find / 2>&1 | grep -i -E "bin/xxd$|bin/hexdump$|bin/sed$|bin/perl$" | xargs -I Z cp Z /storage/sr-tools

        if [[ ! $(command -v xxd) ]] && [[ ! $(command -v hexdump) ]]; then
                echo "xxd / hexdump not found, but not neccessary for patching only.."
        fi

        if [[ ! $(command -v perl) ]] && [[ ! $(command -v sed) ]]; then
                echo "perl / sed not found, but not neccessary for checking only.."
        fi
        #ln -s /storage/{xxd,perl} /storage/.kodi/addons/service.ttyd/bin/
        #cp -ra /var/media/root/usr/bin/{xxd,perl}/storage/
}

function _check4patched() {
        #_get_tools
        echo -e "\n[*] First check mpeg2/vc activated?"
        echo; sleep 2
        vcgencmd codec_enabled MPG2
        vcgencmd codec_enabled WVC1
        sleep 3 && echo

        echo "[+] Getting Hexstring... May take some time..."
        echo
        if [[ $(command -v xxd) ]]; then
                echo "[*] Using xxd"
                HS=$(xxd -c 128 $START_ELF | grep -Ei "47 *E9 *3(3|4) *36 *32 *48 *(3C|1D) *(18|1F)" | sed -re 's/.*47\ *e9\ *3(3|4)\ *36\ *32\ *48\ (1d|3c)(18|1f)\ .*/\2/')
                HS_MODE=$(xxd -c 128 $START_ELF | grep -Ei "47 *E9 *3(3|4) *36 *32 *48 *(3C|1D) *(18|1F)" | sed -re 's/.*47\ *e9\ *3(3|4)\ *36\ *32\ *48\ (1d|3c)(18|1f)\ .*/\1/')
                HT=$(xxd -c 128 $START_ELF | grep -Ei "47 *E9 *3(3|4) *36 *32 *48 *(3C|1D) *(18|1F)" | sed -re "s/.*47\ *e9\ *3(3|4)\ *36\ *32\ *48\ *$HS(..)\ .*/\2/")
        elif [[ $(command -v hexdump) ]]; then
                echo "[*] Using hexdump (beta)"
                # hexdump -v -e '6/2 "0x%x - ""\n"'
                # Old hexdump HS-search
                # hexdump -s 751391 -C $START_ELF | grep -Ei "$REGEX2"
                REGEX2=".*47\ *e9\ *3(3|4)\ *36\ *32\ *48\ *(1d|3c)\ *(18|1f)\ .*"
                RUN_HEXDMP="hexdump -s 75139 -ve '1/1 \"%.2x \"' ${START_ELF}"
                HS=$(eval $RUN_HEXDMP | grep -Eio "$REGEX2" | sed -re "s/$REGEX2/\2/")
                HS_MODE=$(eval $RUN_HEXDMP | sed -re "s/$REGEX2/\1/")
                HT=$(eval $RUN_HEXDMP | grep -Eio "$REGEX2" | sed -re "s/.*47\ *e9\ *3(3|4)\ *36\ *32\ *48\ *$HS\ *(..)\ .*/\2/")
        else
                echo "xxd / hexdump not found, trying to patch with 0x1D ? "
                echo -n "If unsure please install xxd and stop now. continue? (y/n) [n/N]: "
                read yn
                if [[ $yn != "y" && $yn != "yes" ]]; then
                        exit 1;
                fi
        fi

        if [[ "$1" != "--check-only" && "$1" != "--reset-to-original" ]]; then
                if [[ "$HT" == "1f" ]]; then
                        echo "[~] Already Patched (0x$HT)"
                        sleep 4 && exit 0;
                else
                        echo "[!] Not patched (0x$HT) continue..."
                        sleep 2
                fi
        else
                if [[ "$HT" == "1f" ]]; then
                        echo "[~] Already Patched (0x$HT)"
                else
                        echo "[!] Not patched! (0x$HT)"
                        sleep 2
                fi
        fi
}

#
# MAIN ZONE
#
echo "     _________________________________________________________ "
echo "    |><><><><><><><><><><><><><><><><><><><><><><><><><><><><>|"
echo "    |                                                         |"
echo "    |  raspi_mpeg_license_patch v0.4.2b - (c) 2023 suuhm      |"
echo "    |                                                         |"
echo "    |  !!! IMPORTANT NOTE !!!                                 |"
echo "    |  PLEASE BUY THE LICENSES!                               |"
echo "    |  THIS SCRIPT IS JUST FOR RECOVER CASES!                 |"
echo "    |_________________________________________________________|"
echo "                                                               "
echo; sleep 2

#if [[ $2 && "$2" =~ \-\-\o\s\=[a-z]*$ ]]; then
#unknown =~ Regex operator in BusyBox v1.31.0 bash? ash-shell /
if [[ $2 ]]; then
        _OS=$2
        _COM=$1
fi

if [[ "$1" == "--check-only" ]]; then
        _get_startelf $_COM $_OS
        _check4patched $1
        echo -e "\n[~] Check state HEX location +/- 1 line:"
        if [[ $(command -v xxd) ]]; then
                xxd -c 128 $START_ELF | grep -Ei -B 1 -A 1 "47 *E9 *3(3|4) *36 *32 *48 *(3C|1D) *(18|1F)"
        else
                REGEXD="0x47\ 0xe9\ 0x3(3|4)\ 0x36\ 0x32\ 0x48\ 0x(1d|3c)\ 0x(18|1f)"
                echo -e "\nHexdump Patchline => $(hexdump -s 75138 -e '1/1 "0x%.2x "' $START_ELF | grep -Eio "$REGEXD" | sed -r "s/.*($REGEXD).*/\1/")\n"
        fi
        
        echo -en "\n[?] Want you show some GPU temperature stats? (y/n) [n/N]: "
        read yn
        if [[ $yn != "y" && $yn != "yes" ]]; then
                exit 1;
        else
                echo "* get GPUtemp every 5 secs... (STOP with Ctrl+C)"
                while true; do gputemp; sleep 5; done
                # libreelec some more stats pls uncomment here:
                # bcmstat.sh d 23
                exit 0
        fi

elif [[ "$1" == "--patch-now" ]]; then
        _get_startelf $_COM $_OS
        _check4patched $1
        mount -o remount,rw $(dirname $START_ELF)
        # nano /flash/config.txt
        # decode_MPG2=0xa7fc0fff
        # decode_WVC1=0x6d1feeff
        # decode_DTS=0x00000000
        # decode_DDP=0x00000000
        HS=$(echo $HS | awk '{print toupper($0)}')
        # tolower
        # Or: HS=$(echo $HS | tr [:lower:] [:upper:])
        echo -e "\n[*] Start Patching ($HS) ..."

        if [[ ! $(command -v perl) ]] && [[ ! $(command -v sed) ]]; then
                echo "perl/ sed  not found, exit"
                exit 1
        fi
        cp -a $START_ELF $START_ELF.BACKUP
        
        # 0x33 Patch
        if [ $HS_MODE -eq 3 ]; then
                echo "[~] Using legacy patch (HS_MODE: $HS_MODE)"
                if [[ $(command -v perl) ]]; then
                        perl -pne "s/\x47\xE9362H\x$HS\x18/\x47\xE9362H\x$HS\x1F/g" < $START_ELF.BACKUP > $START_ELF
                else
                        # sed - Escape: \x5c
                        # ANSI-C Quoting
                        echo -e "\n[!] perl not found - using sed:"
                        eval sed "\$'s/\x47\xe9\x33\x36\x32\x48\x$HS\x18/\x47\xe9\x33\x36\x32\x48\x$HS\x1f/g'" $START_ELF.BACKUP > $START_ELF
                fi
                
        # 0x34 Patch
        elif [ $HS_MODE -eq 4 ]; then
                echo "[~] Using > 2022 patch (HS_MODE: $HS_MODE)"
                if [[ $(command -v perl) ]]; then
                        perl -pne "s/\x47\xE9\x3462H\x$HS\x18/\x47\xE9\x3462H\x$HS\x1F/g" < $START_ELF.BACKUP > $START_ELF
                else
                        echo -e "\n[!] perl not found - using sed:"
                        eval sed "\$'s/\x47\xe9\x34\x36\x32\x48\x$HS\x18/\x47\xe9\x34\x36\x32\x48\x$HS\x1f/g'" $START_ELF.BACKUP > $START_ELF
                fi
        else
                echo "[!] Something went wrong, exit now.." ; exit 3
        fi

        echo -e "\n*********************\n\a[*] Finished. success\n"
        echo "New md5sum: $(md5sum $START_ELF)"
        echo "Old md5sum: $(md5sum $START_ELF.BACKUP)"
        mount -o remount,ro $(dirname $START_ELF)
        sleep 2; echo
        echo -e "\n[!] Now, pls restart your device and check again.\n"
        echo -n "Restart now? continue? (y/n) : "
        read yn
        if [[ $yn != "y" && $yn != "yes" ]]; then
                exit 0;
        else
                reboot
        fi

elif [[ "$1" == "--reset-to-original" ]]; then
        _get_startelf $_COM $_OS
        _check4patched $1
        mount -o remount,rw $(dirname $START_ELF)
        echo -e "\n[*] Reset now..."

        if [[ ! $(command -v perl) ]] && [[ ! $(command -v sed) ]]; then
                echo "perl/ sed  not found, exit"
                exit 1
        fi
        if [[ -e $START_ELF.BACKUP ]]; then
                echo -e "\n[*] Found old Backup start.elf file.. $START_ELF.BACKUP" ; sleep 2
                cp -a $START_ELF $START_ELF.PATCHED
                cp -a $START_ELF.BACKUP $START_ELF
        else
                echo -e "\n[!] Backup files not found. Need for patching Back" ; sleep 2
                cp -a $START_ELF $START_ELF.PATCHED
                
                # 0x33 Patch
                if [ $HS_MODE -eq 3 ]; then
                        echo "[~] Using old patch ($HS_MODE) -> legacy"
                        if [[ $(command -v perl) ]]; then
                                perl -pne "s/\x47\xE9362H\x$HS\x1F/\x47\xE9362H\x$HS\x18/g" < $START_ELF.BACKUP > $START_ELF
                        else
                                # sed - Escape: \x5c
                                # ANSI-C Quoting
                                echo -e "\n[!] perl not found - using sed:"
                                eval sed "\$'s/\x47\xe9\x33\x36\x32\x48\x$HS\x1f/\x47\xe9\x33\x36\x32\x48\x$HS\x18/g'" $START_ELF.BACKUP > $START_ELF
                        fi

                # 0x34 Patch
                elif [ $HS_MODE -eq 4 ]; then
                        echo "[~] Using > 2022 patch ($HS_MODE)"
                        if [[ ! $(command -v perl) ]]; then
                                perl -pne "s/\x47\xE9\x3462H\x$HS\x1F/\x47\xE9\x3462H\x$HS\x18/g" < $START_ELF.BACKUP > $START_ELF
                        else
                                echo -e "\n[!] perl not found - using sed:"
                                eval sed "\$'s/\x47\xe9\x34\x36\x32\x48\x$HS\x1f/\x47\xe9\x34\x36\x32\x48\x$HS\x18/g'" $START_ELF.BACKUP > $START_ELF
                        fi
                else
                        echo "[!] Something went wrong, exit now.." ; exit 3
                fi
        fi

        echo -e "\n*********************\n\a[*] Finished. success\n"
        echo "New original md5sum: $(md5sum $START_ELF)"
        echo "Old Patched File md5sum: $(md5sum $START_ELF.PATCHED)"

        mount -o remount,ro $(dirname $START_ELF)
        echo ; sleep 2
        echo "[!] Now, pls restart your device and check again."
        echo -n "Restart now? continue? (y/n) : "
        read yn
        if [[ $yn != "y" && $yn != "yes" ]]; then
                exit 0;
        else
                reboot
        fi
else
        echo -e "\n\a[!] No Arguments set: "
        echo -e "\n* Usage: $0 --check-only | --patch-now | --reset-to-original [--os=<raspbian|libreelec|osmc|xbian>]\n"
        exit 1
fi

exit 0
