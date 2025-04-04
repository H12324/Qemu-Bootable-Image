#!/bin/bash

set -e

INITRAMFS_DIR="initramfs"
INITRAMFS_IMG="initramfs.img"

# Create initramfs directory
rm -rf "$INITRAMFS_DIR"
mkdir -p "$INITRAMFS_DIR"/{bin,sbin,etc,proc,sys,dev}

# Create init script (Assumes user has gcc and all needed dependencies)
gcc -static -o "$INITRAMFS_DIR"/init init.c 

# Assumes that busybox is already on the host_device
# Add BusyBox for a shell program 
# Note: Maybe add option to exclude shell and use previous init.c
cp /bin/busybox "$INITRAMFS_DIR/bin/"
for cmd in sh ls mount echo cat; do
    ln -s /bin/busybox "$INITRAMFS_DIR/bin/$cmd"
done

# Create initramfs image
(cd "$INITRAMFS_DIR" && find . | cpio -o -H newc) | gzip > "$INITRAMFS_IMG"
