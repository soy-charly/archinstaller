#!/bin/bash

# Instalación de software adicional y gestor de arranque

# Instalación del gestor de arranque
echo "¿Qué gestor de arranque deseas usar?"
echo "1) GRUB"
echo "2) Syslinux"
read -p "Opción: " gestor_arranque

case $gestor_arranque in
    1)
        echo "Instalando GRUB..."
        pacman -S grub os-prober --noconfirm
        grub-install --target=i386-pc /dev/sda
        grub-mkconfig -o /boot/grub/grub.cfg
        ;;
    2)
        echo "Instalando Syslinux..."
        pacman -S syslinux --noconfirm
        syslinux-install_update -i -a -m
        ;;
    *)
        echo "Opción no válida. Abortando."
        exit 1
        ;;
esac

# Instalación de software adicional
echo "¿Deseas instalar software adicional como un entorno de escritorio o gestor de ventanas?"
confirmar "Deseas instalar software adicional ahora"

echo "Selecciona un entorno de escritorio o gestor de ventanas:"
echo "1) GNOME"
echo "2) KDE Plasma"
echo "3) Xfce"
echo "4) i3"
echo "5) No instalar entorno gráfico"
read -p "Opción: " opcion_software

case $opcion_software in
    1)
        echo "Instalando GNOME..."
        pacman -S gnome gnome-extra --noconfirm
        ;;
    2)
        echo "Instalando KDE Plasma..."
        pacman -S plasma kde-applications --noconfirm
        ;;
    3)
        echo "Instalando Xfce..."
        pacman -S xfce4 xfce4-goodies --noconfirm
        ;;
    4)
        echo "Instalando i3..."
        pacman -S i3-wm i3status i3lock --noconfirm
        ;;
    5)
        echo "No se instalará entorno gráfico."
        ;;
    *)
        echo "Opción no válida. Abortando."
        exit 1
        ;;
esac
