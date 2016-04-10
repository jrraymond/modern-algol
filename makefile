IDIR=src
BUILD=build
CC=clang
CFLAGS=-I$(IDIR) -Wall

$(BUILD)/malgol: $(IDIR)/malgol.c $(BUILD)/lexer.o
	$(CC) -o $(BUILD)/malgol $(IDIR)/malgol.c $(CFLAGS)

$(BUILD)/dynamic_array.o: $(IDIR)/dynamic_array.h 
	$(CC) -o $(BUILD)/dynamic_array.o -c $(IDIR)/dynamic_array.c $(CFLAGS)

$(BUILD)/lexer.o: $(BUILD)/dynamic_array.o $(IDIR)/lexer.h 
	$(CC) -o $(BUILD)/lexer.o -c $(IDIR)/lexer.c $(CFLAGS)


.PHONY: clean

clean:
	rm -f $(BUILD)/*
