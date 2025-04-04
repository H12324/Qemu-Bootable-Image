# Run QEMU (Assumes user has compiled bzImage with same path for kernel arg)
# Also assumes that user has installed qemu-system-x86_64
QEMU="qemu-system-x86_64"
LINUX_PATH="linux-6.14/arch/x86/boot/bzImage" 
$QEMU \
    -kernel $LINUX_PATH \
    -initrd initramfs.img \
    -nographic \
    -append "console=ttyS0 rdinit=/init"