#!/bin/bash

echo "Actualizando lista de paquetes..."
pacman -Sy --noconfirm

PS3='Elige el número correspondiente al entorno de escritorio: '
options=("GNOME" "KDE" "Xfce" "LXQt" "Hyprland" "Ninguno")

select opt in "${options[@]}"; do
    case $REPLY in
        1)
            echo "Instalando GNOME..."
            pacman -S --noconfirm gnome gnome-extra gdm gnome-tweaks xdg-user-dirs-gtk
            systemctl enable gdm
            break;;
        2)
            echo "Instalando KDE (Plasma)..."
            pacman -S --noconfirm plasma kde-applications sddm xdg-desktop-portal-kde
            systemctl enable sddm
            break;;
        3)
            echo "Instalando Xfce..."
            pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter xdg-user-dirs-gtk
            systemctl enable lightdm
            break;;
        4)
            echo "Instalando LXQt..."
            pacman -S --noconfirm lxqt lxqt-arch-config sddm xorg xdg-user-dirs-gtk
            systemctl enable sddm
            break;;
        5)
            echo "Instalando Hyprland..."
            pacman -S --noconfirm hyprland xdg-desktop-portal-hyprland xdg-desktop-portal wlroots waybar kitty rofi thunar xwayland
            grep -qxF 'exec hyprland' ~/.xinitrc 2>/dev/null || echo 'exec hyprland' >> ~/.xinitrc
            break;;
        6)
            echo "No se instalará ningún entorno de escritorio."
            break;;
        *)
            echo "Opción inválida. Por favor, elige un número entre 1 y ${#options[@]}.";;
    esac
done

