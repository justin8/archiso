#!/bin/bash

SCRIPT=$(mktemp)
grep -A10000 '^#########' "$0" > "$SCRIPT"
cd "$(dirname "$(readlink -f "$0")")"
CACHEDIR="/var/cache/pacman/pkg"
VPKG=''
[[ -e $CACHEDIR ]] && VPKG="--volume=$CACHEDIR:$CACHEDIR"

docker run --rm \
	   --privileged \
	   $VPKG \
	   --volume="$(pwd):/run" \
	   --volume="$SCRIPT:/docker_build.sh" \
	   --workdir=/run \
	   justin8/archlinux \
	   /bin/bash /docker_build.sh $EUID ${GROUPS[0]}
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
EXTERNAL_DIR=$(pwd)
TEMP="$(mktemp -d)"
USER="$1"
GROUP="$2"
LOG="$(mktemp)"
OUT="$(mktemp)"

cleanup() {
	if [[ $? -ne 0 ]]; then
		cat "$LOG" >> "$OUT"
	fi
	rm -f "$LOG" "$OUT"
}

trap cleanup EXIT SIGINT SIGTERM
tail -f "$OUT" &
exec &> "$LOG"
echo -n "Updating packages... " >> "$OUT"
pacman -Syu --noconfirm archiso make
echo -e "[ \e[32;1mOK\e[0m ]" >> "$OUT"

# Mount a tmpfs folder for faster building
echo -n "Creating build dir... " >> "$OUT"
# TODO: This creates a mount/utab file in the mounted directory; not sure how. It isn't CWD when starting docker. it seems to be the directory the script runs from. Just removing it for now.
mount -t tmpfs tmpfs "$TEMP"
rm "$EXTERNAL_DIR/mount/utab"
rmdir "$EXTERNAL_DIR/mount"
echo -e "[ \e[32;1mOK\e[0m ]" >> "$OUT"

cd "$EXTERNAL_DIR"
cp -r . "$TEMP"

echo -n "Preparing build environment... " >> "$OUT"
cd "$TEMP"
make install
cd "$BUILDDIR"
rm -rf work out
echo -e "[ \e[32;1mOK\e[0m ]" >> "$OUT"

echo -n "Building ISO (this may take several minutes)... " >> "$OUT"
ionice ./build.sh -v 2>&1
echo $?
echo -e "[ \e[32;1mOK\e[0m ]" >> "$OUT"

echo -n "Copying ISO... " >> "$OUT"
ISO=$(find out -iname '*.iso' | cut -d/ -f2)
cp "out/$ISO" "$EXTERNAL_DIR"
echo -e "[ \e[32;1mOK\e[0m ]" >> "$OUT"

echo -n "Fixing permissions on ISO file... " >> "$OUT"
chown "$USER:$GROUP" "$EXTERNAL_DIR/$ISO"
echo -e "[ \e[32;1mOK\e[0m ]" >> "$OUT"


cleanup
rm "$EXTERNAL_DIR/mount/utab"
rmdir "$EXTERNAL_DIR/mount"
exit $rc
