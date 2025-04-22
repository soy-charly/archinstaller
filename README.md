# Arch Linux Installer Scripts

![Arch Linux Logo](https://archlinux.org/static/logos/archlinux-logo-dark-1200dpi.b42bd35d5916.png)

Scripts modulares para instalar Arch Linux con configuración interactiva. Ideal para instalaciones rápidas y personalizadas.

## Características Principales
- ✔️ Selección interactiva de particiones (BOOT/ROOT)
- 🌍 Configuración automática de zona horaria vía geolocalización
- ⌨️ Selección de layout de teclado e idioma del sistema
- 🖥️ Elección de entorno de escritorio (GNOME, KDE, Xfce, LXQt)
- 👤 Creación automática de usuario con privilegios sudo
- 🚀 Instalación optimizada con paquetes esenciales
- ⚙️ Configuración automática de GRUB según sistema (UEFI/BIOS)

## Requisitos
- Imagen ISO de Arch Linux reciente
- Conexión a Internet activa
- Particiones previamente creadas
- Sistema en modo UEFI o BIOS legado
- Conocimientos básicos de línea de comandos

## Uso

### Opción 1: Clonar repositorio
```bash
# Desde el Live Environment de Arch Linux:
pacman -Sy --noconfirm git
git clone https://github.com/tuusuario/arch-installer.git
cd arch-installer
chmod +x main.sh *.sh chroot_scripts/*.sh
./main.sh
```

### Opción 2: Descarga directa vía curl
```bash
# Desde el Live Environment:
pacman -Sy --noconfirm curl
curl -L https://raw.githubusercontent.com/tuusuario/arch-installer/main/main.sh -o main.sh
chmod +x main.sh
./main.sh
```

## Flujo de Instalación
1. **Preparación**:
   - Conexión a Internet
   - Montaje de particiones
   - Formateo de dispositivos

2. **Instalación Base**:
   - Kernel Linux
   - Firmwares esenciales
   - Generación de fstab

3. **Configuración Chroot**:
   - Zona horaria automática
   - Localización e idiomas
   - Instalación de GRUB
   - Creación de usuario
   - Entorno de escritorio
   - Paquetes adicionales

## Estructura del Proyecto
```
arch-installer/
├── main.sh                       # Script principal
├── functions.sh                  # Funciones comunes
├── 1_partitions.sh               # Particionado y montaje
├── 2_base_install.sh             # Sistema base
├── chroot_scripts/               # Configuraciones en chroot
│   ├── 3_timezone.sh             # Zona horaria automática
│   ├── 4_localization.sh         # Idioma y teclado
│   ├── 5_bootloader.sh           # Instalación de GRUB
│   ├── 6_user.sh                 # Creación de usuario
│   ├── 7_desktop.sh              # Entornos de escritorio
│   └── 8_final.sh                # Toques finales
└── README.md                     # Este archivo
```

## Personalización
### Entornos de Escritorio
Edita `chroot_scripts/7_desktop.sh` para:
- Añadir nuevos entornos
- Cambiar paquetes instalados
- Modificar gestores de pantalla

### Layouts de Teclado
Modifica en `chroot_scripts/4_localization.sh`:
- Listado de layouts soportados
- Configuraciones regionales

### Paquetes Adicionales
Añade en `chroot_scripts/8_final.sh`:
- Controladores específicos
- Herramientas de desarrollo
- Paquetes personalizados

## Contribuciones
1. Haz fork del repositorio
2. Crea una rama:
   ```bash
   git checkout -b mi-mejora
   ```
3. Realiza tus cambios
4. Envía un Pull Request

## Licencia
MIT License - Ver [LICENSE](LICENSE)

## Notas Importantes
⚠️ **ADVERTENCIA**: Este script formateará tus discos  
🔧 Recomendado probar primero en máquina virtual  
📶 Asegurar conexión a Internet antes de ejecutar  
💾 Respalda tus datos importantes antes de continuar  
🔒 Este script no es responsable de la pérdida de datos
