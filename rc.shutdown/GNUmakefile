PREFIX  = /usr
CC      = musl-gcc
CFLAGS  = -Wextra -Wall -Os
LDFLAGS = -s
BIN     = rc.shutdown
SRC     = main.c

all: $(BIN)

$(BIN):
	$(CC) $(LDFLAGS) -o $@ $(SRC) $(LDLIBS)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f $(BIN) $(DESTDIR)$(PREFIX)/bin

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/$(BIN)

clean:
	rm -f $(BIN)

.PHONY:
	all install uninstall clean
