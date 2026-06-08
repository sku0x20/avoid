#!/bin/bash
set -e

./build_raw.sh

gzip -9 -v avoid.img
