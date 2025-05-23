#!/bin/bash

# Script de instalación de interfaces gráficas para Arch Linux
# Permite instalar múltiples entornos de escritorio y gestores de ventanas

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Función para imprimir mensajes coloreados
print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[ADVERTENCIA]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_header() { echo -e "${CYAN}$1${NC}"; }

# Verificar si el usuario es root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "No ejecutes este script como root. Usa un usuario normal con sudo."
        exit 1
    fi
}

# Actualizar sistema
update_system() {
    print_status "Actualizando el sistema..."
    sudo pacman -Syu --noconfirm
    print_status "Sistema actualizado correctamente"
}

# Instalar drivers de video
install_video_drivers() {
    print_header "=== INSTALACIÓN DE DRIVERS DE VIDEO ==="
    echo "1) Intel"
    echo "2) NVIDIA (propietario)"
    echo "3) NVIDIA (código abierto - nouveau)"
    echo "4) AMD"
    echo "5) VirtualBox"
    echo "6) VMware"
    echo "7) Omitir"
    echo
    
    read -p "Selecciona tu tarjeta gráfica (1-7): " gpu_choice
    
    case $gpu_choice in
        1)
            print_status "Instalando drivers Intel..."
            sudo pacman -S --noconfirm xf86-video-intel vulkan-intel
            ;;
        2)
            print_status "Instalando drivers NVIDIA propietarios..."
            sudo pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
            ;;
        3)
            print_status "Instalando drivers NVIDIA código abierto..."
            sudo pacman -S --noconfirm xf86-video-nouveau
            ;;
        4)
            print_status "Instalando drivers AMD..."
            sudo pacman -S --noconfirm xf86-video-amdgpu vulkan-radeon
            ;;
        5)
            print_status "Instalando drivers VirtualBox..."
            sudo pacman -S --noconfirm virtualbox-guest-utils xf86-video-vmware
            sudo systemctl enable vboxservice
            ;;
        6)
            print_status "Instalando drivers VMware..."
            sudo pacman -S --noconfirm xf86-video-vmware xf86-input-vmmouse
            ;;
        7)
            print_status "Omitiendo instalación de drivers de video"
            ;;
        *)
            print_warning "Opción inválida, omitiendo drivers de video"
            ;;
    esac
}

# Instalar servidor X y utilidades básicas
install_xorg() {
    print_status "Instalando servidor X y utilidades básicas..."
    sudo pacman -S --noconfirm xorg-server xorg-xinit xorg-xkill xorg-xrandr \
        xorg-xdpyinfo xorg-xsetroot mesa ttf-dejavu ttf-liberation \
        noto-fonts firefox chromium git wget curl unzip zip p7zip \
        htop neofetch tree file-roller
    print_status "Servidor X instalado correctamente"
}

# Función para instalar GNOME
install_gnome() {
    print_status "Instalando GNOME..."
    sudo pacman -S --noconfirm gnome gnome-tweaks gdm
    sudo systemctl enable gdm
    print_status "GNOME instalado correctamente"
}

# Función para instalar KDE Plasma
install_kde() {
    print_status "Instalando KDE Plasma..."
    sudo pacman -S --noconfirm plasma kde-applications sddm
    sudo systemctl enable sddm
    print_status "KDE Plasma instalado correctamente"
}

# Función para instalar XFCE
install_xfce() {
    print_status "Instalando XFCE..."
    sudo pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
    sudo systemctl enable lightdm
    print_status "XFCE instalado correctamente"
}

# Función para instalar MATE
install_mate() {
    print_status "Instalando MATE..."
    sudo pacman -S --noconfirm mate mate-extra lightdm lightdm-gtk-greeter
    sudo systemctl enable lightdm
    print_status "MATE instalado correctamente"
}

# Función para instalar Cinnamon
install_cinnamon() {
    print_status "Instalando Cinnamon..."
    sudo pacman -S --noconfirm cinnamon lightdm lightdm-gtk-greeter
    sudo systemctl enable lightdm
    print_status "Cinnamon instalado correctamente"
}

# Función para instalar LXDE
install_lxde() {
    print_status "Instalando LXDE..."
    sudo pacman -S --noconfirm lxde-gtk3 lightdm lightdm-gtk-greeter
    sudo systemctl enable lightdm
    print_status "LXDE instalado correctamente"
}

# Función para instalar LXQt
install_lxqt() {
    print_status "Instalando LXQt..."
    sudo pacman -S --noconfirm lxqt sddm
    sudo systemctl enable sddm
    print_status "LXQt instalado correctamente"
}

