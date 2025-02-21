#!/bin/bash

set -e  # Прерывать выполнение при ошибке

echo "Обновление и установка необходимых пакетов..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y unzip screen tmux nano build-essential pkg-config libssl-dev git-all

# Удаление старых версий Rust и установка новой
if ! command -v cargo &> /dev/null; then
    echo "Установка Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Проверка установки Rust
cargo --version
rustup target add riscv32i-unknown-none-elf

# Удаление старых версий protoc
echo "Удаление старых версий protoc..."
rm -f /root/.local/bin/protoc
rm -rf /root/.local/include/google/protobuf
rm -f /usr/local/bin/protoc
rm -rf /usr/local/include/google/protobuf

# Установка protoc 25.2
PROTOC_VERSION=25.2
ARCH=linux-x86_64
PROTOC_ZIP=protoc-$PROTOC_VERSION-$ARCH.zip

echo "Скачивание и установка protoc $PROTOC_VERSION..."
curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOC_VERSION/$PROTOC_ZIP
sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
sudo unzip -o $PROTOC_ZIP -d /usr/local include/*
rm -f $PROTOC_ZIP

# Добавление /usr/local/bin в PATH
if ! grep -q 'export PATH="/usr/local/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
fi
export PATH="/usr/local/bin:$PATH"

# Проверка установки protoc
protoc --version

# Настройка файла подкачки (swap)
echo "Настройка swap файла..."

# Отключение и удаление существующего swap файла, если он есть
if grep -q '/swapfile' /etc/fstab; then
    echo "Удаление существующего swap файла..."
    sudo swapoff -a
    sudo rm -f /swapfile
fi

# Создание нового swap файла
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Добавление в fstab (если отсутствует)
if ! grep -q '/swapfile' /etc/fstab; then
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# Проверка swap
swapon --show
free -h
cat /proc/swaps

echo "Установка завершена успешно!"
