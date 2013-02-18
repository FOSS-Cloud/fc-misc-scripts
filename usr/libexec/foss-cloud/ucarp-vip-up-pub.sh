#!/bin/sh
 
# Bring up the virtual IP address
/sbin/ip addr add "$2"/"$3" dev "$1"

# Start apache
/etc/init.d/apache2 start
