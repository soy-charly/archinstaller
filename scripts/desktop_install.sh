#!/bin/bash

read -p "¿Desea instalar Hyprland y Ly? (s/n): " INSTALL_HYPR
if [[ "$INSTALL_HYPR" =~ ^[Ss]$ ]]; then
    arch-chroot /mnt pacman -S --noconfirm hyprland ly nano kitty waybar rofi dunst alacritty grim slurp xdg-desktop-portal-hyprland xdg-user-dirs polkit-kde-agent firefox dolphin nvidia
    arch-chroot /mnt systemctl enable ly
fi
