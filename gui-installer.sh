#!/bin/bash

# Arch Desktop Wizard - Instalador Visual de Escritorios
# Script interactivo con interfaz mejorada y soporte para múltiples escritorios

# Configuración de colores y estilos
declare -A COLORS=(
    [RED]='\033[0;31m'
    [GREEN]='\033[0;32m'
    [YELLOW]='\033[1;33m'
    [BLUE]='\033[0;34m'
    [PURPLE]='\033[0;35m'
    [CYAN]='\033[0;36m'
    [WHITE]='\033[1;37m'
    [GRAY]='\033[0;90m'
    [NC]='\033[0m'
    [BOLD]='\033[1m'
    [DIM]='\033[2m'
)

# Variables globales
SELECTED_DESKTOPS=()
SELECTED_DRIVERS=""
AUDIO_SYSTEM=""
INSTALL_LOG="/tmp/arch_desktop_install.log"

# Funciones de utilidad para la interfaz
print_banner() {
    clear
    echo -e "${COLORS[CYAN]}${COLORS[BOLD]}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║              🚀 ARCH DESKTOP WIZARD v2.0 🚀                ║
    ║                                                              ║
    ║        Instalador Visual de Entornos de Escritorio          ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${COLORS[NC]}"
}

print_section() {
    echo -e "\n${COLORS[BLUE]}${COLORS[BOLD]}▶ $1${COLORS[NC]}"
    echo -e "${COLORS[GRAY]}${'═'*60}${COLORS[NC]}"
}

print_option() {
    local num="$1"
    local name="$2"
    local desc="$3"
    local status="$4"
    
    if [[ "$status" == "selected" ]]; then
        echo -e "${COLORS[GREEN]}[✓] ${COLORS[WHITE]}$num) ${COLORS[BOLD]}$name${COLORS[NC]} ${COLORS[GREEN]}$desc${COLORS[NC]}"
    else
        echo -e "${COLORS[GRAY]}[ ] ${COLORS[WHITE]}$num) ${COLORS[BOLD]}$name${COLORS[NC]} ${COLORS[DIM]}$desc${COLORS[NC]}"
    fi
}

print_success() {
    echo -e "${COLORS[GREEN]}${COLORS[BOLD]}✓${COLORS[NC]} $1"
}

print_warning() {
    echo -e "${COLORS[YELLOW]}${COLORS[BOLD]}⚠${COLORS[NC]} $1"
}

print_error() {
    echo -e "${COLORS[RED]}${COLORS[BOLD]}✗${COLORS[NC]} $1"
}

print_info() {
    echo -e "${COLORS[BLUE]}${COLORS[BOLD]}ℹ${COLORS[NC]} $1"
}

# Función para mostrar progreso
show_progress() {
    local current=$1
    local total=$2
    local desc="$3"
    local percent=$((current * 100 / total))
    local filled=$((percent / 2))
    local empty=$((50 - filled))
    
    printf "\r${COLORS[BLUE]}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %d%% - %s${COLORS[NC]}" "$percent" "$desc"
    
    if [ $current -eq $total ]; then
        echo
    fi
}

# Verificar requisitos del sistema
check_requirements() {
    print_section "VERIFICANDO REQUISITOS DEL SISTEMA"
    
    # Verificar si es Arch Linux
    if ! grep -q "Arch Linux" /etc/os-release 2>/dev/null; then
        print_error "Este script está diseñado para Arch Linux"
        exit 1
    fi
    
    # Verificar conexión a internet
    if ! ping -c 1 google.com &> /dev/null; then
        print_error "Se requiere conexión a internet"
        exit 1
    fi
    
    # Verificar permisos sudo
    if ! sudo -n true 2>/dev/null; then
        print_error "Se requieren permisos sudo"
        exit 1
    fi
    
    print_success "Todos los requisitos verificados"
    sleep 1
}

# Configuración inicial del sistema
system_setup() {
    print_section "CONFIGURACIÓN INICIAL DEL SISTEMA"
    
    # Habilitar multilib si no está habilitado
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        print_info "Habilitando repositorio multilib..."
        sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
    fi
    
    # Actualizar sistema
    print_info "Actualizando sistema y base de datos de paquetes..."
    {
        sudo pacman -Syu --noconfirm
        sudo pacman -S --needed --noconfirm reflector
        sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    } >> "$INSTALL_LOG" 2>&1
    
    print_success "Sistema actualizado correctamente"
}

