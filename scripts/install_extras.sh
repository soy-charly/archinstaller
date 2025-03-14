#!/bin/bash
set -e  # Detener el script si hay errores

echo "🚀 Instalando AUR Helper (yay)..."
pacman -S --noconfirm git base-devel
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si --noconfirm
cd ..
rm -rf yay-bin

echo "🚀 Instalando paquetes adicionales desde repos oficiales..."
pacman -S --noconfirm \
    gvfs gvfs-mtp udiskie \
    tlp tlp-rdw \
    libinput-gestures \
    lxappearance qt5ct qt6ct \
    zsh zsh-autosuggestions zsh-syntax-highlighting

echo "🚀 Instalando paquetes desde AUR..."
yay -S --noconfirm swww hyprpaper nordic-theme papirus-icon-theme

echo "🚀 Habilitando servicios esenciales..."
systemctl enable tlp

echo "🚀 Configurando Zsh como shell predeterminada..."
chsh -s /bin/zsh charly

echo "🚀 Configurando fondo de pantalla..."
mkdir -p /home/charly/Pictures
echo "exec-once = swww init" >> /home/charly/.config/hypr/hyprland.conf
echo "exec-once = swww img /home/charly/Pictures/fondo.png" >> /home/charly/.config/hypr/hyprland.conf

echo "✅ Instalación de extras completada. Reinicia para aplicar cambios."
