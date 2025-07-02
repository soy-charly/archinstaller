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
    
    # Mostrar particiones disponibles
    print_status "Particiones disponibles:"
    lsblk -f
    echo
    
    # Seleccionar partición EFI/boot
    print_status "Selecciona la partición EFI/boot (debe ser FAT32, ~512MB):"
    read -p "Partición EFI (ej: sda1, nvme0n1p1): " EFI_INPUT
    EFI_PART="/dev/$EFI_INPUT"
    
    if [ ! -b "$EFI_PART" ]; then
        print_error "La partición $EFI_PART no existe"
        exit 1
    fi
    
    # Seleccionar partición root
    print_status "Selecciona la partición root (/):"
    read -p "Partición root (ej: sda2, nvme0n1p2): " ROOT_INPUT
    ROOT_PART="/dev/$ROOT_INPUT"
    
    if [ ! -b "$ROOT_PART" ]; then
        print_error "La partición $ROOT_PART no existe"
        exit 1
    fi
    
    # Preguntar por partición swap (opcional)
    read -p "¿Tienes partición swap? (y/N): " HAS_SWAP
    if [[ $HAS_SWAP =~ ^[Yy]$ ]]; then
        read -p "Partición swap (ej: sda3, nvme0n1p3): " SWAP_INPUT
        SWAP_PART="/dev/$SWAP_INPUT"
        
        if [ ! -b "$SWAP_PART" ]; then
            print_error "La partición $SWAP_PART no existe"
            exit 1
        fi
    fi
    
    # Confirmar particiones seleccionadas
    echo
    print_warning "Particiones seleccionadas:"
    echo "  EFI/boot: $EFI_PART"
    echo "  Root (/): $ROOT_PART"
    if [[ $HAS_SWAP =~ ^[Yy]$ ]]; then
        echo "  Swap: $SWAP_PART"
    fi
    echo
    print_warning "Las particiones seleccionadas serán FORMATEADAS"
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

# Verificar y preparar particiones
prepare_partitions() {
    print_status "Verificando particiones seleccionadas..."
    
    # Verificar que la partición EFI no esté montada
    if mountpoint -q "$EFI_PART" 2>/dev/null; then
        print_status "Desmontando $EFI_PART..."
        umount "$EFI_PART" || true
    fi
    
    # Verificar que la partición root no esté montada
    if mountpoint -q "$ROOT_PART" 2>/dev/null; then
        print_status "Desmontando $ROOT_PART..."
        umount "$ROOT_PART" || true
    fi
    
    # Verificar partición swap si existe
    if [[ $HAS_SWAP =~ ^[Yy]$ ]]; then
        if swapon --show | grep -q "$SWAP_PART"; then
            print_status "Desactivando swap en $SWAP_PART..."
            swapoff "$SWAP_PART" || true
        fi
    fi
    
    print_status "Particiones preparadas para formateo"
}

# Formatear particiones
format_partitions() {
    print_status "Formateando particiones..."
    
    # Formatear partición EFI
    print_status "Formateando partición EFI $EFI_PART..."
    mkfs.fat -F32 "$EFI_PART"
    print_status "Partición EFI formateada"
    
    # Formatear y activar swap si existe
    if [[ $HAS_SWAP =~ ^[Yy]$ ]]; then
        print_status "Formateando partición swap $SWAP_PART..."
        mkswap "$SWAP_PART"
        swapon "$SWAP_PART"
        print_status "Partición swap configurada"
    fi
    
    # Formatear partición root
    print_status "Formateando partición root $ROOT_PART..."
    mkfs.ext4 -F "$ROOT_PART"
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
    print_warning "Este script instalará Arch Linux en las particiones que selecciones"
    print_warning "Las particiones seleccionadas serán formateadas"
    print_warning "Asegúrate de hacer respaldos antes de continuar"
    echo
    
    print_status "REQUISITOS PREVIOS:"
    echo "  - Debes tener particiones ya creadas:"
    echo "    * Una partición EFI/boot (FAT32, ~512MB)"
    echo "    * Una partición root (/) para el sistema"
    echo "    * Opcionalmente una partición swap"
    echo "  - Si no tienes particiones, usa herramientas como:"
    echo "    * fdisk, cfdisk, parted, o gparted"
    echo
    
    read -p "¿Deseas continuar? (y/N): " continue_install
    if [[ ! $continue_install =~ ^[Yy]$ ]]; then
        print_error "Instalación cancelada"
        exit 0
    fi
    
    check_uefi
    configure_system
    setup_network
    prepare_partitions
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
    echo
    print_status "Si necesitas crear particiones antes de ejecutar este script:"
    echo "  - Usa 'cfdisk /dev/sdX' para crear particiones de forma interactiva"
    echo "  - O 'fdisk /dev/sdX' para el método tradicional"
    echo "  - Recuerda crear: EFI (512MB, tipo EFI), Root (resto, tipo Linux), Swap (opcional)"
}

# Ejecutar función principal
main "$@"