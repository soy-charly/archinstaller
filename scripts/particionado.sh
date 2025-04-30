#!/bin/bash

# Listar las particiones disponibles
echo "Listado de particiones disponibles:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

# Seleccionar partición para la raíz ("/")
echo "Selecciona una partición para la raíz del sistema (ejemplo: /dev/sda1):"
read -p "Introduce la partición para root: " particion_root

# Verificar si la partición para root existe
if ! lsblk | grep -q "$particion_root"; then
    echo "La partición $particion_root no existe o no está disponible. Abortando."
    exit 1
fi

# Montar la partición raíz en /mnt
echo "Montando la partición $particion_root en /mnt..."
sudo mount $particion_root /mnt
echo "Partición $particion_root montada en /mnt."

# Seleccionar partición para /boot
echo "Selecciona una partición para /boot (ejemplo: /dev/sda2):"
read -p "Introduce la partición para /boot: " particion_boot

# Verificar si la partición para /boot existe
if ! lsblk | grep -q "$particion_boot"; then
    echo "La partición $particion_boot no existe o no está disponible. Abortando."
    exit 1
fi

# Crear punto de montaje para /boot si no existe
sudo mkdir -p /mnt/boot

# Montar la partición /boot en /mnt/boot
echo "Montando la partición $particion_boot en /mnt/boot..."
sudo mount $particion_boot /mnt/boot
echo "Partición $particion_boot montada en /mnt/boot."

# Finalización
echo "Las particiones $particion_root y $particion_boot han sido montadas correctamente."
