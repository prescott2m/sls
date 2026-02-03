#include <asm-generic/socket.h>
#include <netinet/in.h>
#include <stdio.h>
#include <sys/socket.h>
#include <netinet/ip_icmp.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>
#include <stdarg.h>
#include <errno.h>

#define DATALEN 56
#define MAXIPLEN 60
#define MAXICMPLEN 76
#define PACKLEN DATALEN+MAXIPLEN+MAXICMPLEN

static void
usage(const char *argv0)
{
    printf("usage: %s <ip>\n", argv0);
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

static char*
pr_addr(void *sa, socklen_t salen)
{
	static char buffer[4096] = "";
	static struct sockaddr_storage last_sa = { 0 };
	static socklen_t last_salen = 0;
    char address[128];

	if (salen == last_salen && !memcmp(sa, &last_sa, salen))
		return buffer;

	memcpy(&last_sa, sa, (last_salen = salen));
	getnameinfo(sa, salen, address, sizeof address, NULL, 0, NI_NUMERICHOST);
    snprintf(buffer, sizeof buffer, "%s", address);

	return(buffer);
}

static unsigned short
in_cksum(const unsigned short *addr, register int len, unsigned short csum)
{
	register int nleft = len;
	const unsigned short *w = addr;
	register unsigned short answer;
	register int sum = csum;

	while (nleft > 1)  {
		sum += *w++;
		nleft -= 2;
	}

	if (nleft == 1)
        sum += *(unsigned char *)w;

	sum = (sum >> 16) + (sum & 0xffff);
	sum += (sum >> 16);
	answer = ~sum;
	return (answer);
}

static int
send_icmp_echo(int sock, struct sockaddr_in *dst, int ntransmitted)
{
    struct icmphdr *icp;

	if (!(icp = (struct icmphdr*)malloc((unsigned int)PACKLEN))) {
        perror("malloc");
        return -1;
    }

	icp->type = ICMP_ECHO;
	icp->code = 0;
	icp->checksum = 0;
	icp->un.echo.sequence = htons(ntransmitted+1);
	icp->checksum = in_cksum((unsigned short *)icp, DATALEN+8, 0);

    return sendto(sock, icp, DATALEN+8, 0, (struct sockaddr*)dst, sizeof(*dst));
}

static int
get_icmp_reply(int sock)
{
    struct icmphdr *icp_reply;
    struct sockaddr_in *from;
    struct iphdr *ip;
    struct msghdr msg;
    struct iovec iov;
    unsigned char *packet;
    unsigned char *buf;
    char addrbuf[128];
    int cc;

    if (!(packet = (unsigned char *)malloc((unsigned int)PACKLEN))) {
        perror("malloc");
		return -1;
	}

    memset(&msg, 0, sizeof(msg));
    iov.iov_base = (char *) packet;
    iov.iov_len = PACKLEN;
    msg.msg_name = addrbuf;
    msg.msg_namelen = sizeof(addrbuf);
    msg.msg_iov = &iov;
    msg.msg_iovlen = 1;

    cc = recvmsg(sock, &msg, MSG_WAITALL);
    if (cc  < 0 ){
        perror("Error in recvmsg");
        return -1;
    }

    buf = msg.msg_iov->iov_base;
    ip = (struct iphdr *)buf;
    icp_reply = (struct icmphdr *)(buf + (ip->ihl * 4));

    if (in_cksum((unsigned short *)icp_reply, cc, 0)) {
        printf(" bad checksum");
        return -1;
    }

    if (icp_reply->type != ICMP_ECHOREPLY) {
        printf(" not an ICMP_ECHOREPLY\n");
        return -1;
    }

    from = msg.msg_name;
    printf(" %d bytes from %s: icmp_seq=%u\n", cc, pr_addr(from, sizeof *from), ntohs(icp_reply->un.echo.sequence));
    return 0;
}

int
main(int argc, char *argv[])
{
    struct sockaddr_in source;
    struct sockaddr_in dst;
    struct icmphdr *p;
    int ntransmitted = 0;
    int nrecieved = 0;

    if (argc != 2)
        usage(argv[0]);

    int s = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
    if (s < 0)
        die("socket: %s\n", strerror(errno));

    struct timeval timeout;   
    timeout.tv_sec = 5;
    timeout.tv_usec = 0;

    if (setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)) < 0)
        die("setsockopt(SO_RCVTIMEO): %s\n", strerror(errno));
    if (setsockopt(s, SOL_SOCKET, SO_SNDTIMEO, &timeout, sizeof(timeout)) < 0)
        die("setsockopt(SO_SNDTIMEO): %s\n", strerror(errno));

    memset((char*)&dst, 0, sizeof(dst));
    dst.sin_family = AF_INET;
    inet_pton(AF_INET, argv[1], &dst.sin_addr);
    dst.sin_port = htons(1025);

    for (ntransmitted = 0; ntransmitted < 4; ntransmitted++) {
        int i = send_icmp_echo(s, &dst, ntransmitted);
        if (i < 0) {
            perror("sendto");
            continue;
        }

        printf("Sent %d bytes\n", i);
        if (!get_icmp_reply(s)) nrecieved++;
        if (ntransmitted != 3) sleep(1);
    }

    printf("---\n%d packets transmitted, %d packets received, %.2f%% packet loss\n", ntransmitted, nrecieved, 100.0 * (ntransmitted - nrecieved) / ntransmitted);
    return 0;
}
