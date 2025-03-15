# 🚀 Arch Linux Installer

This is a set of automated scripts to install Arch Linux with a basic configuration and an optional installation of Hyprland as a desktop environment.

## 📂 Project Structure

```bash
arch-install/
│── install.sh              # 🏗️ Main script
│── partitions.sh           # 🖥️ Partition selection and formatting
│── base_install.sh         # 📦 Base system installation
│── system_config.sh        # ⚙️ System configuration inside chroot
│── desktop_install.sh      # 🎨 Optional installation of Hyprland and Ly
```

## ✅ Requirements

- 🌐 Internet connection  
- 💾 A disk prepared for Arch Linux installation  
- 🏗️ System running in UEFI mode  

## 🛠️ Installation

1. 🔥 Boot from an Arch Linux ISO in Live mode.  
2. 🌐 Connect to the internet using `ip a` to check network connectivity or `wifi-menu` if using Wi-Fi.  
3. 📥 Install `git` to clone the repository:  
   ```bash
   pacman -Sy git
   ```
4. 📂 Clone this repository:  
   ```bash
   git clone https://github.com/yourusername/arch-install.git
   cd arch-install
   ```
5. 🔑 Grant execution permissions to the scripts:  
   ```bash
   chmod +x *.sh
   ```
6. ▶️ Run the main script:  
   ```bash
   ./install.sh
   ```

## 🎨 Customization

You can modify any of the scripts to suit your needs, such as adding additional packages in `base_install.sh` or changing the keyboard configuration in `system_config.sh`.

## 🖥️ Optional: Hyprland and Ly Installation

During the installation process, you will be asked if you want to install Hyprland and the Ly display manager. If you choose "s", they will be installed automatically.

## ⚠️ Notes

- ⚡ This script **will erase** the selected partitions. Make sure to back up any important data before running it!  
- 📦 The installation is performed using `pacstrap` and includes the essentials: `linux`, `linux-firmware`, `nano`, `sudo`, `grub`, `networkmanager`, etc.  
- 🎮 If you need support for NVIDIA or other drivers, you can add the required packages in `base_install.sh`.  

## 🤝 Contributions

If you want to improve this script, you can fork the repository and submit a pull request.