# Selección de drivers gráficos
select_graphics_driver() {
    print_banner
    print_section "SELECCIÓN DE DRIVERS GRÁFICOS"
    
    echo -e "${COLORS[WHITE]}Selecciona tu tarjeta gráfica:${COLORS[NC]}\n"
    
    print_option "1" "Intel Graphics" "- Gráficos integrados Intel"
    print_option "2" "NVIDIA (Propietario)" "- Drivers oficiales NVIDIA"
    print_option "3" "NVIDIA (Nouveau)" "- Drivers libres para NVIDIA"
    print_option "4" "AMD/ATI" "- Gráficos AMD Radeon"
    print_option "5" "VirtualBox" "- Máquina virtual VirtualBox"
    print_option "6" "VMware" "- Máquina virtual VMware"
    print_option "7" "Genérico" "- Drivers básicos VESA"
    
    echo -e "\n${COLORS[YELLOW]}Tip: Si no estás seguro, selecciona 'Genérico'${COLORS[NC]}"
    
    while true; do
        echo -ne "\n${COLORS[WHITE]}Tu elección [1-7]: ${COLORS[NC]}"
        read -r choice
        
        case $choice in
            1) SELECTED_DRIVERS="intel"; break ;;
            2) SELECTED_DRIVERS="nvidia"; break ;;
            3) SELECTED_DRIVERS="nouveau"; break ;;
            4) SELECTED_DRIVERS="amd"; break ;;
            5) SELECTED_DRIVERS="virtualbox"; break ;;
            6) SELECTED_DRIVERS="vmware"; break ;;
            7) SELECTED_DRIVERS="generic"; break ;;
            *) print_error "Opción inválida. Intenta de nuevo." ;;
        esac
    done
    
    print_success "Driver seleccionado: $SELECTED_DRIVERS"
    sleep 1
}

# Instalación de drivers gráficos
install_graphics_drivers() {
    print_section "INSTALANDO DRIVERS GRÁFICOS"
    
    local packages=""
    
    case $SELECTED_DRIVERS in
        intel)
            packages="xf86-video-intel mesa lib32-mesa vulkan-intel lib32-vulkan-intel"
            ;;
        nvidia)
            packages="nvidia nvidia-utils lib32-nvidia-utils nvidia-settings"
            ;;
        nouveau)
            packages="xf86-video-nouveau mesa lib32-mesa"
            ;;
        amd)
            packages="xf86-video-amdgpu mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon"
            ;;
        virtualbox)
            packages="virtualbox-guest-utils virtualbox-guest-modules-arch"
            sudo systemctl enable vboxservice
            ;;
        vmware)
            packages="xf86-video-vmware xf86-input-vmmouse open-vm-tools"
            sudo systemctl enable vmtoolsd
            ;;
        generic)
            packages="xf86-video-vesa mesa"
            ;;
    esac
    
    if [ -n "$packages" ]; then
        print_info "Instalando: $packages"
        sudo pacman -S --needed --noconfirm $packages >> "$INSTALL_LOG" 2>&1
        print_success "Drivers gráficos instalados"
    fi
}

# Configuración de audio
setup_audio() {
    print_banner
    print_section "CONFIGURACIÓN DE SISTEMA DE AUDIO"
    
    echo -e "${COLORS[WHITE]}Selecciona el sistema de audio:${COLORS[NC]}\n"
    
    print_option "1" "PipeWire" "- Sistema moderno (recomendado)"
    print_option "2" "PulseAudio" "- Sistema tradicional"
    print_option "3" "Omitir" "- No instalar audio"
    
    while true; do
        echo -ne "\n${COLORS[WHITE]}Tu elección [1-3]: ${COLORS[NC]}"
        read -r choice
        
        case $choice in
            1) 
                AUDIO_SYSTEM="pipewire"
                install_pipewire
                break 
                ;;
            2) 
                AUDIO_SYSTEM="pulseaudio"
                install_pulseaudio
                break 
                ;;
            3) 
                AUDIO_SYSTEM="none"
                print_info "Omitiendo instalación de audio"
                break 
                ;;
            *) print_error "Opción inválida. Intenta de nuevo." ;;
        esac
    done
}

