#!/bin/sh
set -e

rm -f avoid.img.gz

[ -f avoid.img ] || ./build_img.sh

gzip -9 -v avoid.img
