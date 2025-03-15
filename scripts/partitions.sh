#!/bin/bash

echo "Lista de discos disponibles:"
lsblk

read -p "Ingrese la partición para la raíz del sistema (ejemplo: /dev/sdX1 o /dev/nvme0n1p1): " ROOT_PARTITION
read -p "Ingrese la partición para /boot (ejemplo: /dev/sdX2 o /dev/nvme0n1p2): " BOOT_PARTITION

mkfs.ext4 "$ROOT_PARTITION"
mkfs.fat -F32 "$BOOT_PARTITION"

mount "$ROOT_PARTITION" /mnt
mkdir -p /mnt/boot
mount "$BOOT_PARTITION" /mnt/boot
