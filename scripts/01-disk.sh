#!/bin/bash

echo "== PARTICIONADO DEL DISCO ($DISK) =="

# Crear las particiones
echo "Creando particiones..."
parted $DISK mklabel gpt
parted $DISK mkpart primary 1MiB 100%

# Crear particiones para /, /home y swap
pvcreate ${DISK}1
vgcreate vg0 ${DISK}1
lvcreate -L 30G -n root vg0
lvcreate -L 2G -n swap vg0
lvcreate -l 100%FREE -n home vg0

# Formatear las particiones
mkfs.$FS_TYPE /dev/vg0/root
mkfs.$FS_TYPE /dev/vg0/home
mkswap /dev/vg0/swap
swapon /dev/vg0/swap

# Montar las particiones
mount /dev/vg0/root /mnt
mkdir /mnt/home
mount /dev/vg0/home /mnt/home
