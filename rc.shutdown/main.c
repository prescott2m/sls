/* See ../LICENSE file for copyright and license details. */
#include <stdio.h>
#include <stdlib.h>
#include <sys/reboot.h>
#include <unistd.h>

static void
usage(const char *argv0)
{
    printf("usage: %s [poweroff|reboot]. you must be root\n", argv0);
    exit(2);
}

int
main(int argc, char *argv[])
{
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