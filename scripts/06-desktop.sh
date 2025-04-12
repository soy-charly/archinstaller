#!/bin/bash

echo "== INSTALACIÓN DE ENTORNO DE ESCRITORIO: ${DESKTOP_ENV:-Ninguno} =="

if [[ -z "$DESKTOP_ENV" ]]; then
    echo "No se instalará entorno gráfico."
    exit 0
fi

arch-chroot /mnt /bin/bash <<EOF
pacman -Sy --noconfirm xorg xorg-xinit network-manager-applet pipewire pipewire-pulse wireplumber

case "$DESKTOP_ENV" in
    GNOME)
        pacman -S --noconfirm gnome gnome-tweaks gdm
        systemctl enable gdm
        ;;
    Plasma)
        pacman -S --noconfirm plasma kde-applications sddm
        systemctl enable sddm
        ;;
    XFCE)
        pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
        systemctl enable lightdm
        ;;
    Cinnamon)
        pacman -S --noconfirm cinnamon lightdm lightdm-gtk-greeter
        systemctl enable lightdm
        ;;
    MATE)
        pacman -S --noconfirm mate mate-extra lightdm lightdm-gtk-greeter
        systemctl enable lightdm
        ;;
    LXQt)
        pacman -S --noconfirm lxqt sddm
        systemctl enable sddm
        ;;
    Budgie)
        pacman -S --noconfirm budgie-desktop gnome-terminal nautilus lightdm lightdm-gtk-greeter
        systemctl enable lightdm
        ;;
    i3)
        pacman -S --noconfirm i3-wm i3status dmenu xterm lightdm lightdm-gtk-greeter
        systemctl enable lightdm
        ;;
    Hyprland)
        pacman -S --noconfirm hyprland waybar xdg-desktop-portal-hyprland foot network-manager-applet \
                                xdg-utils xdg-user-dirs kitty neovim wofi polkit-gnome pipewire wireplumber \
                                ttf-font-awesome noto-fonts noto-fonts-emoji

        systemctl enable NetworkManager
        mkdir -p /home/$USERNAME/.config
        chown -R $USERNAME:$USERNAME /home/$USERNAME
        ;;
esac
EOF
