# 🏗️ Arch Linux Automatic Installer with Hyprland

This set of scripts allows for the **automatic installation of Arch Linux** with **Hyprland**, providing options to choose disks, create users, and configure the base system.

---

## 📌 **Features**
✅ Fully automated **Arch Linux installation**  
✅ **GPT partitioning** support  
✅ Installs **base system**, including `sudo`, `nano`, and `networkmanager`  
✅ Configures **timezone, locales, hostname, and network**  
✅ Creates a custom user and optionally a `root` account  
✅ **Optional installation of Hyprland and Ly**  
✅ Additional enhancements available as an option  
✅ **Formats `/` as EXT4 and `/boot` as FAT32**  

---

## 🚀 **Usage**

### 1️⃣ **Download the scripts**
```sh
git clone https://github.com/your-repo/arch-installer.git
cd arch-installer
```

### 2️⃣ **Make the scripts executable**
```sh
chmod +x scripts/*.sh
```

### 3️⃣ **Run the main installer**
```sh
sudo ./scripts/arch_installer.sh
```

This script will:
- Ask for the disk to install the system
- Create and format partitions (`/` as EXT4, `/boot` as FAT32)
- Install the base system
- Configure user and network settings
- Offer to install Hyprland and additional enhancements

---

## 📜 **Script Structure**
📂 `arch-installer/`  
├── 📂 `scripts/` → **Folder containing all installation scripts**  
│   ├── `arch_installer.sh` → **Main installer**  
│   ├── `install_hyprland.sh` → **Hyprland and Ly installation**  
│   ├── `install_extras.sh` → **Additional configurations**  
└── `README.md` → **This guide**  

---

## 🔧 **Manual Installation**
If you prefer to run the scripts separately:

1️⃣ **Install Arch Linux**  
```sh
sudo ./scripts/arch_installer.sh
```

2️⃣ **Install Hyprland** (optional)  
```sh
arch-chroot /mnt /bin/bash -c "./scripts/install_hyprland.sh"
```

3️⃣ **Install additional enhancements** (optional)  
```sh
arch-chroot /mnt /bin/bash -c "./scripts/install_extras.sh"
```

---

## 🛠️ **Requirements**
- **UEFI system**
- **Internet connection**
- **Bootable USB with Arch Linux**

---

## 📝 **Notes**
- The script **does NOT** ask for confirmation before formatting the disk.
- The root partition (`/`) is formatted as **EXT4**.
- The boot partition (`/boot`) is formatted as **FAT32**.
- To change partition sizes, edit `scripts/arch_installer.sh`.
- For **bug reports or improvements**, open an **Issue** on the repository.

---

🎉 **All set! You now have a fully installed Arch Linux system with Hyprland.** 🚀

