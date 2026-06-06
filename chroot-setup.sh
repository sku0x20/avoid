#!/bin/bash
set -e

echo "root:root" | chpasswd
xbps-reconfigure -fa
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Void" --removable
ln -s /etc/sv/agetty-ttyS0 /var/service/
ln -s /etc/sv/dhcpcd /var/service/
