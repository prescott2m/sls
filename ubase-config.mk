# ubase version
VERSION = 0.1

# paths
PREFIX = /usr
MANPREFIX = $(PREFIX)/share/man

CC = $(TARGET_TUPLE)-gcc
AR = $(TARGET_TUPLE)-ar
RANLIB = $(TARGET_TUPLE)-ranlib

CPPFLAGS = -D_XOPEN_SOURCE=700 -D_GNU_SOURCE
CFLAGS   = -std=c99 -Wall -Wextra
LDLIBS   = 
LDFLAGS  = -s