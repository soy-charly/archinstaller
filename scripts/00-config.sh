#!/bin/bash

echo "========================================"
echo "  BIENVENIDO AL CONFIGURADOR INICIAL"
echo "========================================"

# Elegir idioma
while true; do
  echo -e "\nSelecciona tu idioma:"
  echo "1) Español (es_ES.UTF-8)"
  echo "2) Inglés (en_US.UTF-8)"
  echo "3) Salir"
  read -p "Elige una opción (1-3) [1]: " LANG_OPTION
  LANG_OPTION=${LANG_OPTION:-1}

  case $LANG_OPTION in
    1)
      LANG="es_ES.UTF-8"
      KEYMAP="es"
      break
      ;;
    2)
      LANG="en_US.UTF-8"
      KEYMAP="us"
      break
      ;;
    3)
      echo "Saliendo del configurador. ¡Hasta luego!"
      exit 0
      ;;
    *)
      echo "⚠️ Opción inválida. Por favor, selecciona una opción válida."
      ;;
  esac
done

# Elegir disco
while true; do
  echo -e "\nSelecciona el disco para la instalación:"
  DISK=$(lsblk -d -p -n -o NAME,SIZE | fzf --prompt "Elige el disco de instalación: ")
  if [[ -n $DISK ]]; then
    echo "Has seleccionado el disco: $DISK"
    read -p "¿Es correcto? (s/n) [s]: " CONFIRM_DISK
    CONFIRM_DISK=${CONFIRM_DISK:-s}
    [[ $CONFIRM_DISK =~ ^[sS]$ ]] && break
  else
    echo "⚠️ No se seleccionó ningún disco. Inténtalo de nuevo."
  fi
done

# Elegir el sistema de archivos
while true; do
  echo -e "\nSelecciona el sistema de archivos:"
  select FS_OPTION in "ext4" "btrfs" "xfs" "Salir"; do
    case $FS_OPTION in
      "ext4"|"btrfs"|"xfs")
        FS_TYPE=$FS_OPTION
        echo "Has seleccionado: $FS_TYPE"
        break 2
        ;;
      "Salir")
        echo "Saliendo del configurador. ¡Hasta luego!"
        exit 0
        ;;
      *)
        echo "⚠️ Opción inválida. Por favor, selecciona una opción válida."
        ;;
    esac
  done
done

# Elegir entorno de escritorio
while true; do
  echo -e "\nSelecciona el entorno de escritorio:"
  select DESKTOP_OPTION in "Hyprland" "GNOME" "Plasma" "XFCE" "Cinnamon" "MATE" "LXQt" "Budgie" "i3" "Ninguno (solo CLI)" "Salir"; do
    case $DESKTOP_OPTION in
      "Hyprland"|"GNOME"|"Plasma"|"XFCE"|"Cinnamon"|"MATE"|"LXQt"|"Budgie"|"i3"|"Ninguno (solo CLI)")
        DESKTOP_ENV=$DESKTOP_OPTION
        echo "Has seleccionado: $DESKTOP_ENV"
        break 2
        ;;
      "Salir")
        echo "Saliendo del configurador. ¡Hasta luego!"
        exit 0
        ;;
      *)
        echo "⚠️ Opción inválida. Por favor, selecciona una opción válida."
        ;;
    esac
  done
done

# Elegir tamaño de la partición /home
while true; do
  echo -e "\nSelecciona el tamaño de la partición /home:"
  case $DESKTOP_ENV in
    "Hyprland"|"i3")
      echo "Recomendación: 20-30 GB (entornos ligeros)."
      ;;
    "GNOME"|"Plasma"|"Cinnamon"|"MATE"|"LXQt"|"Budgie")
      echo "Recomendación: 50-100 GB (entornos completos)."
      ;;
    "XFCE")
      echo "Recomendación: 30-50 GB (entorno intermedio)."
      ;;
    "Ninguno (solo CLI)")
      echo "Recomendación: 10-20 GB (sin entorno gráfico)."
      ;;
  esac
  read -p "Introduce el tamaño en GB (ejemplo: 50) [50]: " HOME_SIZE
  HOME_SIZE=${HOME_SIZE:-50}
  if [[ $HOME_SIZE =~ ^[0-9]+$ && $HOME_SIZE -gt 0 ]]; then
    echo "Has seleccionado: ${HOME_SIZE}GB para /home."
    read -p "¿Es correcto? (s/n) [s]: " CONFIRM_HOME_SIZE
    CONFIRM_HOME_SIZE=${CONFIRM_HOME_SIZE:-s}
    [[ $CONFIRM_HOME_SIZE =~ ^[sS]$ ]] && break
  else
    echo "⚠️ Tamaño inválido. Por favor, introduce un número válido."
  fi
done

# Elegir nombre del host
while true; do
  echo -e "\nIntroduce el nombre de tu equipo (hostname):"
  read -p "Hostname [archlinux]: " HOSTNAME
  HOSTNAME=${HOSTNAME:-archlinux}
  echo "Has introducido: $HOSTNAME"
  read -p "¿Es correcto? (s/n) [s]: " CONFIRM_HOSTNAME
  CONFIRM_HOSTNAME=${CONFIRM_HOSTNAME:-s}
  [[ $CONFIRM_HOSTNAME =~ ^[sS]$ ]] && break
done

# Elegir usuario y contraseña
while true; do
  echo -e "\nIntroduce el nombre de usuario:"
  read -p "Usuario [user]: " USERNAME
  USERNAME=${USERNAME:-user}
  echo "Introduce la contraseña del usuario:"
  read -s USERPASS
  echo -e "\nIntroduce la contraseña de root:"
  read -s ROOTPASS
  echo -e "\nUsuario: $USERNAME"
  read -p "¿Es correcto? (s/n) [s]: " CONFIRM_USER
  CONFIRM_USER=${CONFIRM_USER:-s}
  [[ $CONFIRM_USER =~ ^[sS]$ ]] && break
done

# Mostrar resumen de la configuración
echo -e "\n========================================"
echo "          RESUMEN DE LA CONFIGURACIÓN"
echo "========================================"
echo "Idioma: $LANG"
echo "Mapa de teclas: $KEYMAP"
echo "Disco seleccionado: $DISK"
echo "Sistema de archivos: $FS_TYPE"
echo "Entorno de escritorio: $DESKTOP_ENV"
echo "Tamaño de /home: ${HOME_SIZE}GB"
echo "Nombre de host: $HOSTNAME"
echo "Usuario: $USERNAME"
echo "========================================"

# Confirmar configuración
while true; do
  read -p "¿Es correcta la configuración? (s/n) [s]: " CONFIRM
  CONFIRM=${CONFIRM:-s}
  if [[ $CONFIRM =~ ^[sS]$ ]]; then
    echo "Configuración confirmada. Continuando con la instalación..."
    break
  elif [[ $CONFIRM =~ ^[nN]$ ]]; then
    echo "Reiniciando configuración..."
    exec $0
  else
    echo "⚠️ Responde con 's' para sí o 'n' para no."
  fi
done

# Exportar configuración para los scripts posteriores
export LANG KEYMAP DISK FS_TYPE DESKTOP_ENV HOSTNAME USERNAME USERPASS ROOTPASS HOME_SIZE
