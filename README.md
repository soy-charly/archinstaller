# Instalador Asistido de Arch Linux

Este proyecto proporciona un script para realizar una instalación semi-automatizada de Arch Linux en un sistema con UEFI. El script está diseñado para ser interactivo, solicitando al usuario la información necesaria para configurar el sistema.

**ADVERTENCIA:** Este script está diseñado para **BORRAR Y FORMATEAR** las particiones que selecciones. Todos los datos en esas particiones se perderán de forma permanente. Úsalo bajo tu propio riesgo.

## Características

-   Instalación guiada paso a paso.
-   Soporte para sistemas UEFI.
-   Creación de usuario y contraseña.
-   Establecimiento de la contraseña de `root`.
-   Elección de entorno de escritorio (GNOME, KDE Plasma, XFCE) o instalación mínima.
-   Opción para añadir paquetes de software adicionales.
-   Configuración automática de `sudo`, `NetworkManager` y el gestor de arranque `GRUB`.

## Prerrequisitos

1.  **Arrancar en modo Live de Arch Linux:** Descarga la [ISO oficial de Arch Linux](https://archlinux.org/download/), crea un USB booteable y arranca tu ordenador desde él.
2.  **Conexión a Internet:** Asegúrate de tener una conexión a internet activa. Si usas Wi-Fi, puedes conectarte desde el entorno live con el comando `iwctl`.
3.  **Particionar el disco:** Este script **NO** particiona el disco. Debes hacerlo tú manualmente antes de ejecutarlo. Usa `fdisk`, `cfdisk` o `gdisk`.

    Para un sistema UEFI (el estándar actual), necesitas como mínimo **dos** particiones:
    -   Una partición **EFI System Partition (ESP)**:
        -   Tamaño: ~550MB.
        -   Tipo: `EFI System`.
        -   Ejemplo: `/dev/sda1`, `/dev/nvme0n1p1`.
    -   Una partición **Raíz (root)**:
        -   Tamaño: El resto del espacio disponible.
        -   Tipo: `Linux filesystem`.
        -   Ejemplo: `/dev/sda2`, `/dev/nvme0n1p2`.

    Puedes verificar tus particiones con `lsblk` o `fdisk -l`. Anota los nombres exactos.

## ¿Cómo usar?

1.  **Clonar o descargar el proyecto:**
    Desde el entorno live de Arch Linux, clona este repositorio:
    ```bash
    pacman -Sy --noconfirm git
    git clone <URL_DEL_REPOSITORIO> arch-installer
    cd arch-installer
    ```
    O si has descargado los archivos manualmente, asegúrate de estar en el directorio correcto.

2.  **Dar permisos de ejecución:**
    Dale permisos de ejecución al script principal:
    ```bash
    chmod +x install.sh
    ```

3.  **Ejecutar el instalador:**
    Ejecuta el script y sigue las instrucciones que aparecerán en pantalla:
    ```bash
    ./install.sh
    ```
    El script te pedirá toda la información necesaria: particiones, nombres de usuario, contraseñas, etc.

4.  **Reiniciar:**
    Una vez que el script finalice, te indicará que la instalación ha sido completada. En ese momento, puedes reiniciar tu sistema:
    ```bash
    reboot
    ```
    No olvides retirar el medio de instalación (USB). ¡Tu nuevo sistema Arch Linux debería arrancar!

## Contribuciones

Las contribuciones son bienvenidas. Si encuentras un error o tienes una idea para mejorar el script, por favor abre un *issue* o envía un *pull request*.
