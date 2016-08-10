IDIR=$(CURDIR)
BUILD=build
CC=gcc
CUTILS_DIR := $(CURDIR)/cutils
LDFLAGS := -L$(CUTILS_DIR)
CFLAGS=-I$(IDIR) -I$(CUTILS_DIR) -Wall -std=gnu99 -g -DDEBUG=1 -Wno-missing-braces


OBJS=lexer.o parser.o actiongoto.o
.c.o: 
	$(CC) -c $(CFLAGS) $<

frontend: malgol.l malgol.y
	bison -d malgol.y
	flex malgol.l
	$(CC) $(CFLAGS) lex.yy.c malgol.tab.c -DPMAIN

interpreter: frontend
	$(CC) $(CFLAGS) lex.yy.c malgol.tab.c interpreter.c

jit: frontend
	$(CC) $(CFLAGS) lex.yy.c malgol.tab.c interpreter.c -DJIT


malgol: malgol.c malgol.l malgol.y cutils
	$(CC) $(CFLAGS) -o malgol malgol.c $(OBJS) $(LDFLAGS) -lcutils

test: test_actiongoto.c $(OBJS) cutils
	$(CC) $(CFLAGS) -o test test_actiongoto.c $(OBJS) $(LDFLAGS) -lcutils -lm

.PHONY: cutils
cutils:
	$(MAKE) -C $(CUTILS_DIR)


.PHONY: clean
clean:
	rm -f *.o malgol *.tab.* lex.yy.c
	$(MAKE) clean -C $(CUTILS_DIR)
