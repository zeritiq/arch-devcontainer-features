#!/bin/bash

set -e

# Yay AUR Helper Feature
# This feature installs yay AUR helper for Arch Linux

INSTALL_PACKAGES="${INSTALLPACKAGES:-}"

echo "Starting yay AUR helper installation..."

# Check if we're on Arch Linux
if [ ! -f /etc/arch-release ]; then
    echo "Error: This feature is only compatible with Arch Linux"
    exit 1
fi

# Check if yay is already installed
if command -v yay &> /dev/null; then
    echo "Yay is already installed, skipping installation..."
else
    echo "Installing yay AUR helper..."
    
    # Ensure required packages are installed
    echo "Checking for required packages (base-devel, git)..."
    if ! pacman -Q base-devel &> /dev/null || ! pacman -Q git &> /dev/null; then
        echo "Installing required packages..."
        sudo pacman -Sy base-devel git --noconfirm --needed
    fi
    
    # Create temporary directory for yay installation
    YAY_TMP_DIR=$(mktemp -d)
    cd "$YAY_TMP_DIR"
    
    echo "Cloning yay from AUR..."
    git clone https://aur.archlinux.org/yay.git
    
    echo "Building and installing yay..."
    cd yay
    makepkg -si --noconfirm
    
    # Clean up
    cd /
    rm -rf "$YAY_TMP_DIR"
    
    echo "Yay installation completed successfully!"
fi

# Install additional AUR packages if specified
if [ -n "$INSTALL_PACKAGES" ]; then
    echo "Installing additional AUR packages: $INSTALL_PACKAGES"
    
    # Convert comma-separated list to space-separated
    PACKAGES=$(echo "$INSTALL_PACKAGES" | tr ',' ' ')
    
    # Install packages using yay
    yay -Sy $PACKAGES --noconfirm
    
    echo "Additional packages installed successfully!"
fi

echo "Yay AUR helper feature installation completed!"
