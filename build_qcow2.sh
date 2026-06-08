#!/bin/sh
set -e

xbps-install -Sy qemu-img

rm -f avoid.qcow2

./build_img.sh

# expand to 8G (sparse) so VM has room to grow
truncate -s 8G avoid.img
echo ", +" | sfdisk -N 2 avoid.img
LOOP=$(losetup -fP --show avoid.img)

cleanup() {
    losetup -d "$LOOP" 2>/dev/null || true
}
trap cleanup EXIT

resize2fs "${LOOP}p2"

losetup -d "$LOOP"
trap - EXIT

qemu-img convert -f raw -O qcow2 avoid.img avoid.qcow2
rm avoid.img
