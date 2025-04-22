#!/bin/bash

echo "== INSTALACIÓN DE LA BASE DE ARCH LINUX =="

# Instalar el sistema base
pacstrap /mnt base linux linux-firmware

# Generar el archivo fstab
genfstab -U /mnt >> /mnt/etc/fstab
