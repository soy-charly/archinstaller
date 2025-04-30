#!/bin/bash

# Configuración del sistema

# Comprobamos si ya estamos en chroot
if [[ ! -f /etc/hostname ]]; then
    echo "Este script debe ejecutarse en el entorno chroot del sistema recién instalado."
    exit 1
fi

# Configuración de la zona horaria
echo "Configurando la zona horaria..."
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc
echo "Zona horaria configurada."

# Configuración del idioma
echo "Configurando el idioma..."
echo "es_ES.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=es_ES.UTF-8" > /etc/locale.conf
echo "Idioma configurado."

# Configuración del hostname
read -p "Introduce el nombre de tu equipo (hostname): " hostname
echo "$hostname" > /etc/hostname
echo "Hostname configurado."

# Configuración de la red
echo "¿Deseas configurar la red ahora?"
confirmar "Deseas configurar la red ahora"

# Si elige NetworkManager
echo "Instalando NetworkManager..."
pacman -S networkmanager --noconfirm
systemctl enable NetworkManager
systemctl start NetworkManager
echo "Red configurada."

# Configuración de contraseñas
echo "Estableciendo la contraseña del superusuario (root)..."
passwd
read -p "Introduce un nombre de usuario para tu cuenta de usuario: " usuario
useradd -m -G wheel -s /bin/bash $usuario
echo "Estableciendo la contraseña para el usuario $usuario..."
passwd $usuario
echo "Contraseña configurada."
