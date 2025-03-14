#!/bin/bash

set -e

echo "Bienvenido al instalador de Arch Linux"

# Selección de particiones
echo "Lista de discos disponibles:"
lsblk
read -p "Ingrese la partición para la raíz del sistema (ejemplo: /dev/sdX1 o /dev/nvme0n1p1): " ROOT_PARTITION
read -p "Ingrese la partición para /boot (ejemplo: /dev/sdX2 o /dev/nvme0n1p2): " BOOT_PARTITION

# Formateo y montaje
mkfs.ext4 $ROOT_PARTITION
mkfs.fat -F32 $BOOT_PARTITION
mount $ROOT_PARTITION /mnt
mkdir -p /mnt/boot
mount $BOOT_PARTITION /mnt/boot

# Instalación de Arch Linux
pacstrap /mnt base linux linux-firmware nano

genfstab -U /mnt >> /mnt/etc/fstab

# Configuración del sistema
echo "Configurando el sistema..."
arch-chroot /mnt bash -c "
    ln -sf /usr/share/zoneinfo/$(tzselect) /etc/localtime
    hwclock --systohc
    sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf
    echo 'KEYMAP=us' > /etc/vconsole.conf
    read -p 'Ingrese un nombre para su equipo: ' HOSTNAME
    echo \$HOSTNAME > /etc/hostname
    echo '127.0.0.1    localhost' >> /etc/hosts
    echo '::1          localhost' >> /etc/hosts
    echo '127.0.1.1    \$HOSTNAME.localdomain \$HOSTNAME' >> /etc/hosts
    pacman -Sy --noconfirm grub efibootmgr networkmanager sudo
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg
    systemctl enable NetworkManager

    # Creación de usuario
    read -p 'Ingrese su nombre de usuario: ' USERNAME
    useradd -m -G wheel -s /bin/bash \$USERNAME
    echo 'Establezca la contraseña para \$USERNAME:'
    passwd \$USERNAME
    echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

    # Creación de usuario root opcional
    read -p '¿Desea establecer una contraseña para root? (s/n): ' SET_ROOT
    if [[ \$SET_ROOT == 's' ]]; then
        echo 'Establezca la contraseña para root:'
        passwd
    fi

    # Permitir cambio de hostname
    read -p '¿Desea cambiar el hostname después de la instalación? (s/n): ' CHANGE_HOSTNAME
    if [[ \$CHANGE_HOSTNAME == 's' ]]; then
        read -p 'Ingrese el nuevo hostname: ' NEW_HOSTNAME
        echo \$NEW_HOSTNAME > /etc/hostname
        sed -i "s/\$HOSTNAME/\$NEW_HOSTNAME/g" /etc/hosts
    fi
"

# Instalación opcional de Hyprland y Ly
arch-chroot /mnt bash -c "
    read -p '¿Desea instalar Hyprland y Ly? (s/n): ' INSTALL_HYPR
    if [[ \$INSTALL_HYPR == 's' ]]; then
        pacman -S --noconfirm hyprland ly nano kitty waybar rofi dunst alacritty grim slurp xdg-desktop-portal-hyprland xdg-user-dirs polkit-kde-agent
        systemctl enable ly
    fi
"

echo "Instalación completada. Puede reiniciar ahora."
