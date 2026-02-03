#define _GNU_SOURCE
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>

static void
usage(const char *argv0)
{
    printf("usage: %s <ifname>\n", argv0);
    exit(2);
}

void
die(const char *errstr, ...)
{
    va_list ap;

    va_start(ap, errstr);
    vfprintf(stderr, errstr, ap);
    va_end(ap);
    exit(1);
}

int
main(int argc, char *argv[])
{
    if (argc != 2) usage(argv[0]);

    int fd = socket(AF_UNIX, SOCK_DGRAM, 0);
    if (fd < 0) 
        die("socket: %s\n", strerror(errno));

    struct ifreq ifr;
    memset(&ifr, 0, sizeof(ifr));

    if (strlen(argv[1]) >= IFNAMSIZ) 
        die("interface name too long\n");

    strcpy(ifr.ifr_name, argv[1]);
    if (ioctl(fd, SIOCGIFFLAGS, &ifr) < 0)
        die("ioctl(SIOCGIFFLAGS): %s\n", strerror(errno));

    ifr.ifr_flags |= IFF_UP;
    if (ioctl(fd, SIOCSIFFLAGS, &ifr) < 0)
        die("ioctl(SIOCSIFFLAGS): %s\n", strerror(errno));

    close(fd);
    return 0;
}
