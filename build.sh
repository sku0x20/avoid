#!/bin/bash
set -e

IMAGE=avoid.img
MOUNT=/mnt/avoid-build
REPO=https://repo-default.voidlinux.org/current
ARCH=x86_64

truncate -s 500M "$IMAGE"

sfdisk "$IMAGE" << 'EOF'
label: gpt
size=512M, type=uefi
type=linux
EOF

LOOP=$(losetup -fP --show "$IMAGE")

mkfs.vfat "${LOOP}p1"
mkfs.ext4 "${LOOP}p2"

mkdir -p "$MOUNT"
mount "${LOOP}p2" "$MOUNT"
mkdir -p "$MOUNT/boot/efi"
mount "${LOOP}p1" "$MOUNT/boot/efi"

mkdir -p "$MOUNT/etc/xbps.d"
cp noextract.conf "$MOUNT/etc/xbps.d/noextract.conf"

mkdir -p "$MOUNT/var/db/xbps/keys"
cp /var/db/xbps/keys/* "$MOUNT/var/db/xbps/keys/"

XBPS_ARCH=$ARCH xbps-install -S -R "$REPO" -r "$MOUNT"
XBPS_ARCH=$ARCH xbps-install -R "$REPO" -r "$MOUNT" $(grep -v '^\s*#' packages.list | grep -v '^\s*$')

echo "LANG=en_US.UTF-8" > "$MOUNT/etc/locale.conf"

xgenfstab -U "$MOUNT" > "$MOUNT/etc/fstab"

xchroot "$MOUNT" /bin/bash << 'EOF'
xbps-reconfigure -fa
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Void" --removable
ln -s /etc/sv/agetty-ttyS0 /var/service/
ln -s /etc/sv/dhcpcd /var/service/
EOF

mkdir -p "$MOUNT/opt/extras"
cp build.sh "$MOUNT/opt/extras/build.sh"

rm -rf "$MOUNT/var/cache/xbps/"*

e2fsck -f "${LOOP}p2"
sync

umount -R "$MOUNT"
losetup -d "$LOOP"
