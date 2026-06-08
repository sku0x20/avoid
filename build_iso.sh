#!/bin/bash
set -e

./build_img.sh

gzip -9 -v avoid.img
