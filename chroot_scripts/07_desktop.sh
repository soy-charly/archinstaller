#!/bin/bash

PS3='Elige el número correspondiente al entorno de escritorio: '
options=("GNOME" "KDE" "Xfce" "LXQt" "Hyprland" "Ninguno")
select opt in "${options[@]}"; do
    case $REPLY in
        1)
            echo "Instalando GNOME..."
            pacman -Sy --noconfirm gnome gdm
            systemctl enable gdm
            break;;
        2)
            echo "Instalando KDE..."
            pacman -Sy --noconfirm plasma sddm
            systemctl enable sddm
            break;;
        3)
            echo "Instalando Xfce..."
            pacman -Sy --noconfirm xfce4 lightdm
            systemctl enable lightdm
            break;;
        4)
            echo "Instalando LXQt..."
            pacman -Sy --noconfirm lxqt sddm
            systemctl enable sddm
            break;;
        5)
            echo "Instalando Hyprland..."
            pacman -Sy --noconfirm hyprland
            echo "exec hyprland" >> ~/.xinitrc
            break;;
        6)
            echo "No se instalará ningún entorno de escritorio."
            break;;
        *)
            echo "Opción inválida. Por favor, elige un número entre 1 y ${#options[@]}.";;
    esac
done