install_pipewire() {
    print_info "Instalando PipeWire..."
    sudo pacman -S --needed --noconfirm \
        pipewire pipewire-alsa pipewire-pulse pipewire-jack \
        wireplumber pavucontrol helvum >> "$INSTALL_LOG" 2>&1
    
    # Habilitar servicios para el usuario actual
    systemctl --user enable pipewire pipewire-pulse 2>/dev/null || true
    
    print_success "PipeWire instalado correctamente"
}

install_pulseaudio() {
    print_info "Instalando PulseAudio..."
    sudo pacman -S --needed --noconfirm \
        pulseaudio pulseaudio-alsa pavucontrol >> "$INSTALL_LOG" 2>&1
    print_success "PulseAudio instalado correctamente"
}

# Instalación de componentes base
install_base_components() {
    print_section "INSTALANDO COMPONENTES BASE"
    
    local base_packages=(
        "xorg-server" "xorg-xinit" "xorg-xrandr" "xorg-xsetroot"
        "mesa" "ttf-dejavu" "ttf-liberation" "noto-fonts"
        "firefox" "file-roller" "gvfs" "udisks2"
        "networkmanager" "network-manager-applet"
        "git" "wget" "curl" "unzip" "htop" "neofetch"
    )
    
    for i in "${!base_packages[@]}"; do
        show_progress $((i+1)) ${#base_packages[@]} "Instalando ${base_packages[i]}"
        sudo pacman -S --needed --noconfirm "${base_packages[i]}" >> "$INSTALL_LOG" 2>&1
        sleep 0.1
    done
    
    print_success "Componentes base instalados"
}

# Definición de escritorios disponibles
declare -A DESKTOPS=(
    [gnome]="GNOME|Escritorio moderno y elegante|gnome gnome-tweaks|gdm"
    [kde]="KDE Plasma|Potente y personalizable|plasma kde-applications|sddm"
    [xfce]="XFCE|Ligero y funcional|xfce4 xfce4-goodies|lightdm lightdm-gtk-greeter"
    [mate]="MATE|Tradicional y estable|mate mate-extra|lightdm lightdm-gtk-greeter"
    [cinnamon]="Cinnamon|Elegante y familiar|cinnamon|lightdm lightdm-gtk-greeter"
    [budgie]="Budgie|Moderno y minimalista|budgie-desktop|lightdm lightdm-gtk-greeter"
    [lxqt]="LXQt|Ligero Qt|lxqt|sddm"
    [deepin]="Deepin|Hermoso y elegante|deepin deepin-extra|lightdm lightdm-gtk-greeter"
    [i3]="i3 WM|Gestor de ventanas tiling|i3-wm i3status i3lock dmenu|none"
    [awesome]="Awesome WM|Dinámico y configurable|awesome|none"
    [bspwm]="Bspwm|Tiling binario|bspwm sxhkd|none"
    [qtile]="Qtile|Tiling en Python|qtile|none"
)

# Mostrar selección de escritorios
show_desktop_selection() {
    print_banner
    print_section "SELECCIÓN DE ENTORNOS DE ESCRITORIO"
    
    echo -e "${COLORS[WHITE]}Escritorios disponibles:${COLORS[NC]}\n"
    
    echo -e "${COLORS[PURPLE]}${COLORS[BOLD]}ENTORNOS COMPLETOS:${COLORS[NC]}"
    local desktop_keys=("gnome" "kde" "xfce" "mate" "cinnamon" "budgie" "lxqt" "deepin")
    local num=1
    
    for key in "${desktop_keys[@]}"; do
        IFS='|' read -r name desc packages dm <<< "${DESKTOPS[$key]}"
        local status=""
        [[ " ${SELECTED_DESKTOPS[@]} " =~ " $key " ]] && status="selected"
        print_option "$num" "$name" "- $desc" "$status"
        ((num++))
    done
    
    echo -e "\n${COLORS[PURPLE]}${COLORS[BOLD]}GESTORES DE VENTANAS:${COLORS[NC]}"
    local wm_keys=("i3" "awesome" "bspwm" "qtile")
    
    for key in "${wm_keys[@]}"; do
        IFS='|' read -r name desc packages dm <<< "${DESKTOPS[$key]}"
        local status=""
        [[ " ${SELECTED_DESKTOPS[@]} " =~ " $key " ]] && status="selected"
        print_option "$num" "$name" "- $desc" "$status"
        ((num++))
    done
    
    echo -e "\n${COLORS[GRAY]}${COLORS[BOLD]}ACCIONES:${COLORS[NC]}"
    print_option "99" "Continuar" "- Proceder con la instalación"
    print_option "0" "Salir" "- Cancelar instalación"
}

# Manejar selección de escritorios
handle_desktop_selection() {
    while true; do
        show_desktop_selection
        
        if [ ${#SELECTED_DESKTOPS[@]} -gt 0 ]; then
            echo -e "\n${COLORS[GREEN]}${COLORS[BOLD]}Seleccionados: ${SELECTED_DESKTOPS[*]}${COLORS[NC]}"
        fi
        
        echo -ne "\n${COLORS[WHITE]}Selecciona un escritorio [1-12, 99=continuar, 0=salir]: ${COLORS[NC]}"
        read -r choice
        
        case $choice in
            1) toggle_desktop "gnome" ;;
            2) toggle_desktop "kde" ;;
            3) toggle_desktop "xfce" ;;
            4) toggle_desktop "mate" ;;
            5) toggle_desktop "cinnamon" ;;
            6) toggle_desktop "budgie" ;;
            7) toggle_desktop "lxqt" ;;
            8) toggle_desktop "deepin" ;;
            9) toggle_desktop "i3" ;;
            10) toggle_desktop "awesome" ;;
            11) toggle_desktop "bspwm" ;;
            12) toggle_desktop "qtile" ;;
            99) 
                if [ ${#SELECTED_DESKTOPS[@]} -eq 0 ]; then
                    print_error "Debes seleccionar al menos un escritorio"
                    sleep 2
                else
                    break
                fi
                ;;
            0) 
                print_info "Instalación cancelada"
                exit 0 
                ;;
            *) 
                print_error "Opción inválida"
                sleep 1
                ;;
        esac
    done
}

# Alternar selección de escritorio
toggle_desktop() {
    local desktop="$1"
    
    if [[ " ${SELECTED_DESKTOPS[@]} " =~ " $desktop " ]]; then
        # Remover de la selección
        SELECTED_DESKTOPS=("${SELECTED_DESKTOPS[@]/$desktop}")
        # Limpiar elementos vacíos
        local temp_array=()
        for item in "${SELECTED_DESKTOPS[@]}"; do
            [[ -n "$item" ]] && temp_array+=("$item")
        done
        SELECTED_DESKTOPS=("${temp_array[@]}")
    else
        # Agregar a la selección
        SELECTED_DESKTOPS+=("$desktop")
    fi
}

# Instalación de escritorios seleccionados
install_selected_desktops() {
    print_section "INSTALANDO ESCRITORIOS SELECCIONADOS"
    
    local display_managers=()
    local total_desktops=${#SELECTED_DESKTOPS[@]}
    
    for i in "${!SELECTED_DESKTOPS[@]}"; do
        local desktop="${SELECTED_DESKTOPS[i]}"
        IFS='|' read -r name desc packages dm <<< "${DESKTOPS[$desktop]}"
        
        show_progress $((i+1)) $total_desktops "Instalando $name"
        
        # Instalar paquetes del escritorio
        sudo pacman -S --needed --noconfirm $packages >> "$INSTALL_LOG" 2>&1
        
        # Agregar display manager a la lista si no es 'none'
        if [[ "$dm" != "none" && ! " ${display_managers[@]} " =~ " $dm " ]]; then
            display_managers+=("$dm")
        fi
        
        # Configuraciones específicas
        case $desktop in
            i3) setup_i3_config ;;
            bspwm) setup_bspwm_config ;;
            qtile) setup_qtile_config ;;
        esac
        
        sleep 0.5
    done
    
    # Configurar display manager
    if [ ${#display_managers[@]} -gt 0 ]; then
        setup_display_manager "${display_managers[0]}"
    fi
    
    print_success "Todos los escritorios instalados correctamente"
}

# Configuración específica para i3
setup_i3_config() {
    mkdir -p ~/.config/i3
    cat > ~/.config/i3/config << 'EOF'
# i3 config file
set $mod Mod4
font pango:DejaVu Sans Mono 8

# Autostart
exec --no-startup-id nm-applet

# Keybindings
bindsym $mod+Return exec i3-sensible-terminal
bindsym $mod+Shift+q kill
bindsym $mod+d exec dmenu_run
bindsym $mod+Shift+c reload
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -b 'Yes' 'i3-msg exit'"

# Window management
bindsym $mod+j focus left
bindsym $mod+k focus down
bindsym $mod+l focus up
bindsym $mod+semicolon focus right

bindsym $mod+Shift+j move left
bindsym $mod+Shift+k move down
bindsym $mod+Shift+l move up
bindsym $mod+Shift+semicolon move right

# Workspaces
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
bindsym $mod+3 workspace 3
bindsym $mod+4 workspace 4
bindsym $mod+5 workspace 5

bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
bindsym $mod+Shift+3 move container to workspace 3
bindsym $mod+Shift+4 move container to workspace 4
bindsym $mod+Shift+5 move container to workspace 5

# Layout
bindsym $mod+h split h
bindsym $mod+v split v
bindsym $mod+f fullscreen toggle

# Status bar
bar {
    status_command i3status
}
EOF
}

# Configuración específica para Bspwm
setup_bspwm_config() {
    mkdir -p ~/.config/bspwm ~/.config/sxhkd
    
    cat > ~/.config/bspwm/bspwmrc << 'EOF'
#!/bin/sh
sxhkd &
bspc monitor -d I II III IV V
bspc config border_width         2
bspc config window_gap          12
bspc config split_ratio          0.52
bspc config borderless_monocle   true
bspc config gapless_monocle      true
EOF
    
    cat > ~/.config/sxhkd/sxhkdrc << 'EOF'
super + Return
    alacritty

super + d
    dmenu_run

super + shift + q
    bspc node -c

super + shift + e
    bspc quit
EOF
    
    chmod +x ~/.config/bspwm/bspwmrc
}

# Configuración específica para Qtile
setup_qtile_config() {
    mkdir -p ~/.config/qtile
    cat > ~/.config/qtile/config.py << 'EOF'
from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy

mod = "mod4"
terminal = "alacritty"

keys = [
    Key([mod], "Return", lazy.spawn(terminal)),
    Key([mod], "d", lazy.spawn("dmenu_run")),
    Key([mod, "shift"], "q", lazy.window.kill()),
    Key([mod, "shift"], "r", lazy.restart()),
    Key([mod, "shift"], "e", lazy.shutdown()),
]

groups = [Group(i) for i in "12345"]

for i in groups:
    keys.extend([
        Key([mod], i.name, lazy.group[i.name].toscreen()),
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name)),
    ])

