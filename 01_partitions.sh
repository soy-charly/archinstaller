#!/bin/bash

source functions.sh

echo "### Configuración de particiones ###"
BOOT_PART=$(select_partition "Selecciona la partición BOOT")
ROOT_PART=$(select_partition "Selecciona la partición ROOT")

# Guardar variables para uso posterior
echo "BOOT_PART=$BOOT_PART" > /installer.conf
echo "ROOT_PART=$ROOT_PART" >> /installer.conf

# Formatear y montar
mkfs.ext4 $ROOT_PART
[ -d /sys/firmware/efi ] && mkfs.fat -F32 $BOOT_PART || mkfs.ext4 $BOOT_PART

mount $ROOT_PART /mnt
mkdir -p /mnt/boot
mount $BOOT_PART /mnt/boot
