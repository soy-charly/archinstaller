#!/usr/bin/env bash
set -euo pipefail

# Comprobamos que se ejecute como root
if [[ $EUID -ne 0 ]]; then
  echo "Este script debe ejecutarse como root."
  exit 1
fi

echo "=== Instalación interactiva de Arch Linux ==="

# 1) Selección de dispositivo para /boot y /
echo
echo "Listado de discos disponibles:"
lsblk -d -o NAME,SIZE,MODEL
echo

read -rp "Ingresa la ruta del dispositivo para /boot (ej: /dev/sda1): " BOOT_PART
read -rp "Ingresa la ruta del dispositivo para /     (ej: /dev/sda2): " ROOT_PART

# 2) Formatear particiones
echo
echo "Formateando $BOOT_PART como FAT32 para /boot..."
mkfs.fat -F32 "$BOOT_PART"

echo "Formateando $ROOT_PART como ext4 para /..."
mkfs.ext4 "$ROOT_PART"

# 3) Montaje
echo
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot
mount "$BOOT_PART" /mnt/boot

# 4) Instalar paquetes base
echo
echo "Instalando paquetes base (base, linux, linux-firmware, vim, sudo)..."
pacstrap /mnt base linux linux-firmware vim sudo

# 5) Generar fstab
echo
echo "Generando /etc/fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# 6) Configurar chroot
echo
echo "Entrando en chroot para configuración adicional..."
arch-chroot /mnt /bin/bash <<EOF
set -euo pipefail

# Zona horaria
ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime
hwclock --systohc

# Locales
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
read -rp "Nombre del host (hostname): " HOSTNAME
echo "\$HOSTNAME" > /etc/hostname

# Hosts file
cat >> /etc/hosts <<EOT
127.0.0.1   localhost
::1         localhost
127.0.1.1   \$HOSTNAME.localdomain \$HOSTNAME
EOT

# Contraseña de root
echo
echo "Configura la contraseña de root:"
passwd

# Crear usuario y asignar contraseña
echo
read -rp "Nombre de usuario a crear: " USERNAME
useradd -m -G wheel -s /bin/bash "\$USERNAME"
echo "Configura la contraseña de \$USERNAME:"
passwd "\$USERNAME"

# Permisos sudo
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# 7) Selector de entorno de escritorio
echo
echo "Elige entorno de escritorio (o 0 para ninguno):"
echo "  1) GNOME"
echo "  2) KDE Plasma"
echo "  3) Hyprland (Wayland)"
echo "  0) Ninguno"
read -rp "Opción [0-3]: " DE_CHOICE

case "\$DE_CHOICE" in
  1)
    echo "Instalando GNOME..."
    pacman -S --noconfirm xorg gnome gnome-extra gdm
    systemctl enable gdm
    ;;
  2)
    echo "Instalando KDE Plasma..."
    pacman -S --noconfirm xorg plasma sddm kde-applications
    systemctl enable sddm
    ;;
  3)
    echo "Instalando Hyprland y entorno minimal..."
    pacman -S --noconfirm xorg-wayland sway-wayland hyprland waybar kitty \
      firefox wl-clipboard noto-fonts pavucontrol
    # Puedes habilitar un display manager ligero o dejar iniciar desde TTY
    ;;
  0)
    echo "No instalaré ningún entorno de escritorio."
    ;;
  *)
    echo "Opción inválida, continúa sin DE."
    ;;
esac

# 8) Instalar GRUB como gestor de arranque
echo
echo "Instalando GRUB..."
pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo
echo "¡Instalación completada! Sal de chroot y reinicia:"
echo "  arch-chroot /mnt /bin/bash"
echo "  exit"
echo "  exit"
echo "  reboot"
EOF

echo
echo "Recuerda desmontar las particiones e iniciar desde el nuevo sistema:"
echo "  umount -R /mnt"
echo "  reboot"
