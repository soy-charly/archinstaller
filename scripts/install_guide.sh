#!/bin/bash

set -e

echo "Bienvenido al instalador de Arch Linux"

# Selección de particiones
echo "Lista de discos disponibles:"
lsblk
read -p "Ingrese la partición para la raíz del sistema (ejemplo: /dev/sdX1 o /dev/nvme0n1p1): " ROOT_PARTITION
read -p "Ingrese la partición para /boot (ejemplo: /dev/sdX2 o /dev/nvme0n1p2): " BOOT_PARTITION

# Ejecutar el script de instalación base
bash base_install.sh $ROOT_PARTITION $BOOT_PARTITION

# Ejecutar la configuración del sistema
arch-chroot /mnt bash /root/configure_system.sh

# Ejecutar la instalación del gestor de arranque
arch-chroot /mnt bash /root/install_bootloader.sh

# Preguntar si instalar Hyprland y Ly
arch-chroot /mnt bash /root/install_hyprland.sh

echo "Instalación completada. Puede reiniciar ahora."
