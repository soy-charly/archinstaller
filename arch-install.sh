#!/bin/bash

# Script de instalación automática de Arch Linux
# ADVERTENCIA: Este script formateará completamente el disco seleccionado
# Úsalo bajo tu propio riesgo

set -e  # Salir si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes coloreados
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ADVERTENCIA]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estamos en modo UEFI
check_uefi() {
    if [ ! -d /sys/firmware/efi ]; then
        print_error "Este script está diseñado para sistemas UEFI. Sistema BIOS no soportado."
        exit 1
    fi
    print_status "Sistema UEFI detectado correctamente"
}

# Configurar variables del sistema
configure_system() {
    echo -e "${BLUE}=== CONFIGURACIÓN DEL SISTEMA ===${NC}"
    
    # Seleccionar disco
    print_status "Discos disponibles:"
    lsblk -d -o NAME,SIZE,MODEL
    echo
    read -p "Ingresa el dispositivo a usar (ej: sda, nvme0n1): " DISK
    DISK="/dev/$DISK"
    
    if [ ! -b "$DISK" ]; then
        print_error "El dispositivo $DISK no existe"
        exit 1
    fi
    
    print_warning "Se formateará completamente $DISK"
    read -p "¿Continuar? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        print_error "Instalación cancelada"
        exit 1
    fi
    
    # Configurar hostname
    read -p "Nombre del equipo (hostname): " HOSTNAME
    
    # Configurar usuario
    read -p "Nombre de usuario: " USERNAME
    
    # Configurar zona horaria
    print_status "Configurando zona horaria..."
    echo "Ejemplos: America/Mexico_City, Europe/Madrid, America/New_York"
    read -p "Zona horaria: " TIMEZONE
    
    # Configurar idioma del teclado
    print_status "Configuraciones de teclado comunes:"
    echo "es (Español), us (Inglés US), latam (Latinoamérica)"
    read -p "Distribución del teclado: " KEYBOARD
    
    # Configurar locale
    echo "Locales comunes: es_ES.UTF-8, es_MX.UTF-8, en_US.UTF-8"
    read -p "Locale del sistema: " LOCALE
}

# Configurar red
setup_network() {
    print_status "Configurando conexión de red..."
    
    # Verificar conexión a internet
    if ping -c 3 archlinux.org &> /dev/null; then
        print_status "Conexión a internet verificada"
    else
        print_error "No hay conexión a internet. Configúrala manualmente."
        print_status "Para WiFi usa: iwctl"
        exit 1
    fi
    
    # Sincronizar reloj del sistema
    timedatectl set-ntp true
    print_status "Reloj del sistema sincronizado"
}

# Particionar disco
partition_disk() {
    print_status "Particionando disco $DISK..."
    
    # Crear tabla de particiones GPT
    parted -s "$DISK" mklabel gpt
    
    # Crear partición EFI (512MB)
    parted -s "$DISK" mkpart primary fat32 1MiB 513MiB
    parted -s "$DISK" set 1 esp on
    
    # Crear partición swap (4GB)
    parted -s "$DISK" mkpart primary linux-swap 513MiB 4.5GiB
    
    # Crear partición root (resto del disco)
    parted -s "$DISK" mkpart primary ext4 4.5GiB 100%
    
    print_status "Particiones creadas correctamente"
    
    # Determinar nombres de particiones
    if [[ $DISK == *"nvme"* ]]; then
        EFI_PART="${DISK}p1"
        SWAP_PART="${DISK}p2"
        ROOT_PART="${DISK}p3"
    else
        EFI_PART="${DISK}1"
        SWAP_PART="${DISK}2"
        ROOT_PART="${DISK}3"
    fi
}

# Formatear particiones
format_partitions() {
    print_status "Formateando particiones..."
    
    # Formatear partición EFI
    mkfs.fat -F32 "$EFI_PART"
    print_status "Partición EFI formateada"
    
    # Formatear y activar swap
    mkswap "$SWAP_PART"
    swapon "$SWAP_PART"
    print_status "Partición swap configurada"
    
    # Formatear partición root
    mkfs.ext4 "$ROOT_PART"
    print_status "Partición root formateada"
}

# Montar particiones
mount_partitions() {
    print_status "Montando particiones..."
    
    # Montar partición root
    mount "$ROOT_PART" /mnt
    
    # Crear y montar directorio EFI
    mkdir -p /mnt/boot/efi
    mount "$EFI_PART" /mnt/boot/efi
    
    print_status "Particiones montadas correctamente"
}

# Instalar sistema base
install_base() {
    print_status "Instalando sistema base..."
    
    # Actualizar keyring
    pacman -Sy --noconfirm archlinux-keyring
    
    # Instalar paquetes base
    pacstrap /mnt base base-devel linux linux-firmware \
        networkmanager grub efibootmgr \
        nano vim git wget curl \
        sudo man-db man-pages
    
    print_status "Sistema base instalado"
}

# Generar fstab
generate_fstab() {
    print_status "Generando fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab
    print_status "fstab generado correctamente"
}

# Configurar sistema en chroot
configure_chroot() {
    print_status "Configurando sistema..."
    
    # Crear script de configuración para chroot
    cat << EOF > /mnt/configure_system.sh
#!/bin/bash

# Configurar zona horaria
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

# Configurar locale
echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf

# Configurar teclado
echo "KEYMAP=$KEYBOARD" > /etc/vconsole.conf

# Configurar hostname
echo "$HOSTNAME" > /etc/hostname

# Configurar hosts
cat << HOSTS_EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS_EOF

# Configurar contraseña de root
echo "Configura la contraseña de root:"
passwd

# Crear usuario
useradd -m -G wheel,audio,video,optical,storage -s /bin/bash $USERNAME
echo "Configura la contraseña para $USERNAME:"
passwd $USERNAME

# Configurar sudo
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Instalar y configurar GRUB
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Habilitar servicios
systemctl enable NetworkManager

echo "¡Configuración completada!"
EOF

    # Ejecutar script en chroot
    chmod +x /mnt/configure_system.sh
    arch-chroot /mnt ./configure_system.sh
    rm /mnt/configure_system.sh
}

# Función principal
main() {
    echo -e "${BLUE}===============================================${NC}"
    echo -e "${BLUE}    INSTALADOR AUTOMÁTICO DE ARCH LINUX${NC}"
    echo -e "${BLUE}===============================================${NC}"
    echo
    
    print_warning "Este script instalará Arch Linux y formateará el disco seleccionado"
    print_warning "Asegúrate de hacer respaldos antes de continuar"
    echo
    
    read -p "¿Deseas continuar? (y/N): " continue_install
    if [[ ! $continue_install =~ ^[Yy]$ ]]; then
        print_error "Instalación cancelada"
        exit 0
    fi
    
    check_uefi
    configure_system
    setup_network
    partition_disk
    format_partitions
    mount_partitions
    install_base
    generate_fstab
    configure_chroot
    
    echo
    echo -e "${GREEN}===============================================${NC}"
    echo -e "${GREEN}    ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!${NC}"
    echo -e "${GREEN}===============================================${NC}"
    echo
    print_status "El sistema está listo. Puedes reiniciar con: reboot"
    print_status "Recuerda remover el medio de instalación"
    echo
    print_status "Próximos pasos recomendados después del reinicio:"
    echo "  1. Conectar a internet: nmcli device wifi connect 'SSID' password 'contraseña'"
    echo "  2. Actualizar sistema: sudo pacman -Syu"
    echo "  3. Instalar entorno de escritorio (opcional)"
    echo "  4. Configurar AUR helper como yay o paru"
}

# Ejecutar función principal
main "$@"