#!/bin/bash

# Función para seleccionar partición
select_partition() {
    local prompt=$1
    lsblk
    while true; do
        read -p "$prompt (ej: /dev/sda1): " partition
        if [ -b "$partition" ]; then
            echo $partition
            return
        else
            echo "¡Partición no válida!"
        fi
    done
}

# Función para validar entrada
validate_input() {
    local prompt=$1
    while true; do
        read -p "$prompt: " input
        if [ -n "$input" ]; then
            echo $input
            return
        else
            echo "¡Este campo es obligatorio!"
        fi
    done
}
