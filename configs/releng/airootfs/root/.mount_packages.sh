#!/bin/bash
set -x
count=0
while [[ $count != 10 ]]
do
	if nslookup abachi.dray.be | grep -q 192.168.1.15
	then
		sed -i 's/^#//g' /etc/fstab
		mount /var/cache/pacman/pkg
		break
	fi
	sleep 1
	count=$((count+1))
done
