#!/bin/bash

#
# Script de Instalación Asistida para Arch Linux
#
# ADVERTENCIA: Este script está diseñado para FORMATEAR las particiones que
# selecciones. Úsalo con extrema precaución.
#

# --- CONFIGURACIÓN DE SEGURIDAD ---
# Salir inmediatamente si un comando falla o si se usa una variable no definida.
set -euo pipefail

# --- FUNCIONES DE UTILIDAD ---

# Muestra un mensaje de cabecera
function print_header() {
    clear
    echo "-------------------------------------------------"
    echo "    Asistente de Instalación de Arch Linux      "
    echo "-------------------------------------------------"
    echo
}

# Muestra un mensaje de error y sale
function die() {
    echo "[ERROR] $1" >&2
    exit 1
}

# --- RECOGIDA DE DATOS DEL USUARIO ---

print_header
echo "¡Bienvenido! Este script te guiará en la instalación de Arch Linux."
echo
echo "ADVERTENCIA: Se borrarán todos los datos de las particiones que elijas."
echo "Asegúrate de tener una copia de seguridad."

# --- GESTIÓN DE PARTICIONES ---

# Función para particionado automático
function auto_partition() {
    lsblk
    echo
    read -p "Introduce el disco que quieres formatear COMPLETAMENTE (ej. /dev/sda): " DISK
    if [ -z "$DISK" ]; then
        die "El disco no puede estar vacío."
    fi

    read -p "¡¡ADVERTENCIA!! El disco $DISK será borrado por completo. ¿Continuar? (s/N): " CONFIRM_DISK
    if [ "$CONFIRM_DISK" != "s" ]; then
        echo "Particionado cancelado."
        exit 0
    fi

    echo ">>> Creando tabla de particiones GPT en $DISK..."
    parted -s "$DISK" mklabel gpt

    echo ">>> Creando partición EFI..."
    parted -s "$DISK" mkpart primary fat32 1MiB 551MiB
    parted -s "$DISK" set 1 esp on

    echo ">>> Creando partición Root..."
    parted -s "$DISK" mkpart primary ext4 551MiB 100%

    # Asignar nombres a las particiones (depende de si es NVMe o SATA)
    if [[ "$DISK" == *"nvme"* ]]; then
        EFI_PARTITION="${DISK}p1"
        ROOT_PARTITION="${DISK}p2"
    else
        EFI_PARTITION="${DISK}1"
        ROOT_PARTITION="${DISK}2"
    fi
    
    echo "Particiones creadas: EFI=$EFI_PARTITION, Root=$ROOT_PARTITION"
    sleep 3
}

# Función para particionado manual
function manual_partition() {
    lsblk
    echo
    read -p "Introduce la partición EFI existente (ej. /dev/sda1): " EFI_PARTITION
    read -p "Introduce la partición Raíz (root) existente (ej. /dev/sda2): " ROOT_PARTITION
    if [ -z "$EFI_PARTITION" ] || [ -z "$ROOT_PARTITION" ]; then
        die "Las particiones no pueden estar vacías."
    fi
}

# Preguntar al usuario
print_header
echo "Gestión de Particiones"
echo "  1) Automático (Borrará un disco entero y creará las particiones)"
echo "  2) Manual (Usar particiones que ya has creado)"
read -p "Elige una opción [1-2]: " PARTITION_CHOICE

case $PARTITION_CHOICE in
    1) auto_partition ;;
    2) manual_partition ;;
    *) die "Opción no válida. Abortando." ;;
esac

# Solicitar información del sistema y usuario
read -p "Introduce el nombre del equipo (hostname): " HOSTNAME
read -p "Introduce el nombre de tu usuario: " USERNAME

# Contraseñas (con confirmación)
read -sp "Introduce la contraseña para 'root': " ROOT_PASSWORD
echo
read -sp "Confirma la contraseña para 'root': " ROOT_PASSWORD_CONFIRM
echo
if [ "$ROOT_PASSWORD" != "$ROOT_PASSWORD_CONFIRM" ]; then
    die "Las contraseñas de root no coinciden."
fi

read -sp "Introduce la contraseña para '$USERNAME': " USER_PASSWORD
echo
read -sp "Confirma la contraseña para '$USERNAME': " USER_PASSWORD_CONFIRM
echo
if [ "$USER_PASSWORD" != "$USER_PASSWORD_CONFIRM" ]; then
    die "Las contraseñas de usuario no coinciden."
fi

