#!/bin/bash

echo "== CONFIGURACIÓN INICIAL =="

# Elegir idioma
echo "Selecciona tu idioma:"
select LANG_OPTION in "Español (es_ES.UTF-8)" "Inglés (en_US.UTF-8)" "Salir"; do
  case $LANG_OPTION in
    "Español (es_ES.UTF-8)")
      LANG="es_ES.UTF-8"
      KEYMAP="es"
      break
      ;;
    "Inglés (en_US.UTF-8)")
      LANG="en_US.UTF-8"
      KEYMAP="us"
      break
      ;;
    "Salir")
      echo "Saliendo..."
      exit 1
      ;;
    *)
      echo "Opción inválida, selecciona de nuevo."
      ;;
  esac
done

# Elegir disco
echo "Selecciona el disco para la instalación:"
DISK=$(lsblk -d -p -n -o NAME | fzf --prompt "Elige el disco de instalación: ")

# Elegir el sistema de archivos
echo "Selecciona el sistema de archivos:"
select FS_OPTION in "ext4" "btrfs" "xfs" "Salir"; do
  case $FS_OPTION in
    "ext4")
      FS_TYPE="ext4"
      break
      ;;
    "btrfs")
      FS_TYPE="btrfs"
      break
      ;;
    "xfs")
      FS_TYPE="xfs"
      break
      ;;
    "Salir")
      echo "Saliendo..."
      exit 1
      ;;
    *)
      echo "Opción inválida, selecciona de nuevo."
      ;;
  esac
done

# Elegir entorno de escritorio
echo "Selecciona el entorno de escritorio:"
select DESKTOP_OPTION in "Hyprland" "GNOME" "Plasma" "XFCE" "Cinnamon" "MATE" "LXQt" "Budgie" "i3" "Ninguno (solo CLI)" "Salir"; do
  case $DESKTOP_OPTION in
    "Hyprland")
      DESKTOP_ENV="Hyprland"
      break
      ;;
    "GNOME")
      DESKTOP_ENV="GNOME"
      break
      ;;
    "Plasma")
      DESKTOP_ENV="Plasma"
      break
      ;;
    "XFCE")
      DESKTOP_ENV="XFCE"
      break
      ;;
    "Cinnamon")
      DESKTOP_ENV="Cinnamon"
      break
      ;;
    "MATE")
      DESKTOP_ENV="MATE"
      break
      ;;
    "LXQt")
      DESKTOP_ENV="LXQt"
      break
      ;;
    "Budgie")
      DESKTOP_ENV="Budgie"
      break
      ;;
    "i3")
      DESKTOP_ENV="i3"
      break
      ;;
    "Ninguno (solo CLI)")
      DESKTOP_ENV="Ninguno"
      break
      ;;
    "Salir")
      echo "Saliendo..."
      exit 1
      ;;
    *)
      echo "Opción inválida, selecciona de nuevo."
      ;;
  esac
done

# Elegir nombre del host
echo "Introduce el nombre de tu equipo (hostname):"
read HOSTNAME

# Elegir usuario y contraseña
echo "Introduce el nombre de usuario:"
read USERNAME
echo "Introduce la contraseña del usuario:"
read -s USERPASS
echo "Introduce la contraseña de root:"
read -s ROOTPASS

# Mostrar resumen de la configuración
echo "Resumen de la configuración:"
echo "Idioma: $LANG"
echo "Mapa de teclas: $KEYMAP"
echo "Disco seleccionado: $DISK"
echo "Sistema de archivos: $FS_TYPE"
echo "Entorno de escritorio: $DESKTOP_ENV"
echo "Nombre de host: $HOSTNAME"
echo "Usuario: $USERNAME"

# Confirmar configuración
echo "¿Es correcta la configuración? (s/n)"
read CONFIRM
if [[ $CONFIRM != "s" && $CONFIRM != "S" ]]; then
  echo "Reiniciando configuración..."
  exec $0
fi

# Exportar configuración para los scripts posteriores
export LANG KEYMAP DISK FS_TYPE DESKTOP_ENV HOSTNAME USERNAME USERPASS ROOTPASS

echo "Configuración completada. Continuando con la instalación..."
