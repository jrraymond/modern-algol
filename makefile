IDIR=.
BUILD=build
CC=clang
CFLAGS=-I$(IDIR) -Wall -std=c99

OBJS=lexer.o dynamic_array.o
.c.o: 
	$(CC) -c $(CFLAGS) $<

malgol: $(OBJS)
	$(CC) $(CFLAGS) -o malgol malgol.c $(OBJS)


.PHONY: clean

clean:
	rm -f *.o malgol
