#!/bin/bash

set -e  # Stop execution on errors

sudo apt install unzip

sudo apt install screen

sudo apt update && sudo apt upgrade -y && \
sudo apt install -y tmux nano build-essential pkg-config libssl-dev git-all unzip && \
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
source $HOME/.cargo/env && \
cargo --version && \
rustup target add riscv32i-unknown-none-elf && \
sudo apt remove -y protobuf-compiler && \
curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v25.2/protoc-25.2-linux-x86_64.zip && \
unzip protoc-25.2-linux-x86_64.zip -d $HOME/.local && \
export PATH="$HOME/.local/bin:$PATH" && \
protoc --version

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
