#!/bin/bash
set -e

pacman -Syu --noconfirm base-devel sudo
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel
useradd -m builduser -G wheel

mkdir -p /build
cd /build

sudo -u builduser gpg --recv-key 1EB2638FF56C0C53

for package in cower pacaur; do
	(
		curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/$package.tar.gz
		tar xf $package.tar.gz
		cd $package
		chown -R builduser .
		sudo -u builduser -- makepkg -rcfs --noconfirm
		pacman -U --noconfirm ${package}*pkg.tar.xz
	)
done

rm /pacaur_installer.sh
