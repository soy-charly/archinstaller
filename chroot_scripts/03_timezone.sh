#!/bin/bash

source /installer.conf

echo "### Configurando zona horaria ###"
pacman -Sy --noconfirm curl
TIMEZONE=$(curl -s https://ipapi.co/timezone)
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc
