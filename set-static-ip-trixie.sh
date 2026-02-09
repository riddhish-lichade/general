#!/bin/bash

# Static IP Configuration Script for Raspberry Pi (Debian Trixie)
# Uses NetworkManager (nmcli) - default on Debian Trixie

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <IP_ADDRESS>"
    echo "Example: $0 172.16.16.100"
    exit 1
fi

IP="$1"
GATEWAY="172.16.16.1"
CIDR="20"
DNS="172.16.16.1"  # Using router as DNS; change if needed

# Validate IP format
if ! [[ "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Invalid IP address format."
    exit 1
fi

# Get the active connection name (wired)
CON_NAME=#$(nmcli -t -f NAME,TYPE con show --active | grep ethernet | head -1 | cut -d: -f1)

if [ -z "$CON_NAME" ]; then
    echo "Error: No active ethernet connection found."
    exit 1
fi

echo "Configuring static IP on connection: $CON_NAME"
echo "  Connection : $CON_NAME"
echo "  IP Address : ${IP}/${CIDR}"
echo "  Gateway    : ${GATEWAY}"
echo "  DNS        : ${DNS}"

nmcli c mod "$CON_NAME" ipv4.addresses "${IP}/${CIDR}" ipv4.method manual
nmcli con mod "$CON_NAME" ipv4.gateway "$GATEWAY"
nmcli con mod "$CON_NAME" ipv4.dns "$DNS"
nmcli c down "$CON_NAME" && nmcli c up "$CON_NAME"

echo "Reactivating connection..."

echo "Done. Static IP ${IP} configured."
