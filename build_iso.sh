#!/bin/bash
set -e

./build_raw.sh

gzip -9 -v avoid.img
mv avoid.img.gz avoid.iso.gz
