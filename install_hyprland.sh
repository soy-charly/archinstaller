#!/bin/bash
set -e  # Detener el script si hay errores

echo "🚀 Actualizando sistema..."
pacman -Syu --noconfirm

echo "🚀 Instalando paquetes base para Hyprland..."
pacman -S --noconfirm \
    hyprland xdg-desktop-portal-hyprland \
    waybar rofi kitty dunst \
    firefox neovim htop \
    polkit-kde-agent brightnessctl \
    wl-clipboard cliphist \
    thunar gvfs tumbler ffmpegthumbnailer \
    network-manager-applet pavucontrol \
    bluez bluez-utils blueman \
    pipewire pipewire-pulse wireplumber \
    noto-fonts noto-fonts-emoji ttf-jetbrains-mono \
    mesa vulkan-intel vulkan-radeon libva-mesa-driver \
    ly

echo "🚀 Habilitando servicios esenciales..."
systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable ly

echo "🚀 Creando archivos de configuración..."
mkdir -p /home/charly/.config/hypr
mkdir -p /home/charly/.config/waybar
mkdir -p /home/charly/.config/rofi

echo "exec Hyprland" > /home/charly/.xinitrc

echo "✅ Instalación de Hyprland y Ly completada. Reinicia y entra con tu usuario."
