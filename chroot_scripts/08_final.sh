#!/bin/bash

echo "### Instalando componentes finales ###"
pacman -Sy --noconfirm networkmanager sudo
systemctl enable NetworkManager
