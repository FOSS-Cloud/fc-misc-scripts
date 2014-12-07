#!/bin/sh

# Bring down the virtual IP address
/bin/ip addr del "$2"/"$3" dev "$1"
