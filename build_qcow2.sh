#!/bin/sh
set -e

IMG=${1:-avoid.img}

xbps-install -Sy qemu-img

rm -f avoid.qcow2

[ -n "$1" ] || ./build_img.sh

# expand to 8G (sparse) so VM has room to grow
truncate -s 8G "$IMG"
echo ", +" | sfdisk -N 2 "$IMG"
LOOP=$(losetup -fP --show "$IMG")

cleanup() {
    losetup -d "$LOOP" 2>/dev/null || true
}
trap cleanup EXIT

resize2fs "${LOOP}p2"

losetup -d "$LOOP"
trap - EXIT

qemu-img convert -f raw -O qcow2 "$IMG" avoid.qcow2
rm "$IMG"
