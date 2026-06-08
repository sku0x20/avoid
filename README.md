# Avoid

A minimal Linux distribution based on Void Linux, aimed at servers, build machines, and live recovery disks.

## Images

Pre-built images are available on the [releases](https://github.com/sku0x20/avoid/releases) page:

- `avoid.img.gz` — raw disk image, use with `dd`
- `avoid.qcow2` — QEMU/KVM image

No ISO for now.

## Build

```sh
./build_img.sh       # raw image
./build_img_gz.sh    # gzipped raw image
./build_qcow2.sh     # qcow2 image
```

