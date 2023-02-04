#!/usr/bin/env bash

# sed 's/.ovpn//g' |
greenEcho() {
    echo -e "\e[32m$1\e[0m"
}
yellowEcho() {
    echo -e "\e[33m$1\e[0m"
}
redEcho() {
    echo -e "\e[31m$1\e[0m"
}

deletePlaceHolder() {
    return 0
    if [[ -f $HOME/.local/share/vpnHelper/vpnHelper-placeholder.conf ]]; then
        rm -rf $HOME/.local/share/vpnHelper/vpnHelper-placeholder.conf
    fi
}

createPlaceHolder() {
    if [[ ! -f $HOME/.local/share/vpnHelper/vpnHelper-placeholder.conf ]]; then
        touch $HOME/.local/share/vpnHelper/vpnHelper-placeholder.conf
    fi
}

validateVpnName() {
    vpnName=$1
    vpn=$2
    option=$3

    if [ "$option" == "exists" ]; then
        if grep -q "$vpn=" $HOME/.local/share/vpnHelper/vpnHelper.conf; then
            return 0
        else
            return 1
        fi
    elif [ "$option" == "rename" ]; then
        if grep -q "=$vpnName" $HOME/.local/share/vpnHelper/vpnHelper.conf; then
            return 0
        else
            return 1
        fi
    fi
}

setupVpn() {
    setupOption=$1
    vpns=$(find . -maxdepth 2 -type f -name "*.ovpn" -exec basename {} \; | sed 's/.ovpn//g')

    if [ -z "$vpns" ]; then
        redEcho "No VPNs found in the vpn directory!"
        createPlaceHolder
        exit
    fi

    if [ "$setupOption" == "all" ]; then
        read -p "Do you wish to rename the VPNs? (y/n) " rename
        if [ "$rename" == "y" ]; then
            for vpn in $vpns; do
                if validateVpnName $vpn $name "exists"; then
                    redEcho "A custom name for $vpn already exists! Do you wish to overwrite it? (y/n)" overwrite
                    if [ "$overwrite" == "n" ]; then
                        continue
                    fi
                fi

                read -p "Enter a name for $vpn: " name

                if [ -z "$name" ]; then
                    redEcho "Name cannot be empty!"
                    continue
                fi

                if validateVpnName $name; then
                    redEcho "A VPN with the name $name already exists! Do you wish to overwrite it? (y/n)" overwrite
                    if [ "$overwrite" == "n" ]; then
                        continue
                    fi
                    sed -i "/$name/d" $HOME/.local/share/vpnHelper/vpnHelper.conf
                else
                    echo "$vpn=$name" >>$HOME/.local/share/vpnHelper/vpnHelper.conf

                fi

            done

        else
            for vpn in $vpns; do
                echo "$vpn=$vpn" >>$HOME/.local/share/vpnHelper/vpnHelper.conf
            done
        fi
    elif [ "$setupOption" == "single" ]; then
        echo "Setup a single VPN"
    fi
}

manageVpn() {
    select opt in "Setup all VPNs" "Setup a single VPN" "Quit"; do
        case $opt in
        "Setup all VPNs")
            setup="all"
            deletePlaceHolder
            break
            ;;
        "Setup a single VPN")
            setup="single"
            deletePlaceHolder
            break
            ;;
        "Quit")
            echo "We're done"
            exit
            ;;
        *)
            echo "Invalid option"
            ;;
        esac
    done
}

createConfigFile() {
    if [[ -f $HOME/.local/share/vpnHelper/vpnHelper.conf && ! -f $HOME/.local/share/vpnHelper/vpnHelper-placeholder.conf ]]; then
        sed -i 's/first_run=true/first_run=false/g' $HOME/.local/share/vpnHelper/vpnHelper.conf
        exit
    fi

    if [[ -f $HOME/.local/share/vpnHelper/vpnHelper-placeholder.conf ]]; then
        return 0
    fi

    mkdir $HOME/.local/share/vpnHelper
    touch $HOME/.local/share/vpnHelper/vpnHelper.conf
    touch $HOME/.local/share/vpnHelper/vpnHelper-placeholder.conf
    echo "first_run=true" >>$HOME/.local/share/vpnHelper/vpnHelper.conf
}

createConfigFile
first_run=$(grep -oP '(?<=first_run=).+' $HOME/.local/share/vpnHelper/vpnHelper.conf)

if [ "$first_run" == "true" ]; then
    yellowEcho "Welcome to vpnHelper!"
    yellowEcho "Please select one of the following options:"

    manageVpn

    setupVpn $setup

fi
