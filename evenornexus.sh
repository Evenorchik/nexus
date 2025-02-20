#!/bin/bash

set -e  # Stop execution on errors

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Add target architecture for Rust
rustup target add riscv32i-unknown-none-elf

# Install protoc
PROTOC_VERSION=21.12
ARCH=linux-x86_64
PROTOC_ZIP=protoc-$PROTOC_VERSION-$ARCH.zip

# Download and extract
curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOC_VERSION/$PROTOC_ZIP
sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
sudo unzip -o $PROTOC_ZIP -d /usr/local include/*
rm -f $PROTOC_ZIP

# Add /usr/local/bin to PATH
if ! grep -q 'export PATH="$PATH:/usr/local/bin"' ~/.bashrc; then
    echo 'export PATH="$PATH:/usr/local/bin"' >> ~/.bashrc
fi
source ~/.bashrc

# Configure swap file
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Check swap
swapon --show
free -h
cat /proc/swaps

echo "Installation completed!"