layouts = [
    layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=4),
    layout.Max(),
]

screens = [
    Screen(
        bottom=bar.Bar([
            widget.CurrentLayout(),
            widget.GroupBox(),
            widget.Prompt(),
            widget.WindowName(),
            widget.Systray(),
            widget.Clock(format="%Y-%m-%d %a %I:%M %p"),
        ], 24),
    ),
]
EOF
}

# Configurar display manager
setup_display_manager() {
    local dm="$1"
    
    print_info "Configurando display manager: $dm"
    
    case $dm in
        gdm)
            sudo systemctl enable gdm
            ;;
        sddm)
            sudo systemctl enable sddm
            ;;
        "lightdm lightdm-gtk-greeter")
            sudo systemctl enable lightdm
            ;;
    esac
}

# Instalación de aplicaciones adicionales
install_additional_apps() {
    print_banner
    print_section "APLICACIONES ADICIONALES"
    
    echo -e "${COLORS[WHITE]}¿Deseas instalar aplicaciones adicionales?${COLORS[NC]}\n"
    
    print_option "1" "Paquete Básico" "- Editores, multimedia básico"
    print_option "2" "Paquete Completo" "- Oficina, multimedia, desarrollo"
    print_option "3" "Personalizar" "- Seleccionar individualmente"
    print_option "4" "Omitir" "- No instalar aplicaciones extra"
    
    echo -ne "\n${COLORS[WHITE]}Tu elección [1-4]: ${COLORS[NC]}"
    read -r choice
    
    case $choice in
        1) install_basic_apps ;;
        2) install_complete_apps ;;
        3) install_custom_apps ;;
        4) print_info "Omitiendo aplicaciones adicionales" ;;
        *) print_error "Opción inválida, omitiendo aplicaciones" ;;
    esac
}

