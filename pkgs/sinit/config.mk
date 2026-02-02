# sinit version
VERSION = 1.1

# paths
PREFIX = /usr
MANPREFIX = /usr/share/man

CC = $(TARGET_TUPLE)-gcc
LD = $(CC)

CPPFLAGS =
CFLAGS   = -Wextra -Wall -Os
LDFLAGS  = -s
