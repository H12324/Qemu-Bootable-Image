#!/bin/bash

set -e

# Script assumes user already has utils needed to build the linux image
# so it won't call sudo apt install... to install dependencies

# Kernel Variables
LINUX_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.14.tar.xz"
LINUX_ZIP="linux-6.14.tar.xz"
LINUX_DIR="linux-6.14"
LINUX_IMG="$LINUX_DIR/arch/x86/boot/bzImage" 

# Initramfs Variables
INITRAMFS_DIR="initramfs"
INITRAMFS_IMG="initramfs.img"

# Download and extract the kernel
if [ ! -d "$LINUX_DIR" ]; then
    if [ ! -f "$LINUX_ZIP" ]; then
        wget "$LINUX_URL"
    fi
    tar -xf $LINUX_ZIP
fi

# Build the kernel (if not already built)
if [ ! -f "$LINUX_IMG" ]; then
    cd "$LINUX_DIR"
    make defconfig
    make -j$(nproc) bzImage
    cd ..
fi

# Create initramfs directory
rm -rf "$INITRAMFS_DIR"
mkdir -p "$INITRAMFS_DIR"/{bin,sbin,etc,proc,sys,dev}

# Create init script (Assumes user has gcc and all needed dependencies)
cat > temp.c << EOF
#include <iostream>
#include <unistd.h>
#include <sys/reboot.h>
#include <sys/syscall.h>

int main() {
    std::cout << "hello world" << std::endl;
    // Comment out loop if you want it to shutdown
    while (true) {
        sync();
    }
    reboot(RB_POWER_OFF);  
    return 0;
}
EOF
g++ -static -o "$INITRAMFS_DIR"/init temp.c 
rm temp.c

# Create initramfs image
(cd "$INITRAMFS_DIR" && find . | cpio -o -H newc) | gzip > "$INITRAMFS_IMG"

# Run Qemu assuming user has qemu-system-x86_64 installed
QEMU="qemu-system-x86_64"
$QEMU \
    -kernel "$LINUX_IMG" \
    -initrd initramfs.img \
    -nographic \
    -append "console=ttyS0 rdinit=/init"