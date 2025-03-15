# 🚀 Instalador de Arch Linux

Este es un conjunto de scripts automatizados para instalar Arch Linux con una configuración básica y una opción para instalar Hyprland como entorno de escritorio.

## 📂 Estructura del Proyecto

```bash
arch-install/
│── install.sh              # 🏗️ Script principal
│── partitions.sh           # 🖥️ Selección y formateo de particiones
│── base_install.sh         # 📦 Instalación del sistema base
│── system_config.sh        # ⚙️ Configuración dentro de chroot
│── desktop_install.sh      # 🎨 Instalación opcional de Hyprland y Ly
```

## ✅ Requisitos

- 🌐 Conexión a Internet  
- 💾 Un disco preparado para la instalación de Arch Linux  
- 🏗️ Sistema en modo UEFI  

## 🛠️ Instalación

1. 🔥 Arranca desde una ISO de Arch Linux en modo Live.  
2. 🌐 Conéctate a Internet con `ip a` para verificar la red o usa `wifi-menu` si usas Wi-Fi.  
3. 📥 Instala `git` para poder clonar el repositorio:  
   ```bash
   pacman -Sy git
   ```
4. 📂 Clona este repositorio:  
   ```bash
   git clone https://github.com/tuusuario/arch-install.git
   cd arch-install
   ```
5. 🔑 Da permisos de ejecución a los scripts:  
   ```bash
   chmod +x *.sh
   ```
6. ▶️ Ejecuta el script principal:  
   ```bash
   ./install.sh
   ```

## 🎨 Personalización

Puedes modificar cualquiera de los scripts para adaptarlos a tus necesidades, por ejemplo, añadiendo paquetes adicionales en `base_install.sh` o cambiando la configuración de teclado en `system_config.sh`.

## 🖥️ Opcional: Instalación de Hyprland y Ly

Durante la instalación, se te preguntará si deseas instalar Hyprland y el gestor de inicio Ly. Si eliges "s", se instalarán automáticamente.

## ⚠️ Notas

- ⚡ Este script **borrará** los datos de las particiones seleccionadas. ¡Asegúrate de hacer una copia de seguridad de tus datos importantes antes de ejecutarlo!  
- 📦 La instalación se realiza con `pacstrap` e incluye lo básico: `linux`, `linux-firmware`, `nano`, `sudo`, `grub`, `networkmanager`, etc.  
- 🎮 Si deseas soporte para NVIDIA u otros controladores, puedes añadir los paquetes en `base_install.sh`.  

## 🤝 Contribuciones

Si deseas mejorar este script, puedes hacer un fork y enviar un pull request.
