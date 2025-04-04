#!/bin/bash

set -e

# Script assumes user already has utils needed to build the linux image
# so it won't call sudo apt install... to install dependencies

LINUX_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.14.tar.xz"
LINUX_ZIP="linux-6.14.tar.xz"
LINUX_DIR="linux-6.14"

# Download and extract the kernel
#rm -rf "$LINUX_DIR"
if [ ! -d "$LINUX_DIR" ]; then
    if [ ! -f "$LINUX_ZIP" ]; then
        wget "$LINUX_URL"
    fi
    tar -xf $LINUX_ZIP
fi

# Build the kernel
cd "$LINUX_DIR"
make defconfig
make -j$(nproc) bzImage
cd ..