install_basic_apps() {
    print_info "Instalando paquete básico..."
    local apps="gedit mousepad vlc gimp libreoffice-fresh thunderbird"
    sudo pacman -S --needed --noconfirm $apps >> "$INSTALL_LOG" 2>&1
    print_success "Paquete básico instalado"
}

install_complete_apps() {
    print_info "Instalando paquete completo..."
    local apps="gedit mousepad code vlc gimp inkscape blender libreoffice-fresh thunderbird discord steam obs-studio"
    sudo pacman -S --needed --noconfirm $apps >> "$INSTALL_LOG" 2>&1
    print_success "Paquete completo instalado"
}

install_custom_apps() {
    print_info "Función de personalización pendiente de implementar"
}

# Resumen final
show_final_summary() {
    print_banner
    print_section "RESUMEN DE INSTALACIÓN"
    
    echo -e "${COLORS[GREEN]}${COLORS[BOLD]}✅ INSTALACIÓN COMPLETADA EXITOSAMENTE${COLORS[NC]}\n"
    
    echo -e "${COLORS[WHITE]}${COLORS[BOLD]}Configuración instalada:${COLORS[NC]}"
    echo -e "  🖥️  Drivers gráficos: ${COLORS[CYAN]}$SELECTED_DRIVERS${COLORS[NC]}"
    echo -e "  🔊  Sistema de audio: ${COLORS[CYAN]}$AUDIO_SYSTEM${COLORS[NC]}"
    echo -e "  🖼️  Escritorios: ${COLORS[CYAN]}${SELECTED_DESKTOPS[*]}${COLORS[NC]}"
    
    echo -e "\n${COLORS[YELLOW]}${COLORS[BOLD]}PRÓXIMOS PASOS:${COLORS[NC]}"
    echo -e "  1️⃣  Reinicia el sistema: ${COLORS[WHITE]}sudo reboot${COLORS[NC]}"
    echo -e "  2️⃣  Selecciona tu escritorio favorito en el login"
    echo -e "  3️⃣  Personaliza tu entorno según tus preferencias"
    
    echo -e "\n${COLORS[GRAY]}Log de instalación guardado en: $INSTALL_LOG${COLORS[NC]}"
    
    echo -ne "\n${COLORS[WHITE]}¿Deseas reiniciar ahora? [y/N]: ${COLORS[NC]}"
    read -r reboot_choice
    
    if [[ $reboot_choice =~ ^[Yy]$ ]]; then
        print_info "Reiniciando sistema..."
        sudo reboot
    else
        print_success "¡Gracias por usar Arch Desktop Wizard!"
    fi
}

# Función principal
main() {
    # Verificar que no se ejecute como root
    if [[ $EUID -eq 0 ]]; then
        print_error "No ejecutes este script como root"
        exit 1
    fi
    
    # Crear log de instalación
    touch "$INSTALL_LOG"
    
    # Flujo principal
    print_banner
    print_info "Iniciando Arch Desktop Wizard..."
    sleep 2
    
    check_requirements
    system_setup
    select_graphics_driver
    install_graphics_drivers
    setup_audio
    install_base_components
    handle_desktop_selection
    install_selected_desktops
    install_additional_apps
    show_final_summary
}

# Ejecutar función principal
main "$@"