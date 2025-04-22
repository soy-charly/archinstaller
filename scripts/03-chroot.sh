#!/bin/bash

echo "== CONFIGURACIÓN DESDE CHROOT =="

# Chroot al sistema
arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc
locale-gen
echo "LANG=$LANG" > /etc/locale.conf
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf

# Establecer el nombre de host
echo "$HOSTNAME" > /etc/hostname
EOF