# Función para instalar i3
install_i3() {
    print_status "Instalando i3..."
    sudo pacman -S --noconfirm i3-wm i3status i3lock dmenu xterm \
        feh nitrogen picom thunar
    
    # Crear configuración básica de i3
    mkdir -p ~/.config/i3
    cat << 'EOF' > ~/.config/i3/config
# i3 config file (v4)
set $mod Mod4

# Font for window titles
font pango:DejaVu Sans Mono 8

# Use Mouse+$mod to drag floating windows
floating_modifier $mod

# Start a terminal
bindsym $mod+Return exec xterm

# Kill focused window
bindsym $mod+Shift+q kill

# Start dmenu
bindsym $mod+d exec dmenu_run

# Change focus
bindsym $mod+j focus left
bindsym $mod+k focus down
bindsym $mod+l focus up
bindsym $mod+semicolon focus right

# Move focused window
bindsym $mod+Shift+j move left
bindsym $mod+Shift+k move down
bindsym $mod+Shift+l move up
bindsym $mod+Shift+semicolon move right

# Split orientation
bindsym $mod+h split h
bindsym $mod+v split v

# Enter fullscreen mode
bindsym $mod+f fullscreen toggle

# Restart i3 inplace
bindsym $mod+Shift+r restart

# Exit i3
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -b 'Yes' 'i3-msg exit'"

# Workspaces
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
bindsym $mod+3 workspace 3
bindsym $mod+4 workspace 4
bindsym $mod+5 workspace 5

# Move to workspace
bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
bindsym $mod+Shift+3 move container to workspace 3
bindsym $mod+Shift+4 move container to workspace 4
bindsym $mod+Shift+5 move container to workspace 5

# Status bar
bar {
    status_command i3status
}
EOF
    
    print_status "i3 instalado correctamente"
    print_status "Para iniciar i3, agrega 'exec i3' a ~/.xinitrc y usa 'startx'"
}

# Función para instalar Awesome
install_awesome() {
    print_status "Instalando Awesome WM..."
    sudo pacman -S --noconfirm awesome xterm
    print_status "Awesome WM instalado correctamente"
    print_status "Para iniciar Awesome, agrega 'exec awesome' a ~/.xinitrc y usa 'startx'"
}

# Función para instalar Openbox
install_openbox() {
    print_status "Instalando Openbox..."
    sudo pacman -S --noconfirm openbox openbox-themes obconf \
        tint2 nitrogen thunar xterm
    print_status "Openbox instalado correctamente"
    print_status "Para iniciar Openbox, agrega 'exec openbox-session' a ~/.xinitrc y usa 'startx'"
}

# Función para instalar Bspwm
install_bspwm() {
    print_status "Instalando Bspwm..."
    sudo pacman -S --noconfirm bspwm sxhkd xterm dmenu
    
    # Crear directorios de configuración
    mkdir -p ~/.config/bspwm ~/.config/sxhkd
    
    # Configuración básica de bspwm
    cat << 'EOF' > ~/.config/bspwm/bspwmrc
#!/bin/sh
sxhkd &
bspc monitor -d I II III IV V
bspc config border_width         2
bspc config window_gap          12
bspc config split_ratio          0.52
bspc config borderless_monocle   true
bspc config gapless_monocle      true
EOF
    
    # Configuración básica de sxhkd
    cat << 'EOF' > ~/.config/sxhkd/sxhkdrc
# Terminal
super + Return
    xterm

# Program launcher
super + d
    dmenu_run

# Close window
super + shift + q
    bspc node -c

# Quit bspwm
super + shift + e
    bspc quit
EOF
    
    chmod +x ~/.config/bspwm/bspwmrc
    
    print_status "Bspwm instalado correctamente"
    print_status "Para iniciar Bspwm, agrega 'exec bspwm' a ~/.xinitrc y usa 'startx'"
}

# Mostrar menú de interfaces disponibles
show_gui_menu() {
    clear
    print_header "================================================================"
    print_header "        INSTALADOR DE INTERFACES GRÁFICAS - ARCH LINUX"
    print_header "================================================================"
    echo
    echo -e "${PURPLE}ENTORNOS DE ESCRITORIO COMPLETOS:${NC}"
    echo "1)  GNOME         - Moderno y elegante"
    echo "2)  KDE Plasma    - Potente y personalizable"
    echo "3)  XFCE          - Ligero y funcional"
    echo "4)  MATE          - Tradicional y estable"
    echo "5)  Cinnamon      - Elegante y familiar"
    echo "6)  LXDE          - Muy ligero"
    echo "7)  LXQt          - Ligero y moderno"
    echo
    echo -e "${PURPLE}GESTORES DE VENTANAS:${NC}"
    echo "8)  i3            - Tiling, minimalista"
    echo "9)  Awesome       - Dinámico y configurable"
    echo "10) Openbox       - Ligero y personalizable"
    echo "11) Bspwm         - Tiling, binario"
    echo
    echo "0)  Terminar instalación"
    echo
}

# Procesar selección del usuario
process_selection() {
    case $1 in
        1) install_gnome ;;
        2) install_kde ;;
        3) install_xfce ;;
        4) install_mate ;;
        5) install_cinnamon ;;
        6) install_lxde ;;
        7) install_lxqt ;;
        8) install_i3 ;;
        9) install_awesome ;;
        10) install_openbox ;;
        11) install_bspwm ;;
        0) return 1 ;;
        *) print_warning "Opción inválida" ;;
    esac
    return 0
}

