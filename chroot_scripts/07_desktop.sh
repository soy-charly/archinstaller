#!/bin/bash

PS3='Elige entorno de escritorio: '
select opt in GNOME KDE Xfce LXQt Ninguno; do
    case $opt in
        GNOME)
            pacman -Sy --noconfirm gnome gdm
            systemctl enable gdm
            break;;
        KDE)
            pacman -Sy --noconfirm plasma sddm
            systemctl enable sddm
            break;;
        Xfce)
            pacman -Sy --noconfirm xfce4 lightdm
            systemctl enable lightdm
            break;;
        LXQt)
            pacman -Sy --noconfirm lxqt sddm
            systemctl enable sddm
            break;;
        Ninguno) break;;
        *) echo "Opción inválida";;
    esac
done
