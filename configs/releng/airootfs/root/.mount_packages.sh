#!/bin/bash
<<<<<<< HEAD
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
=======
if nslookup abachi.dray.be|grep 192.168.1.15
then
    sed -i 's/^#//g' /etc/fstab
    mount -a
fi
>>>>>>> Changed to auto-mount packages share if it is on a local network to abachi; otherwise don't mount it.
