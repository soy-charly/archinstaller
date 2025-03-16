#!/bin/bash

read -p "¿Desea instalar Hyprland y Ly? (s/n): " INSTALL_HYPR
if [[ "$INSTALL_HYPR" =~ ^[Ss]$ ]]; then
    read -p "¿Qué marca de tarjeta gráfica tienes? (nvidia/amd/intel): " GPU_BRAND
    case "$GPU_BRAND" in
        nvidia)
            GPU_PACKAGE="nvidia"
            ;;
        amd)
            GPU_PACKAGE="xf86-video-amdgpu"
            ;;
        intel)
            GPU_PACKAGE="xf86-video-intel"
            ;;
        *)
            echo "Marca de tarjeta gráfica no válida. Saliendo..."
            exit 1
            ;;
    esac

    arch-chroot /mnt pacman -S --noconfirm hyprland ly nano kitty waybar rofi dunst alacritty grim slurp xdg-desktop-portal-hyprland xdg-user-dirs polkit-kde-agent firefox dolphin "$GPU_PACKAGE"
    arch-chroot /mnt systemctl enable ly
fi
