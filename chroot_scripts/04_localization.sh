#!/bin/bash

echo "### Configuración regional ###"
LOCALE=$(validate_input "Ingresa el locale (ej: es_MX.UTF-8)")
KEYLAYOUT=$(validate_input "Layout de teclado (ej: la-latin1)")

sed -i "s/^#$LOCALE/$LOCALE/" /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf
echo "KEYMAP=$KEYLAYOUT" > /etc/vconsole.conf
