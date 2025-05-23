#!/bin/bash

set -e

echo "=== Arch Linux Instalador Automatizado (UEFI) ==="

# Verificar UEFI
if [[ ! -d /sys/firmware/efi ]]; then
  echo "Este sistema no está arrancado en modo UEFI. Reinicia y selecciona arranque UEFI."
  exit 1
fi

# Mostrar discos
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

# Particiones
read -p "Partición EFI (/boot/efi) (ej: /dev/sda1): " BOOT_PART
read -p "Partición raíz (/) (ej: /dev/sda2): " ROOT_PART

# Formatear si se desea
read -p "¿Formatear $BOOT_PART como FAT32? (s/N): " FORMAT_BOOT
read -p "¿Formatear $ROOT_PART como ext4? (s/N): " FORMAT_ROOT

[[ "$FORMAT_BOOT" =~ ^[sS]$ ]] && mkfs.fat -F32 "$BOOT_PART"
[[ "$FORMAT_ROOT" =~ ^[sS]$ ]] && mkfs.ext4 "$ROOT_PART"

# Montaje
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot/efi
mount "$BOOT_PART" /mnt/boot/efi

# Base del sistema
echo "Instalando sistema base..."
pacstrap /mnt base linux linux-firmware vim sudo networkmanager grub efibootmgr dosfstools mtools

# Generar fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Preguntar por usuario y escritorio
read -p "Nombre de usuario: " USERNAME
read -s -p "Contraseña: " PASSWORD
echo
read -p "Entorno de escritorio (gnome/kde/xfce): " DESKTOP

# Crear script en chroot
cat <<EOF > /mnt/post-install.sh
#!/bin/bash
set -e

ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=es" > /etc/vconsole.conf

echo archpc > /etc/hostname
cat <<EOT > /etc/hosts
127.0.0.1 localhost
::1       localhost
127.0.1.1 archpc.localdomain archpc
EOT

systemctl enable NetworkManager

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

case "$DESKTOP" in
  gnome)
    pacman -Sy --noconfirm gnome gdm
    systemctl enable gdm
    ;;
  kde)
    pacman -Sy --noconfirm plasma kde-applications sddm
    systemctl enable sddm
    ;;
  xfce)
    pacman -Sy --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
    systemctl enable lightdm
    ;;
  *)
    echo "Entorno no válido. No se instalará interfaz gráfica."
    ;;
esac

echo "Configuración completa."
EOF

chmod +x /mnt/post-install.sh

# Ejecutar en chroot
arch-chroot /mnt /post-install.sh
rm /mnt/post-install.sh

echo "Instalación completada. Puedes reiniciar el sistema."
