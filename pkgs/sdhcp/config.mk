# sdhcp version
VERSION   = 0.1

PREFIX    = /usr
DESTDIR   =
MANPREFIX = $(PREFIX)/share/man

CC        = $(TARGET_TUPLE)-cc
LD        = $(CC)
CPPFLAGS  = -D_DEFAULT_SOURCE
CFLAGS    = -Wall -Wextra -pedantic -std=c99 $(CPPFLAGS)
LDFLAGS   = -s
