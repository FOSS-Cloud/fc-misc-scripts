#!/bin/sh

# Bring up the virtual IP address
/bin/ip addr add "$2"/"$3" dev "$1"
