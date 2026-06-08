#!/bin/bash
set -e

IMAGE=avoid.img
MOUNT=/mnt/avoid-build
REPO=https://repo-default.voidlinux.org/current
ARCH=x86_64

truncate -s 1500M "$IMAGE"

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

XBPS_ARCH=$ARCH xbps-install -y -S -R "$REPO" -r "$MOUNT"
XBPS_ARCH=$ARCH xbps-install -y -R "$REPO" -r "$MOUNT" $(grep -v '^\s*#' packages.list | grep -v '^\s*$')

xgenfstab -U "$MOUNT" > "$MOUNT/etc/fstab"

xchroot "$MOUNT" /bin/bash << 'EOF'
echo "LANG=en_US.UTF-8" > /etc/locale.conf
xbps-reconfigure -fa
echo "root:root" | chpasswd
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Void" --removable
ln -s /etc/sv/agetty-ttyS0 /etc/runit/runsvdir/default/
ln -s /etc/sv/dhcpcd /etc/runit/runsvdir/default/
EOF

mkdir -p "$MOUNT/opt/extras"
cp build.sh "$MOUNT/opt/extras/build.sh"

rm -rf "$MOUNT/var/cache/xbps/"*

dd if=/dev/zero of="$MOUNT/boot/efi/zeroes" bs=4M status=none || true
rm -f "$MOUNT/boot/efi/zeroes"
dd if=/dev/zero of="$MOUNT/zeroes" bs=4M status=none || true
rm -f "$MOUNT/zeroes"

sync
umount -R "$MOUNT"

e2fsck -f "${LOOP}p2"

losetup -d "$LOOP"

xz -T0 -v "$IMAGE"
