#!/bin/bash

set -e  # Stop execution on errors if any command fails

echo "Updating and installing necessary packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y unzip screen tmux nano build-essential pkg-config libssl-dev git-all

# Install Rust
if ! command -v cargo &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Verify Rust installation
cargo --version
rustup target add riscv32i-unknown-none-elf

# Remove old protoc version
echo "Removing any existing protoc installation..."
sudo apt remove -y protobuf-compiler

# Install protoc 25.2
PROTOC_VERSION=25.2
ARCH=linux-x86_64
PROTOC_ZIP=protoc-$PROTOC_VERSION-$ARCH.zip

echo "Downloading and installing protoc $PROTOC_VERSION..."
curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOC_VERSION/$PROTOC_ZIP
sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
sudo unzip -o $PROTOC_ZIP -d /usr/local include/*
rm -f $PROTOC_ZIP

# Ensure /usr/local/bin is in PATH
if ! grep -q 'export PATH="/usr/local/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
fi
export PATH="/usr/local/bin:$PATH"

# Verify protoc installation
protoc --version

# Configure 8GB swap file
if ! grep -q '/swapfile' /etc/fstab; then
    echo "Setting up a new 8GB swap file..."
    sudo swapoff -a || true
    sudo rm -f /swapfile
    sudo fallocate -l 8G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
else
    echo "Swap file already exists, skipping swap setup."
fi

# Verify swap
swapon --show
free -h
cat /proc/swaps

echo "Installation completed successfully!"
