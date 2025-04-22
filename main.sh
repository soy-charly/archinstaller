#!/bin/bash

# Verificar root
if [ "$(id -u)" != "0" ]; then
    echo "Este script debe ejecutarse como root"
    exit 1
fi

# Importar funciones
source functions.sh

# Ejecutar pasos de instalación
source 1_partitions.sh
source 2_base_install.sh

# Copiar scripts para chroot
mkdir -p /mnt/installer
cp -r chroot_scripts/* /mnt/installer/
arch-chroot /mnt /bin/bash -c "chmod +x /installer/*.sh && /installer/3_timezone.sh"

# Limpiar y reiniciar
rm -rf /mnt/installer
umount -R /mnt
echo "¡Instalación completada! Reinicia con: reboot"
