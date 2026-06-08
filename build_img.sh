#!/bin/sh
set -e

IMAGE=avoid.img
MOUNT=/mnt/avoid-build
REPO=https://repo-default.voidlinux.org/current
ARCH=x86_64

cleanup() {
    umount -R "$MOUNT" 2>/dev/null || true
    [ -n "$LOOP" ] && losetup -d "$LOOP" 2>/dev/null || true
}
trap cleanup EXIT

rm -f "$IMAGE"
truncate -s 2G "$IMAGE"

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

blkid "${LOOP}p1" "${LOOP}p2"
xgenfstab -U "$MOUNT" > "$MOUNT/etc/fstab"

cp zshrc "$MOUNT/root/.zshrc"
mkdir -p "$MOUNT/etc/skel/.ssh"
cp zshrc "$MOUNT/etc/skel/.zshrc"
touch "$MOUNT/etc/skel/.ssh/authorized_keys"
chmod 700 "$MOUNT/etc/skel/.ssh"
chmod 600 "$MOUNT/etc/skel/.ssh/authorized_keys"
echo "SHELL=/bin/zsh" >> "$MOUNT/etc/default/useradd"
mkdir -p "$MOUNT/etc/ssh/sshd_config.d"
cp sshd_hardening.conf "$MOUNT/etc/ssh/sshd_config.d/hardening.conf"
cp os-release "$MOUNT/etc/os-release"
cp issue "$MOUNT/etc/issue"
sed -i 's/Welcome to Void!/Welcome to Avoid!/' "$MOUNT/etc/runit/1"
sed -i 's/GRUB_DISTRIBUTOR="Void"/GRUB_DISTRIBUTOR="Avoid"/' "$MOUNT/etc/default/grub"
sed -i 's/Void Linux with kernel/Avoid with kernel/g' "$MOUNT/etc/kernel.d/post-install/50-efibootmgr"
sed -i 's/Void Linux with kernel/Avoid with kernel/g' "$MOUNT/etc/kernel.d/post-remove/50-efibootmgr"

xchroot "$MOUNT" /bin/sh << 'EOF'
set -e
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "avoid" > /etc/hostname
usermod -p "$(openssl passwd -6 root)" -s /bin/zsh root
ln -sf dash /bin/sh
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="avoid" --no-nvram
mkdir -p /boot/efi/EFI/BOOT
cp /boot/efi/EFI/avoid/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI
ln -s /etc/sv/agetty-ttyS0 /etc/runit/runsvdir/default/
ln -s /etc/sv/dhcpcd /etc/runit/runsvdir/default/
xbps-reconfigure -fa
EOF

rm -rf "$MOUNT/var/cache/xbps/"*

# zerofill so freed blocks (e.g. deleted xbps package cache) don't compress poorly
dd if=/dev/zero of="$MOUNT/boot/efi/zeroes" bs=4M status=none || true
rm -f "$MOUNT/boot/efi/zeroes"
dd if=/dev/zero of="$MOUNT/zeroes" bs=4M status=none || true
rm -f "$MOUNT/zeroes"

sync
umount -R "$MOUNT"

e2fsck -fp "${LOOP}p2"

losetup -d "$LOOP"
