#!/bin/bash

echo "== MONTAJE DE PARTICIONES =="

# Montar el sistema de archivos
mount --mkdir /mnt

# Montar las particiones adicionales
mkdir -p /mnt/home
mount /dev/vg0/home /mnt/home
