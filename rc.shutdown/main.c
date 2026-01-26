#include <stdio.h>
#include <sys/reboot.h>
#include <stdlib.h>
#include <unistd.h>

void usage(const char* argv0) {
    printf("usage: %s [poweroff|reboot]\n%s must be run as root\n", argv0, argv0);
    exit(2);
}

int main(int argc, char* argv[]) {
    if (getuid() || argc != 2)
        usage(argv[0]);

    switch (argv[1][0]) {
        case 'p':
            sync();
            reboot(RB_POWER_OFF);
            break;
        case 'r':
            sync();
            reboot(RB_AUTOBOOT);
            break;
        default:
            usage(argv[0]);
    }

    perror("reboot");
    return 1;
}