#!/bin/bash
if nslookup abachi.dray.be|grep 192.168.1.15
then
    sed -i 's/^#//g' /etc/fstab
    mount -a
fi
