#!/bin/bash

# Verifica si se ejecuta con privilegios de superusuario
if [ "$EUID" -ne 0 ]; then
    echo "Este script debe ejecutarse con sudo o como root."
    exit 1
fi

# Mueve al directorio donde está el script
cd "$(dirname "$0")"

# Dar permisos de ejecución a los scripts
echo "Otorgando permisos de ejecución a los scripts..."
chmod +x scripts/*.sh

# Ejecutar el script de instalación principal
echo "Iniciando la instalación base..."
./scripts/arch_installer.sh

# Preguntar si quiere instalar los otros scripts
for script in scripts/*.sh; do
    script_name=$(basename "$script")
    
    # Saltar el script principal
    if [[ "$script_name" == "arch_installer.sh" ]]; then
        continue
    fi
    
    # Preguntar si el usuario quiere ejecutar este script
    read -p "¿Quieres ejecutar $script_name? (s/n): " respuesta
    if [[ "$respuesta" == "s" || "$respuesta" == "S" ]]; then
        echo "Ejecutando $script_name..."
        ./"$script"
    else
        echo "Saltando $script_name..."
    fi
done

echo "Instalación completada."
