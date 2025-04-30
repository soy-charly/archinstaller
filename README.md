# **Instalación Personalizada de Arch Linux**

Este proyecto ofrece un conjunto de scripts para realizar una instalación modular y personalizada de Arch Linux desde cero. Permite seleccionar particiones, configurar el sistema, instalar un gestor de arranque y añadir software adicional según las preferencias del usuario.

## **Estructura del Proyecto**

El proyecto está organizado en varios scripts, cada uno encargado de una etapa específica de la instalación:

```
arch_install/
├── particionado.sh   # Selección y montaje de particiones
├── configuracion.sh  # Configuración del sistema (zona horaria, idioma, etc.)
├── software.sh       # Instalación de software adicional (entorno gráfico, gestor de arranque)
└── install.sh        # Script principal que orquesta la instalación
```

### **Descripción de los Scripts**

- **`particionado.sh`**: Permite seleccionar y montar las particiones necesarias, como la raíz (`/`) y `/boot`. Verifica la existencia de las particiones antes de montarlas.

- **`configuracion.sh`**: Configura aspectos básicos del sistema, como la zona horaria, el idioma, el nombre del host, la red y las contraseñas de los usuarios. También ofrece la opción de instalar y configurar NetworkManager.

- **`software.sh`**: Facilita la instalación de un gestor de arranque (GRUB o Syslinux) y software adicional, como entornos gráficos (GNOME, KDE, Xfce, i3) o paquetes esenciales.

- **`install.sh`**: Script principal que ejecuta los demás scripts en el orden adecuado. Es el punto de entrada para iniciar la instalación.

## **Requisitos Previos**

- Arch Linux debe estar en modo Live con acceso a un terminal con privilegios `sudo`.
- Conexión a Internet para descargar paquetes.
- Conocimientos básicos sobre particionamiento de discos y configuración de sistemas Linux.

## **Instrucciones de Uso**

### 1. **Clonar o Descargar el Proyecto**

Clona este repositorio o descárgalo en tu máquina:

```bash
git clone https://github.com/tu_usuario/arch_install.git
cd arch_install
```

### 2. **Hacer los Scripts Ejecutables**

Asegúrate de que los scripts tengan permisos de ejecución:

```bash
chmod +x particionado.sh configuracion.sh software.sh install.sh
```

### 3. **Ejecutar el Script Principal**

Inicia la instalación ejecutando el script principal:

```bash
./install.sh
```

Este script guiará el proceso completo, incluyendo particionado, configuración del sistema e instalación de software.

### 4. **Proceso de Instalación**

El script principal realiza los siguientes pasos:

1. **Particionado**: Selección y montaje de las particiones necesarias (`/` y `/boot`).
2. **Configuración del Sistema**: Configuración de zona horaria, idioma, nombre del host, red y contraseñas.
3. **Instalación de Software**: Instalación de un gestor de arranque y un entorno gráfico o gestor de ventanas.

### 5. **Reiniciar el Sistema**

Una vez completados todos los pasos, el script indicará que reinicies el sistema.

## **Personalización**

Puedes adaptar los scripts a tus necesidades específicas:

- **Particionado**: Modifica los puntos de montaje o añade más particiones según sea necesario.
- **Configuración del Sistema**: Agrega configuraciones adicionales, como usuarios, servicios o ajustes de red.
- **Software Adicional**: Personaliza los paquetes a instalar o añade otros entornos de escritorio.

## **Contribución**

Si deseas mejorar o personalizar estos scripts, realiza un fork del proyecto y envía un pull request con tus cambios. Asegúrate de seguir las mejores prácticas y probar los scripts antes de enviarlos.

## **Licencia**

Este proyecto está bajo la licencia MIT. Consulta el archivo LICENSE en el repositorio para más detalles.