# Selección del Entorno de Escritorio (DE)
print_header
echo "Selecciona un Entorno de Escritorio:"
echo "  1) GNOME (Recomendado, moderno y completo)"
echo "  2) KDE Plasma (Altamente personalizable)"
echo "  3) XFCE (Ligero y estable)"
echo "  4) Ninguno (Instalación mínima de consola)"
read -p "Elige una opción [1-4]: " DE_CHOICE

case $DE_CHOICE in
    1) DE_PACKAGES="gnome gdm"; DM_SERVICE="gdm.service" ;;
    2) DE_PACKAGES="plasma sddm"; DM_SERVICE="sddm.service" ;;
    3) DE_PACKAGES="xfce4 xfce4-goodies lightdm lightdm-gtk-greeter"; DM_SERVICE="lightdm.service" ;;
    4) DE_PACKAGES=""; DM_SERVICE="" ;;
    *) die "Opción no válida. Abortando." ;;
esac

# Paquetes adicionales
read -p "Introduce paquetes extra separados por espacios (ej. firefox vlc git) o deja en blanco: " EXTRA_PACKAGES

# --- CONFIRMACIÓN FINAL ---
print_header
echo "Se realizarán las siguientes acciones:"
echo "  - Formatear y usar las siguientes particiones:"
echo "    - EFI:   $EFI_PARTITION"
echo "    - Raíz:  $ROOT_PARTITION"
echo "  - Nombre del equipo: $HOSTNAME"
echo "  - Nombre de usuario: $USERNAME"
echo "  - Entorno de escritorio: ${DE_PACKAGES:-Ninguno}"
echo "  - Paquetes extra: ${EXTRA_PACKAGES:-Ninguno}"
echo
echo "¡¡¡ADVERTENCIA!!! TODOS LOS DATOS EN $EFI_PARTITION y $ROOT_PARTITION SERÁN BORRADOS."
read -p "¿Estás seguro de que quieres continuar? (s/N): " FINAL_CONFIRMATION

if [ "$FINAL_CONFIRMATION" != "s" ]; then
    echo "Instalación cancelada por el usuario."
    exit 0
fi

# --- INICIO DE LA INSTALACIÓN ---

echo ">>> [1/8] Configurando reloj del sistema..."
timedatectl set-ntp true

echo ">>> [2/8] Formateando particiones..."
mkfs.fat -F32 "$EFI_PARTITION"
mkfs.ext4 -F "$ROOT_PARTITION"

echo ">>> [3/8] Montando particiones..."
mount "$ROOT_PARTITION" /mnt
mkdir -p /mnt/boot
mount "$EFI_PARTITION" /mnt/boot

echo ">>> [4/8] Instalando sistema base (esto puede tardar)..."
pacstrap /mnt base base-devel linux linux-firmware nano sudo

echo ">>> [5/8] Generando fstab..."
genfstab -U /mnt >> /mnt/etc/fstab


echo ">>> [6/8] Configurando el sistema dentro del chroot..."
# Usamos un Here Document para ejecutar comandos dentro del chroot de forma segura
arch-chroot /mnt /bin/bash -e <<EOF

# Configuración de Zona Horaria y Reloj
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

# Configuración de Idioma y Localización
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=es_ES.UTF-8" > /etc/locale.conf

# Configuración de Red y Hostname
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts <<HOSTS
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS

# Contraseñas
echo "root:$ROOT_PASSWORD" | chpasswd

# Creación de Usuario
useradd -m -G wheel "$USERNAME"
echo "$USERNAME:$USER_PASSWORD" | chpasswd

# Configuración de Sudo
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel

# Instalación de paquetes de software
echo "Instalando paquetes de arranque, red, escritorio y extras..."
pacman -S --noconfirm --needed grub efibootmgr networkmanager $DE_PACKAGES $EXTRA_PACKAGES

# Configuración del Gestor de Arranque (GRUB)
echo "Instalando GRUB..."
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH --recheck
grub-mkconfig -o /boot/grub/grub.cfg

# Activación de servicios esenciales
echo "Activando servicios..."
systemctl enable NetworkManager
if [ -n "$DM_SERVICE" ]; then
    systemctl enable "$DM_SERVICE"
fi

EOF

echo ">>> [7/8] Desmontando particiones..."
umount -R /mnt

echo ">>> [8/8] ¡Instalación completada!"

# --- FINALIZACIÓN ---
print_header
echo "¡El sistema Arch Linux ha sido instalado con éxito!"
echo
echo "Puedes reiniciar tu ordenador ahora."
echo "Escribe 'reboot' y retira el medio de instalación."
echo "-------------------------------------------------"

exit 0
