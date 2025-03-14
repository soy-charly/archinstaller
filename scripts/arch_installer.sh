#!/bin/bash
set -e  # Detener el script si hay errores

echo "🚀 Bienvenido a la instalación de Arch Linux con Hyprland"
echo "🔹 Este script te guiará en la configuración inicial."
echo ""

# Verificar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "⚠️ Este script debe ejecutarse como root. Usa sudo."
    exit 1
fi

# Selección de disco para instalación
lsblk
read -p "❓ Ingresa el disco donde se instalará el sistema (ejemplo: sda): " DISK

# Confirmación antes de formatear
read -p "⚠️ Se formateará $DISK. ¿Estás seguro? (y/n): " confirm_disk
if [[ "$confirm_disk" != "y" ]]; then
    echo "❌ Instalación cancelada."
    exit 1
fi

echo "🚀 Creando particiones en /dev/$DISK..."
(
    echo g # Crear nueva tabla GPT
    echo n # Nueva partición para Boot
    echo 1 # Número de partición
    echo   # Inicio automático
    echo +512M # Tamaño
    echo t # Cambiar tipo
    echo 1 # Tipo EFI

    echo n # Nueva partición para Root
    echo 2
    echo   
    echo +20G

    echo n # Nueva partición para Home
    echo 3
    echo   
    echo   

    echo w # Guardar cambios
) | fdisk /dev/$DISK

echo "🚀 Formateando particiones..."
mkfs.fat -F32 /dev/${DISK}1
mkfs.ext4 /dev/${DISK}2
mkfs.ext4 /dev/${DISK}3

echo "🚀 Montando particiones..."
mount /dev/${DISK}2 /mnt
mkdir -p /mnt/boot
mount /dev/${DISK}1 /mnt/boot
mkdir -p /mnt/home
mount /dev/${DISK}3 /mnt/home

# Configuración de usuario
read -p "❓ Ingresa el nombre de usuario: " USERNAME
read -s -p "🔑 Ingresa la contraseña para $USERNAME: " PASSWORD
echo
read -p "❓ ¿Deseas crear el usuario root con contraseña root? (y/n): " create_root

# Instalación del sistema base
echo "🚀 Instalando Arch Linux..."
pacstrap /mnt base linux linux-firmware sudo nano networkmanager

echo "🚀 Generando fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Configuración dentro de chroot
arch-chroot /mnt /bin/bash <<EOF
echo "🚀 Configurando el sistema dentro del chroot..."

echo "🚀 Configurando zona horaria..."
ln -sf /usr/share/zoneinfo/$(curl -s https://ipapi.co/timezone) /etc/localtime
hwclock --systohc

echo "🚀 Configurando locales..."
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "🚀 Configurando hostname..."
echo "archlinux" > /etc/hostname
echo "127.0.0.1   localhost" >> /etc/hosts
echo "::1         localhost" >> /etc/hosts

echo "🚀 Habilitando NetworkManager..."
systemctl enable NetworkManager

echo "🚀 Creando usuario $USERNAME..."
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd

echo "🚀 Instalando sudo y configurando permisos..."
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel

# Configuración del usuario root
if [[ "$create_root" == "y" ]]; then
    echo "🚀 Configurando usuario root..."
    echo "root:root" | chpasswd
fi

echo "🚀 Instalación de base completada."
EOF

# Preguntar si se desea instalar Hyprland y Ly
read -p "❓ ¿Deseas instalar Hyprland y Ly? (y/n): " install_hyprland
if [[ "$install_hyprland" == "y" ]]; then
    echo "🚀 Ejecutando instalación de Hyprland..."
    arch-chroot /mnt /bin/bash -c "curl -O https://raw.githubusercontent.com/tu-repo/install_hyprland.sh && bash install_hyprland.sh"
    echo "✅ Hyprland instalado correctamente."
fi

# Preguntar si se desea instalar las mejoras adicionales
read -p "❓ ¿Deseas instalar mejoras adicionales? (y/n): " install_extras
if [[ "$install_extras" == "y" ]]; then
    echo "🚀 Ejecutando instalación de extras..."
    arch-chroot /mnt /bin/bash -c "curl -O https://raw.githubusercontent.com/tu-repo/install_extras.sh && bash install_extras.sh"
    echo "✅ Mejoras adicionales instaladas correctamente."
fi

echo ""
echo "🎉 Instalación completada. Reinicia tu sistema y disfruta Arch Linux con Hyprland."
