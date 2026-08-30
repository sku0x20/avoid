#!/bin/sh
set -e

IMG=${1:-avoid.img}

rm -f avoid.img.gz

[ -n "$1" ] || ./build_img.sh

gzip -9 -v "$IMG"
