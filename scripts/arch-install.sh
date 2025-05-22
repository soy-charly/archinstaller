#!/bin/bash

set -e

echo "=== Arch Linux Instalador Automatizado ==="

# Confirmar estar en entorno live
if ! ping -c1 archlinux.org &>/dev/null; then
    echo "❌ No tienes conexión a internet. Conéctate y vuelve a intentarlo."
    exit 1
fi

# Listar discos
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

# Seleccionar particiones
read -p "🖴 Ingresa la partición para /boot (ej: /dev/sda1): " BOOT_PART
read -p "📦 Ingresa la partición para / (ej: /dev/sda2): " ROOT_PART

# Confirmar formato
read -p "¿Formatear $BOOT_PART como FAT32? (s/N): " FORMAT_BOOT
read -p "¿Formatear $ROOT_PART como ext4? (s/N): " FORMAT_ROOT

[[ "$FORMAT_BOOT" =~ ^[sS]$ ]] && mkfs.fat -F32 $BOOT_PART
[[ "$FORMAT_ROOT" =~ ^[sS]$ ]] && mkfs.ext4 $ROOT_PART

# Montaje
mount $ROOT_PART /mnt
mkdir -p /mnt/boot
mount $BOOT_PART /mnt/boot

# Configurar el sistema base
pacstrap /mnt base linux linux-firmware vim sudo networkmanager grub efibootmgr

# Generar fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Datos del usuario
read -p "👤 Nombre del usuario: " USERNAME
read -s -p "🔐 Contraseña del usuario: " PASSWORD
echo
read -p "🖥️ Elige entorno de escritorio (gnome/kde/xfce): " DESKTOP

# Copiar script post-install
cat <<EOF > /mnt/post-install.sh
#!/bin/bash
set -e

echo "Configurando zona horaria y localización..."
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=es" > /etc/vconsole.conf

echo "Configurar hostname y red..."
echo archpc > /etc/hostname
cat <<EOT > /etc/hosts
127.0.0.1 localhost
::1       localhost
127.0.1.1 archpc.localdomain archpc
EOT

echo "Habilitar servicios..."
systemctl enable NetworkManager

echo "Instalar GRUB..."
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo "Crear usuario $USERNAME..."
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "root:$PASSWORD" | chpasswd
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "Instalar entorno de escritorio: $DESKTOP"
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
    echo "Entorno de escritorio no válido. No se instalará interfaz gráfica."
    ;;
esac

EOF

chmod +x /mnt/post-install.sh

arch-chroot /mnt /post-install.sh

echo "✅ Instalación completa. Puedes reiniciar el sistema."
