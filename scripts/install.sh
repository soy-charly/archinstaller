#!/bin/bash

set -e

echo "Bienvenido al instalador de Arch Linux"

# Cargar scripts externos
source ./partitions.sh
source ./base_install.sh
source ./system_config.sh
source ./desktop_install.sh

echo "Instalación completada. Puede reiniciar ahora."
