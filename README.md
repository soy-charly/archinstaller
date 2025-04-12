
# ArchInstaller

ArchInstaller is a Bash script that automates the installation and initial configuration of Arch Linux. It is designed to simplify the installation process, allowing users to customize their system according to their needs.

## Features

- **Complete Automation**: Installs Arch Linux in an automated manner, reducing the time and effort required.
- **Support for Multiple File Systems**: Automatically detects and configures SSDs and TRIM. Supports file systems such as BFS, Btrfs, ext{2,3,4}, F2FS, JFS, NILFS2, NTFS, ReiserFS, and XFS.
- **Hardware Compatibility**: Works on PCs (x86 and x86_64) and ARM devices (armv6h and armv7h). Automatically detects and configures hardware, installing the necessary drivers.
- **Desktop Environments**: Allows automated installation of desktop environments such as Cinnamon, Enlightenment, GNOME, KDE, LXDE, MATE, and XFCE.
- **Power Management**: Includes configurations for power management using tools like cpupower and TLP.

## Requirements

- **Internet Connection**: Required to download packages during installation.
- **Arch Linux Live ISO**: It is recommended to use the latest version of the Arch Linux live ISO image.

## Installation

1. **Prepare the Environment**:

  Boot from the Arch Linux Live ISO and configure the network:

  ```bash
  loadkeys us # Set the keyboard to US layout
  wifi-menu   # Connect to a Wi-Fi network
  dhcpcd      # Obtain an IP address
  ```

2. **System Update**:

  Update the repositories and install Git:

  ```bash
  pacman -Syy --noconfirm git
  ```

3. **Clone the Repository**:

  Clone the ArchInstaller repository:

  ```bash
  git clone https://github.com/soy-charly/archinstaller.git
  cd archinstaller
  ```

4. **User Configuration**:

  Edit the `users.csv` file to define the users to be created during installation. Use `users.example` as a reference.

5. **Run the Installation Script**:

  Run the installation script with the desired options. For example, for a PC installation:

  ```bash
  ./arch-install.sh -d sda -p bsrh -w pA55w0rd -n my_host.example.org
  ```

  For a Raspberry Pi:

  ```bash
  ./arch-install.sh -w pA55w0rd -n my_host.example.org
  ```

  Get help on the available options with:

  ```bash
  ./arch-install.sh -h
  ```

## Additional Features

- **Hardware Detection**: The script automatically detects the system's hardware and executes the corresponding scripts to configure the necessary drivers.
- **NFS Cache**: Uses an NFS cache to speed up package downloads if you already have an Arch Linux installation on another machine.
- **Power Management**: Includes configurations for power management using tools like cpupower and TLP.

## Limitations

- **UEFI**: Currently, the script does not support UEFI systems. It is designed for BIOS systems only.
- **Partitioning**: Offers simple partitioning options and may not be suitable for more complex disk configurations.

## Contributions

Contributions are welcome. If you want to improve the script or add new features, please follow these guidelines:

1. Fork the repository.
2. Create a branch for your feature (`git checkout -b feature/new-feature`).
3. Make your changes and commit them (`git commit -am 'Add new feature'`).
4. Push your changes to your fork (`git push origin feature/new-feature`).
5. Create a pull request describing your changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

