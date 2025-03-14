#!/bin/bash
set -e  # Detener el script si hay errores

echo "🚀 Bienvenido a la instalación de Arch Linux con Hyprland y mejoras extra"
echo "🔹 Este script te guiará en la ejecución de los scripts de instalación."
echo ""

# Verificar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    echo "⚠️ Este script debe ejecutarse como root. Usa sudo."
    exit 1
fi

# Preguntar si se desea instalar Hyprland y Ly
read -p "❓ ¿Deseas instalar Hyprland y Ly? (y/n): " install_hyprland
if [[ "$install_hyprland" == "y" ]]; then
    echo "🚀 Ejecutando instalación de Hyprland..."
    ./install_hyprland.sh
    echo "✅ Hyprland instalado correctamente."
fi

# Preguntar si se desea instalar las mejoras adicionales
read -p "❓ ¿Deseas instalar mejoras adicionales? (y/n): " install_extras
if [[ "$install_extras" == "y" ]]; then
    echo "🚀 Ejecutando instalación de extras..."
    ./install_extras.sh
    echo "✅ Mejoras adicionales instaladas correctamente."
fi

echo ""
echo "🎉 Instalación completada. Reinicia tu sistema para aplicar los cambios."
