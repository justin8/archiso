#!/bin/bash
for dev in $(find /sys -name 'max_write_same_blocks')
do
	echo 0 > $dev
done

systemctl start multipathd
