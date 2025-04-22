#!/bin/bash

echo "### Instalando sistema base ###"
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/fstab
