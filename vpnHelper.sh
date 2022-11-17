#!/usr/bin/env bash

vpnPath="/home/gustavo/vpn/"

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

PS3="Select a VPN: "

select vpnOpt in PDC PNM Quit; do
    case $vpnOpt in
    "PDC")
        menu "PDC"

        break
        ;;
    "PNM")
        menu "PNM"

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

