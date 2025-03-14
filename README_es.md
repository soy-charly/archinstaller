# 🏗️ Instalador Automático de Arch Linux con Hyprland

Este conjunto de scripts permite la instalación automática de **Arch Linux** con **Hyprland** y configuración personalizada, incluyendo la opción de elegir discos, crear usuarios y configurar el sistema base.

## 📌 **Características**
✅ Instalación automatizada de **Arch Linux**  
✅ Creación de particiones en **GPT**  
✅ Instalación del sistema base con **sudo**, `nano`, y `networkmanager`  
✅ Configuración de **zona horaria, locales, hostname y red**  
✅ Creación de usuario personalizado y opcionalmente `root`  
✅ Instalación opcional de **Hyprland** y **Ly**  
✅ Posibilidad de añadir mejoras adicionales  

---

## 🚀 **Uso**

### 1️⃣ **Descargar los scripts**
```sh
git clone https://github.com/tu-repo/arch-installer.git
cd arch-installer
```

### 2️⃣ **Hacer ejecutables los scripts**
```sh
chmod +x *.sh
```

### 3️⃣ **Ejecutar el instalador principal**
```sh
sudo ./arch_installer.sh
```

Este script:
- Pregunta en qué disco instalar el sistema
- Crea particiones y las formatea
- Instala el sistema base
- Configura el usuario y la red
- Pregunta si deseas instalar Hyprland y extras

---

## 📜 **Estructura de los scripts**
📂 `arch-installer/`  
├── `arch_installer.sh` → **Instalador principal**  
├── `install_hyprland.sh` → **Instalación de Hyprland y Ly**  
├── `install_extras.sh` → **Configuraciones adicionales**  
└── `README.md` → **Esta guía**  

---

## 🔧 **Instalación Manual**
Si deseas ejecutar los scripts por separado:  

1️⃣ **Instalar Arch Linux**  
```sh
sudo ./arch_installer.sh
```

2️⃣ **Instalar Hyprland** (opcional)  
```sh
arch-chroot /mnt /bin/bash -c "./install_hyprland.sh"
```

3️⃣ **Instalar mejoras adicionales** (opcional)  
```sh
arch-chroot /mnt /bin/bash -c "./install_extras.sh"
```

---

## 🛠️ **Requisitos**
- **Sistema en modo UEFI**
- **Conexión a Internet**
- **USB booteable con Arch Linux**

---

## 📝 **Notas**
- El script **NO** pregunta antes de formatear el disco.
- Si quieres cambiar el tamaño de las particiones, edita `arch_installer.sh`.
- Para **reporte de errores o mejoras**, abre un **Issue** en el repositorio.

---

🎉 **¡Listo! Ahora puedes disfrutar de Arch Linux con Hyprland completamente instalado.** 🚀
```

---

### ✨ **¿Qué incluye este README?**
✔ **Explicación de qué hace cada script**  
✔ **Instrucciones claras de instalación**  
✔ **Ejemplo de estructura de archivos**  
✔ **Notas y requisitos importantes**  

Si necesitas personalizarlo más, dime y lo ajustamos. 😃
