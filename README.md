# Qemu-Bootable-Image
Exercise to create a script which will create and run an amd64 Linux image (hopefully with a filesystem)

### Information about usage
Scripts assume that all neccessary dependencies to compile linux kernel and run qemu-system-x86 are already installed on device running the scripts.

Can run and modify each script seperately or all at once using **run_all.sh**

Reccomended order if running seperately
- make_kernel.sh
- make_initramfs.sh
- run_qemu.sh

If the busybox portion of the script is not working or if you wish to run it without the extra shell utilities and have it hang forever after printing 'hello world', use **run_all_no_shell.sh**
