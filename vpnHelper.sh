#!/usr/bin/env bash

vpnPath="vpn"

checkVpnDir() {
    if [ -n "$(find vpn -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
        echo "VPN directory is empty"
        exit
    fi

    #check for .ovpn files
    if [ -n "$(find vpn -maxdepth 1 -type f -name '*.ovpn' 2>/dev/null)" ]; then
        return
    else
        echo "VPN directory does not contain .ovpn files"
        exit
    fi
}

setupConfig() {
    openvpn3 config-import --c $2 --name $1
}

createConfigFile() {
    if [ ! -f "user.settings" ]; then
        touch user.settings
    fi
}

readConfigFile() {
    while IFS= read -r line; do
        echo "$line"
    done <user.settings
}

storeName() {
    vpnName=$1
    vpnPath=$2

    name="$vpnName=$vpnPath"

    if [ -n "$(grep $vpnName user.settings)" ]; then
        return
    fi

    echo $name >>user.settings
}

changeName() {
    oldName=$1
    newName=$2

    echo "Changing $oldName to $newName"
    sed -i "0,/$oldName/s/$oldName/$newName/" user.settings
}

readDir() {
    vpnPath=$1

    for file in $vpnPath/*.ovpn; do
        vpnName=$(basename $file .ovpn)
        storeName $vpnName "$(pwd)/$vpnPath/$vpnName.ovpn"
    done
}

vpnService() {
    vpnName=$1
    vpnAction=$2

    case $vpnAction in
    "connect")
        openvpn3 session-start -c $vpnName
        ;;
    "disconnect")
        openvpn3 session-manage -c $vpnName -D
        ;;
    "list")
        openvpn3 sessions-list
        ;;
    "status")
        openvpn3 session-stats -c $vpnName
        ;;
    *)
        echo "Invalid action"
        ;;
    esac

}

menu() {
    vpn=$1
    PS3="Select an option: "
    select opt in Connect Disconnect List Status Quit; do
        case $opt in
        "Connect")
            vpnService $vpn "connect"
            break
            ;;
        "Disconnect")
            vpnService $vpn "disconnect"
            break
            ;;
        "List")
            vpnService $vpn "list"
            break
            ;;
        "Status")
            vpnService $vpn "status"
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

if [ "$1" == "--setup" ]; then
    createConfigFile

    checkVpnDir

    readDir $vpnPath

    vpns=$(readConfigFile)

    read -p "Do you want to name your VPNs? (y/n): " nameVpns

    if [[ $nameVpns == "y" || $nameVpns == "Y" ]]; then
        for vpn in $vpns; do
            vpnName=$(echo $vpn | cut -d "=" -f1)
            vpnPath=$(echo $vpn | cut -d "=" -f2)

            read -p "Enter a name for $vpnName: " name

            changeName $vpnName $name
        done
    fi

    for vpn in $vpns; do
        vpnName=$(echo $vpn | cut -d "=" -f1)
        vpnPath=$(echo $vpn | cut -d "=" -f2)

        setupConfig $vpnName $vpnPath
    done
fi

checkVpnDir

PS3="Select a VPN: "

vpnNames=$(cut -d "=" -f1 user.settings)

select vpnOpt in $vpnNames; do
    case $vpnOpt in
    *)
        menu $vpnOpt
        break
        ;;
    esac
done
