#!/bin/bash

# Function to send a Wake-on-LAN magic packet
send_wol_packet() {
    mac_address=$1
    broadcast_address=$2

    # Create the magic packet
    magic_packet="ff:ff:ff:ff:ff:ff"
    for i in {1..16}; do
        magic_packet="${magic_packet}:${mac_address//:/}"
    done

    # Send the magic packet
    echo -n -e "\xff\xff\xff\xff\xff\xff${magic_packet}" | xxd -r -p | socat - UDP4-DATAGRAM:"$broadcast_address":9,broadcast
}

# Replace "00:11:22:33:44:55" with the MAC address of the device you want to wake up
mac_address="1c:87:2c:b1:6e:be"

# Replace "192.168.1.255" with the broadcast address of your network
broadcast_address="192.168.1.255"

# Send the Wake-on-LAN packet
send_wol_packet "$mac_address" "$broadcast_address"

