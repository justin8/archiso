#!/bin/bash
set -x
count=0
while [[ $count != 10 ]]
do
	if nslookup abachi.dray.be | grep -q 192.168.1.15
	then
		if ip route | grep default | grep -q 192.168.1.1
		then
			sed -i 's/^#//g' /etc/fstab
			mount /var/cache/pacman/pkg
			break
		fi
	fi
	sleep 1
	count=$((count+1))
done
