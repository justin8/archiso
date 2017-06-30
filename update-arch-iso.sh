#!/bin/bash

cd "$(dirname "$0")"
CACHEDIR="/var/cache/pacman/pkg"
VPKG=''
SCRIPT="$PWD/.docker_build.sh"
grep -A10000 '^#########' "$0" > "$SCRIPT"

[[ -e $CACHEDIR ]] && VPKG="--volume=$CACHEDIR:$CACHEDIR"

docker run --rm \
	   --privileged \
	   -t \
	   $VPKG \
	   --volume="$(pwd):/run:rw" \
	   --volume="$SCRIPT:/docker_build.sh" \
	   --workdir=/run \
	   base/archlinux \
	   /bin/bash -x /docker_build.sh $EUID ${GROUPS[0]}
rc=$?
rm "$SCRIPT"

exit $rc
##########
set -e

if ! grep -q docker /proc/1/cgroup; then
	echo 'This should only be run inside of docker!'
	exit 1
fi

BUILDDIR="configs/releng"
USER="$1"
GROUP="$2"

cleanup() {
	rm -rf "$EXTERNAL_DIR/mount"
	rm -rf "$BUILDDIR/work" "$BUILDDIR/out"
}

trap cleanup EXIT SIGINT SIGTERM

echo "-- Preparing build environment..."
pacman -Syu --noconfirm archiso make

# Update to archiso version in this repo
make install
rm -rf "$BUILDDIR/{work,out}"

echo "-- Building ISO (this may take several minutes)..."
(cd "$BUILDDIR" && ionice ./build.sh -v 2>&1)

echo "-- Copying ISO..."
find . -iname '*.iso' -exec mv {} . \;

echo "-- Fixing permissions on ISO file..."
chown "$USER:$GROUP" *.iso
