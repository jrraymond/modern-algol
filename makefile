IDIR=$(CURDIR)
BUILD=build
CC=clang
CUTILS_DIR := $(CURDIR)/cutils
LDFLAGS := -L$(CUTILS_DIR)
CFLAGS=-I$(IDIR) -I$(CUTILS_DIR) -Wall -std=c99 -lm -g -DDEBUG=1 -Wno-missing-braces


OBJS=lexer.o parser.o actiongoto.o
.c.o: 
	$(CC) -c $(CFLAGS) $<

malgol: malgol.c $(OBJS) cutils
	$(CC) $(CFLAGS) -o malgol malgol.c $(OBJS) $(LDFLAGS) -lcutils

.PHONY: cutils
cutils:
	$(MAKE) -C $(CUTILS_DIR)


.PHONY: clean
clean:
	rm -f *.o malgol
	$(MAKE) clean -C $(CUTILS_DIR)
