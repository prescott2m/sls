# ubase version
VERSION = 0.1

# paths
PREFIX = /usr
MANPREFIX = $(PREFIX)/share/man

CC = musl-gcc
AR = ar
RANLIB = ranlib

CPPFLAGS = -D_XOPEN_SOURCE=700 -D_GNU_SOURCE
CFLAGS   = -std=c99 -Wall -Wextra
LDLIBS   = 
LDFLAGS  = -s