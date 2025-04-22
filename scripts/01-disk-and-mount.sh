#!/bin/bash

echo "== PARTICIONADO DEL DISCO ($DISK) =="

echo "Seleccione una opción:"
echo "1) Crear nuevas particiones"
echo "2) Usar particiones existentes"
read -p "Opción: " OPTION

if [ "$OPTION" -eq 1 ]; then
    # Crear las particiones
    echo "Creando particiones..."
    parted $DISK mklabel gpt
    parted $DISK mkpart primary 1MiB 100%

    # Crear particiones para /, /home y swap
    pvcreate ${DISK}1
    vgcreate vg0 ${DISK}1
    lvcreate -L 30G -n root vg0
    read -p "¿Desea configurar swap? (s/n): " CONFIG_SWAP
    if [ "$CONFIG_SWAP" == "s" ]; then
        lvcreate -L 2G -n swap vg0
    fi
    lvcreate -l 100%FREE -n home vg0

    # Formatear las particiones
    mkfs.$FS_TYPE /dev/vg0/root
    mkfs.$FS_TYPE /dev/vg0/home
    if [ "$CONFIG_SWAP" == "s" ]; then
        mkswap /dev/vg0/swap
        swapon /dev/vg0/swap
    fi

elif [ "$OPTION" -eq 2 ]; then
    read -p "Ingrese la partición para root: " ROOT_PART
    read -p "Ingrese la partición para home: " HOME_PART
    read -p "¿Desea configurar swap? (s/n): " CONFIG_SWAP
    if [ "$CONFIG_SWAP" == "s" ]; then
        read -p "Ingrese la partición para swap: " SWAP_PART
        mkswap $SWAP_PART
        swapon $SWAP_PART
    fi
else
    echo "Opción no válida. Saliendo..."
    exit 1
fi

# Montar las particiones
mount ${ROOT_PART:-/dev/vg0/root} /mnt
mkdir -p /mnt/home
mount ${HOME_PART:-/dev/vg0/home} /mnt/home

echo "== MONTAJE DE PARTICIONES =="

# Montar el sistema de archivos
mount --mkdir /mnt

# Montar las particiones adicionales
mkdir -p /mnt/home
mount /dev/vg0/home /mnt/home
