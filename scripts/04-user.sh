#!/bin/bash

echo "== CONFIGURACIÓN DE USUARIO =="

# Crear el usuario
arch-chroot /mnt /bin/bash <<EOF
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$USERPASS" | chpasswd
echo "root:$ROOTPASS" | chpasswd
EOF

# Habilitar sudo para el usuario
arch-chroot /mnt pacman -S --noconfirm sudo
arch-chroot /mnt /bin/bash <<EOF
echo "$USERNAME ALL=(ALL) ALL" > /etc/sudoers.d/010_$USERNAME
EOF
