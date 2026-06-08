#!/bin/bash
set -e

./build_img.sh

qemu-img convert -f raw -O qcow2 avoid.img avoid.qcow2
rm avoid.img
