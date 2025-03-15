#!/bin/bash

echo "Configurando el sistema..."

read -p "Ingrese un nombre para su equipo: " HOSTNAME
read -p "Ingrese su nombre de usuario: " USERNAME
read -p "Ingrese su zona horaria (ejemplo: Europe/Madrid): " TIMEZONE

arch-chroot /mnt bash <<EOF
    ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    hwclock --systohc
    sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    echo "KEYMAP=us" > /etc/vconsole.conf
    echo "$HOSTNAME" > /etc/hostname
    echo "127.0.0.1    localhost" >> /etc/hosts
    echo "::1          localhost" >> /etc/hosts
    echo "127.0.1.1    $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

    pacman -Sy --noconfirm grub efibootmgr os-prober networkmanager sudo

    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg

    systemctl enable NetworkManager

    useradd -m -G wheel -s /bin/bash "$USERNAME"
    echo "Establezca la contraseña para $USERNAME:"
    passwd "$USERNAME"
    echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

    read -p "¿Desea establecer una contraseña para root? (s/n): " SET_ROOT
    if [[ "\$SET_ROOT" =~ ^[Ss]$ ]]; then
        echo "Establezca la contraseña para root:"
        passwd
    fi
EOF
