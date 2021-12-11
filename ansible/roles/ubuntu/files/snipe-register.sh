#!/bin/bash
#
# Register device with Snipe-IT
#

# Does /opt/snipeit-register already exist?
if [ ! -f /opt/snipeit-register ]
then
    sudo apt-get install hwinfo curl jq dmidecode -y
    
    SNIPE_SERVICE_TAG=$(sudo dmidecode -s system-serial-number)
    SNIPE_MFG=$(dmidecode -s system-manufacturer)
    SNIPE_MODEL=$(dmidecode -s system-product-name)
    SNIPE_CPU=$(dmidecode -s processor-version)
    SNIPE_MEMORY=$(getconf -a | grep PAGES | awk 'BEGIN {total = 1} {if (NR == 1 || NR == 3) total *=$NF} END {print total / 1024" kB"}')
    
    echo "Registering device with Snipe-IT"
    curl -d "{\"service_tag\":\"$SNIPE_SERVICE_TAG\", \"manufacturer\":\"$SNIPE_MFG\", \"model_number\":\"$SNIPE_MODEL\", \"cpu\":\"$SNIPE_CPU\", \"memory\":\"$SNIPE_MEMORY\"}" \
      -H "Content-Type: application/json" \
      "https://5860c07ffa274f384856076929733fb6.m.pipedream.net"
    
    touch /opt/snipeit-register
else
    echo "Device has already been registered with Snipe-IT. Exiting."
fi
