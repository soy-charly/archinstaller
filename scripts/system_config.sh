#!/bin/bash

echo "Configurando el sistema..."

# Obtener la zona horaria automáticamente usando el servicio ipapi.co
TIMEZONE=$(curl -s https://ipapi.co/timezone)

echo "La zona horaria detectada es: $TIMEZONE"

read -p "Ingrese un nombre para su equipo: " HOSTNAME
read -p "Ingrese su nombre de usuario: " USERNAME

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
    echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
EOF

# Contraseñas fuera de arch-chroot
echo "Establezca la contraseña para el usuario $USERNAME:"
arch-chroot /mnt passwd "$USERNAME"

read -p "¿Desea establecer una contraseña para root? (s/n): " SET_ROOT
if [[ "$SET_ROOT" =~ ^[Ss]$ ]]; then
    echo "Establezca la contraseña para root:"
    arch-chroot /mnt passwd
fi
