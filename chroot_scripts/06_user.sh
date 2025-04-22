#!/bin/bash

USERNAME=$(validate_input "Nombre de usuario")
useradd -m -G wheel -s /bin/bash $USERNAME
passwd $USERNAME

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
