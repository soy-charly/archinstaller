#!/bin/bash

set -e

echo "Bienvenido al instalador de Arch Linux"

# Cargar scripts externos
source ./scripts/partitions.sh
source ./scripts/base_install.sh
source ./scripts/system_config.sh
source ./scripts/desktop_install.sh

echo "Instalación completada. Puede reiniciar ahora."
