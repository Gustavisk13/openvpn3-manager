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

hasCustomVpnName() {
    vpn=$1
    if grep -q "$vpn=" $HOME/.local/share/vpnHelper/vpnHelper.conf; then
        return 0
    else
        return 1
    fi
}

manageVpnNames() {
    vpns=$1
    nameOption=$2

    if [ "$nameOption" == "all" ]; then
        read -p "Do you wish to rename all VPNs? (y/n) " rename
        if [[ "$rename" == "y" || "$rename" == "Y" ]]; then

            for vpn in $vpns; do
                if hasCustomVpnName $vpn; then
                    yellowEcho "VPN $vpn already has a custom name"
                    read -p "Do you wish to rename it? (y/n) " renameVpn
                    if [[ "$renameVpn" == "y" || "$renameVpn" == "Y" ]]; then
                        while true; do
                            read -p "Enter a new name for $vpn: " vpnName
                            validateVpnName $vpnName $vpn "rename"
                            if [ $? -eq 0 ]; then
                                redEcho "A VPN with the name $vpnName already exists!"
                            else
                                sed -i "s/$vpn=.*/$vpn=$vpnName/g" $HOME/.local/share/vpnHelper/vpnHelper.conf
                                break
                            fi
                        done
                    fi
                else
                    read -p "Enter a name for $vpn: " vpnName
                    while true; do
                        validateVpnName $vpnName $vpn "rename"
                        if [ $? -eq 0 ]; then
                            redEcho "A VPN with the name $vpnName already exists!"
                            read -p "Enter a new name for $vpn: " vpnName
                        else
                            break
                        fi
                    done
                    echo "$vpn=$vpnName" >>$HOME/.local/share/vpnHelper/vpnHelper.conf
                fi
            done

        else
            for vpn in $vpns; do
                echo "$vpn=$vpn" >>$HOME/.local/share/vpnHelper/vpnHelper.conf
            done
        fi
    elif [ "$nameOption" == "single" ]; then
        yellowEcho "Choose a VPN to rename:"
        select vpn in $vpns; do
            if hasCustomVpnName $vpn; then
                yellowEcho "VPN $vpn already has a custom name"
                read -p "Do you wish to rename it? (y/n) " renameVpn
                if [[ "$renameVpn" == "y" || "$renameVpn" == "Y" ]]; then
                    while true; do
                        read -p "Enter a new name for $vpn: " vpnName
                        validateVpnName $vpnName $vpn "rename"
                        if [ $? -eq 0 ]; then
                            redEcho "A VPN with the name $vpnName already exists!"
                        else
                            sed -i "s/$vpn=.*/$vpn=$vpnName/g" $HOME/.local/share/vpnHelper/vpnHelper.conf
                            break
                        fi
                    done
                fi
            else
                read -p "Enter a name for $vpn: " vpnName
                while true; do
                    validateVpnName $vpnName $vpn "rename"
                    if [ $? -eq 0 ]; then
                        redEcho "A VPN with the name $vpnName already exists!"
                        read -p "Enter a new name for $vpn: " vpnName
                    else
                        break
                    fi
                done
                echo "$vpn=$vpnName" >>$HOME/.local/share/vpnHelper/vpnHelper.conf
            fi
            break
        done

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

    case $setupOption in
    "rename")
        yellowEcho "You can rename your VPNs to make them easier to identify"

        select opt in "Rename all VPNs" "Rename a single VPN" "Skip configuration" "Return" "Quit"; do
            case $opt in
            "Rename all VPNs")
                manageVpnNames "$vpns" "all"
                break
                ;;
            "Rename a single VPN")
                manageVpnNames "$vpns" "single"
                break
                ;;
            "Skip configuration")
                for vpn in $vpns; do
                    echo "$vpn=$vpn" >>$HOME/.local/share/vpnHelper/vpnHelper.conf
                done
                break
                ;;
            "Return")
                manageVpn
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
        ;;

    esac
}

manageVpn() {
    select opt in "Rename VPNs" "Setup credentials" "Skip configuration" "Quit"; do
        case $opt in
        "Rename VPNs")
            setupVpn "rename"
            deletePlaceHolder
            break
            ;;
        "Setup credentials")
            setupVpn "credentials"
            deletePlaceHolder
            break
            ;;
        "Skip configuration")
            setupVpn "skip"
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
    yellowEcho "Do "

    manageVpn

fi
