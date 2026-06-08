#!/bin/bash
set -e

./build_img.sh

LOOP=$(losetup -fP --show avoid.img)

cleanup() {
    losetup -d "$LOOP" 2>/dev/null || true
}
trap cleanup EXIT

e2fsck -f "${LOOP}p2"
resize2fs "${LOOP}p2" 1400M

losetup -d "$LOOP"
trap - EXIT

echo ", 1400M" | sfdisk -N 2 avoid.img
truncate -s 2G avoid.img

gzip -9 -v avoid.img