# Configurar audio
setup_audio() {
    print_status "¿Deseas instalar el sistema de audio? (y/N)"
    read -p "> " install_audio
    
    if [[ $install_audio =~ ^[Yy]$ ]]; then
        print_status "Instalando PipeWire (sistema de audio moderno)..."
        sudo pacman -S --noconfirm pipewire pipewire-alsa pipewire-pulse \
            pipewire-jack wireplumber pavucontrol
        
        # Habilitar servicios de audio para el usuario
        systemctl --user enable pipewire
        systemctl --user enable pipewire-pulse
        
        print_status "Sistema de audio instalado correctamente"
    fi
}

# Instalar fuentes adicionales
install_fonts() {
    print_status "¿Deseas instalar fuentes adicionales? (y/N)"
    read -p "> " install_extra_fonts
    
    if [[ $install_extra_fonts =~ ^[Yy]$ ]]; then
        print_status "Instalando fuentes adicionales..."
        sudo pacman -S --noconfirm ttf-fira-code ttf-roboto ttf-opensans \
            noto-fonts-emoji ttf-hack adobe-source-code-pro-fonts
        print_status "Fuentes adicionales instaladas"
    fi
}

# Función principal
main() {
    check_root
    
    print_header "================================================================"
    print_header "        INSTALADOR DE INTERFACES GRÁFICAS - ARCH LINUX"
    print_header "================================================================"
    echo
    print_status "Este script te ayudará a instalar interfaces gráficas en Arch Linux"
    print_status "Puedes instalar múltiples entornos si lo deseas"
    echo
    
    read -p "¿Continuar? (y/N): " continue_install
    if [[ ! $continue_install =~ ^[Yy]$ ]]; then
        print_error "Instalación cancelada"
        exit 0
    fi
    
    # Actualizar sistema
    update_system
    
    # Instalar drivers de video
    install_video_drivers
    
    # Instalar Xorg
    install_xorg
    
    # Configurar audio
    setup_audio
    
    # Instalar fuentes adicionales
    install_fonts
    
    # Menú de selección de interfaces
    selected_interfaces=()
    
    while true; do
        show_gui_menu
        echo -e "${GREEN}Interfaces ya seleccionadas:${NC} ${selected_interfaces[*]}"
        echo
        read -p "Selecciona una interfaz (0 para terminar): " choice
        
        if [[ $choice -eq 0 ]]; then
            break
        fi
        
        if process_selection $choice; then
            case $choice in
                1) selected_interfaces+=("GNOME") ;;
                2) selected_interfaces+=("KDE") ;;
                3) selected_interfaces+=("XFCE") ;;
                4) selected_interfaces+=("MATE") ;;
                5) selected_interfaces+=("Cinnamon") ;;
                6) selected_interfaces+=("LXDE") ;;
                7) selected_interfaces+=("LXQt") ;;
                8) selected_interfaces+=("i3") ;;
                9) selected_interfaces+=("Awesome") ;;
                10) selected_interfaces+=("Openbox") ;;
                11) selected_interfaces+=("Bspwm") ;;
            esac
            
            echo
            print_status "Interfaz instalada correctamente!"
            read -p "Presiona Enter para continuar..."
        fi
    done
    
    # Resumen final
    echo
    print_header "================================================================"
    print_header "                    INSTALACIÓN COMPLETADA"
    print_header "================================================================"
    echo
    
    if [ ${#selected_interfaces[@]} -eq 0 ]; then
        print_warning "No se instalaron interfaces gráficas"
    else
        print_status "Interfaces instaladas: ${selected_interfaces[*]}"
        echo
        print_status "PRÓXIMOS PASOS:"
        
        # Verificar si hay display manager instalado
        if systemctl is-enabled gdm &>/dev/null || systemctl is-enabled sddm &>/dev/null || systemctl is-enabled lightdm &>/dev/null; then
            echo "  1. Reinicia el sistema: sudo reboot"
            echo "  2. El gestor de inicio gráfico se iniciará automáticamente"
        else
            echo "  1. Para gestores de ventanas (i3, Awesome, etc.):"
            echo "     - Agrega 'exec [nombre-wm]' a ~/.xinitrc"
            echo "     - Usa 'startx' para iniciar"
            echo "  2. O instala un display manager:"
            echo "     - sudo pacman -S lightdm lightdm-gtk-greeter"
            echo "     - sudo systemctl enable lightdm"
        fi
        
        echo "  3. Instala aplicaciones adicionales según necesites"
        echo "  4. Configura tu entorno según tus preferencias"
    fi
    
    echo
    print_status "¡Gracias por usar el instalador de interfaces gráficas!"
}

# Ejecutar función principal
main "$@"