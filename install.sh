#!/bin/bash

# Script principal para la instalación de Arch Linux desde cero

# Ejecutar particionado
source ./scripts/particionado.sh

# Ejecutar configuración del sistema
source ./scripts/configuracion.sh

# Ejecutar instalación de software adicional
source ./scripts/software.sh

echo "La instalación ha finalizado. Reinicia tu sistema."
