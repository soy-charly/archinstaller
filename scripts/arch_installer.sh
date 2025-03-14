#!/bin/bash

set -e

# Prompt for disk selection
echo "Available disks:"
lsblk -d -n -o NAME,SIZE
read -p "Enter the disk to install Arch Linux (e.g., /dev/sdX): " DISK

# Show available partitions
echo "Available partitions on $DISK:"
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT "$DISK"

# Prompt for boot and root partitions
read -p "Enter the partition for /boot (e.g., /dev/sdX1): " BOOT_PARTITION
read -p "Enter the partition for / (root) (e.g., /dev/sdX2): " ROOT_PARTITION

# Confirm selection
echo "Selected boot partition: $BOOT_PARTITION"
echo "Selected root partition: $ROOT_PARTITION"
read -p "Are you sure? This will erase all data on these partitions (y/N): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
    echo "Installation cancelled."
    exit 1
fi

# Formatting partitions
echo "Formatting partitions..."
mkfs.fat -F32 "$BOOT_PARTITION"
mkfs.ext4 "$ROOT_PARTITION"

# Mounting partitions
echo "Mounting partitions..."
mount "$ROOT_PARTITION" /mnt
mkdir -p /mnt/boot
mount "$BOOT_PARTITION" /mnt/boot

# Install base system
echo "Installing base system..."
pacstrap /mnt base linux linux-firmware nano sudo networkmanager

# Ensure sudo is installed
echo "Installing sudo..."
arch-chroot /mnt pacman -Sy --noconfirm sudo

echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
echo "Entering chroot environment..."
arch-chroot /mnt /bin/bash <<EOF

# Set timezone
echo "Setting timezone..."
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

# Localization
echo "Configuring locale..."
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "Enter hostname:"
read HOSTNAME
echo "$HOSTNAME" > /etc/hostname

echo "127.0.0.1    localhost" >> /etc/hosts
echo "::1          localhost" >> /etc/hosts
echo "127.0.1.1    $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# Set root password
echo "Setting root password..."
passwd

# Create user
echo "Enter new username:"
read USERNAME
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "Set password for $USERNAME:"
passwd "$USERNAME"

echo "Enabling sudo for wheel group..."
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel

# Enable essential services
echo "Enabling NetworkManager..."
systemctl enable NetworkManager

EOF

# Final message
echo "Installation complete! You can reboot now."
