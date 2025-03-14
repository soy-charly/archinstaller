#!/bin/bash
set -e  # Detener el script si hay errores

# Definir particiones
ROOT_PART="/dev/sda5"
BOOT_PART="/dev/sda3"

# Montar particiones
echo "🚀 Montando particiones..."
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot
mount "$BOOT_PART" /mnt/boot

# Instalar Arch Linux
echo "🚀 Instalando Arch Linux..."
pacstrap /mnt base linux linux-firmware vim sudo

# Generar fstab
echo "🚀 Generando fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Configurar el sistema dentro del nuevo Arch instalado
echo "🚀 Configurando sistema..."
arch-chroot /mnt bash -c "
    echo 'LANG=es_ES.UTF-8' > /etc/locale.conf
    echo 'KEYMAP=es' > /etc/vconsole.conf
    echo 'miarch' > /etc/hostname
    ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
    hwclock --systohc
    echo 'es_ES.UTF-8 UTF-8' >> /etc/locale.gen
    locale-gen
"

# Crear usuario root con contraseña "root"
echo "🚀 Configurando usuario root..."
arch-chroot /mnt bash -c "
    echo root:root | chpasswd
"

# Crear usuario charly con contraseña "ascrol2008"
echo "🚀 Configurando usuario charly..."
arch-chroot /mnt bash -c "
    useradd -m -G wheel -s /bin/bash charly
    echo charly:ascrol2008 | chpasswd
    echo 'charly ALL=(ALL) ALL' >> /etc/sudoers
"

# Instalar y configurar GRUB
echo "🚀 Instalando GRUB..."
arch-chroot /mnt bash -c "
    pacman -S --noconfirm grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg
"

echo "✅ Instalación finalizada. Reinicia el sistema y entra con tu usuario."
