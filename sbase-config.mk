# sbase version
VERSION = 0.1

# paths
PREFIX = /
MANPREFIX = /usr/share/man

# tools
CC = musl-gcc
#AR =
RANLIB = ranlib
# OpenBSD requires SMAKE to be scripts/make
# SMAKE = scripts/make
SMAKE = $(MAKE)

# -lrt might be needed on some systems
# -DYYDEBUG adds more debug info when yacc is involved
#   CFLAGS   = -U_FILE_OFFSET_BITS
# LDFLAGS  =