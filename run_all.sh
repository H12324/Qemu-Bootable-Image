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
#include <stdio.h>
#include <unistd.h>
#include <sys/mount.h>
#include <stdlib.h>
#include <sys/reboot.h>
#include <sys/syscall.h>

int main() {
    // Not strictly necessary but makes shell more full-featured
    mount("proc", "/proc", "proc", 0, NULL);
    mount("sysfs", "/sys", "sysfs", 0, NULL);
    mount("devtmpfs", "/dev", "devtmpfs", 0, NULL);

    printf("hello world\n");

    // Also optional though will panic afterwards without it
    execl("/bin/sh", "sh", NULL);
    perror("execl failed");
    return 0;
}
EOF
gcc -static -o "$INITRAMFS_DIR"/init temp.c 
rm temp.c

# Assumes that busybox is already on the host_device
# Add BusyBox for a shell program 
# Note: Maybe add option to exclude shell and use previous init.c
cp /bin/busybox "$INITRAMFS_DIR/bin/"
for cmd in sh ls mount echo cat; do
    ln -s /bin/busybox "$INITRAMFS_DIR/bin/$cmd"
done

# Create initramfs image
(cd "$INITRAMFS_DIR" && find . | cpio -o -H newc) | gzip > "$INITRAMFS_IMG"

# Run Qemu assuming user has qemu-system-x86_64 installed
QEMU="qemu-system-x86_64"
$QEMU \
    -kernel "$LINUX_IMG" \
    -initrd initramfs.img \
    -nographic \
    -append "console=ttyS0 rdinit=/init"