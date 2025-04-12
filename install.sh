#!/bin/bash
set -e

# Llamada al script de configuración para establecer las variables
source "$(dirname "$0")/scripts/00-config.sh"

# Llamada a los scripts modulares
SCRIPTS_DIR="$(dirname "$0")/scripts"
for script in "$SCRIPTS_DIR"/0*-*.sh; do
    bash "$script"
done

echo "✅ Instalación completa. Puedes reiniciar el sistema."
