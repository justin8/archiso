#!/bin/bash

set -e -u

sed -i 's/#\(en_AU\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/Australia/Brisbane /etc/localtime

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/

useradd -m -p "" -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /usr/bin/zsh arch
echo "root:root" | chpasswd

chmod 750 /etc/sudoers.d
chmod 440 /etc/sudoers.d/g_wheel
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

systemctl enable pacman-init.service sshd.service
systemctl set-default multi-user.target
