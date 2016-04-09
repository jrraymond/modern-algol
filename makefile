CC=clang
CFLAGS=-Isrc

malgol: src/malgol.c
	$(CC) -o build/malgol src/malgol.c $(CFLAGS)
