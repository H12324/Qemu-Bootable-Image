/* Alternative init without the shell
#include <iostream>
#include <unistd.h>
#include <sys/reboot.h>
#include <sys/syscall.h>

int main() {
    std::cout << "hello world" << std::endl;
    //while (true) {
        sync();
    //}
    reboot(RB_POWER_OFF);  
    return 0;
}*/

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
