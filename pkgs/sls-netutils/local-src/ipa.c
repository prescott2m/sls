#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
#include <net/if.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdarg.h>
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
    int fd;
    struct ifreq ifr;

    if (argc != 2) usage(argv[0]);

    fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0)
        die("socket: %s\n", strerror(errno));

    memset(&ifr, 0, sizeof(ifr));
    if (strlen(argv[1]) >= IFNAMSIZ) 
        die("interface name too long\n");

    strcpy(ifr.ifr_name, argv[1]);
    if (ioctl(fd, SIOCGIFADDR, &ifr) < 0)
        die("ioctl(SIOCGIFADDR): %s\n", strerror(errno));

    struct sockaddr_in *ipaddr = (struct sockaddr_in *)&ifr.ifr_addr;
    printf("%s inet: \e[94m%s\e[0m\n", argv[1], inet_ntoa(ipaddr->sin_addr));
    close(fd);
    return 0;
}
