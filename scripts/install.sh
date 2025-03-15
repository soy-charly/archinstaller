#!/bin/bash

set -e

echo "Bienvenido al instalador de Arch Linux"
read -p "¿Desea instalar Arch Linux? (s/n): " INSTALL_ARCH
if [[ "$INSTALL_ARCH" =~ ^[Ss]$ ]]; then
  # Cargar scripts externos
  source ./scripts/partitions.sh
  source ./scripts/base_install.sh
  source ./scripts/system_config.sh
  source ./scripts/desktop_install.sh

  echo "Instalación completada. Puede reiniciar ahora."

  else
    echo 'Instalacion abortada'
    exit 1

fi
