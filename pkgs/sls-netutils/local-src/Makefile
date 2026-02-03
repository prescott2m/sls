.POSIX:

PREFIX  = /usr
CC      = $(TARGET_TUPLE)-gcc
CFLAGS  = -Wextra -Wall -Os -std=c99
LDFLAGS = -s

TOOLS = ping up ipa

all: $(TOOLS)

$(TOOLS): %: %.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< $(LDLIBS)

install: all
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f $(TOOLS) $(DESTDIR)$(PREFIX)/bin

uninstall:
	rm -f $(addprefix $(DESTDIR)$(PREFIX)/bin/,$(TOOLS))

clean:
	rm -f $(TOOLS)

.PHONY: all install uninstall clean
