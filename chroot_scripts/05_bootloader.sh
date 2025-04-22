#!/bin/bash

source /installer.conf

echo "### Instalando GRUB ###"
pacman -Sy --noconfirm grub efibootmgr

if [ -d /sys/firmware/efi ]; then
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
else
    grub-install --target=i386-pc $ROOT_PART
fi
grub-mkconfig -o /boot/grub/grub.cfg
