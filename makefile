IDIR=.
BUILD=build
CC=clang
CFLAGS=-I$(IDIR) -Wall -std=c99 -lm -g -DDEBUG=0

OBJS=lexer.o dynamic_array.o hashtable.o
.c.o: 
	$(CC) -c $(CFLAGS) $<

malgol: malgol.c $(OBJS)
	$(CC) $(CFLAGS) -o malgol malgol.c $(OBJS)


.PHONY: clean

clean:
	rm -f *.o malgol
