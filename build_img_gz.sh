#!/bin/bash
set -e

rm -f avoid.img.gz

./build_img.sh

gzip -9 -v avoid.img
