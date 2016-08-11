IDIR=$(CURDIR)
BUILD=build
CC=clang
CXX=clang++
CUTILS_DIR := $(CURDIR)/cutils
LDFLAGS := -L$(CUTILS_DIR)
override CFLAGS += -I$(IDIR) -I$(CUTILS_DIR) -Wall -std=gnu99 -g -DDEBUG=1 -Wno-missing-braces
LLVM_CFLAGS=`llvm-config --cflags`
LLVM_LDFLAGS=`llvm-config --cxxflags --ldflags --libs core executionengine mcjit interpreter analysis native bitwriter --system-libs`


OBJS=lexer.o parser.o actiongoto.o
.c.o: 
	$(CC) -c $(CFLAGS) $<

frontend: malgol.l malgol.y
	bison -d malgol.y
	flex malgol.l
	$(CC) $(CFLAGS) -o parser lex.yy.c malgol.tab.c types.c -DPMAIN

interpreter.o: frontend
	$(CC) $(CFLAGS) $(LLVM_CFLAGS) -c jit.c -o $@

interpreter: interpreter.o
	$(CC) -c $(CFLAGS) lex.yy.c
	$(CC) -c $(CFLAGS) malgol.tab.c
	$(CXX) $< $(LLVM_LDFLAGS) -o $@ $(JIT_OBJS) lex.yy.o malgol.tab.o

JIT_OBJS=codegen.o types.o

jit.o: frontend
	$(CC) $(CFLAGS) $(LLVM_CFLAGS) -c jit.c -o $@ -DJIT

jit: jit.o $(JIT_OBJS)
	$(CC) -c $(CFLAGS) lex.yy.c
	$(CC) -c $(CFLAGS) malgol.tab.c
	$(CXX) $< $(LLVM_LDFLAGS) -o $@ $(JIT_OBJS) lex.yy.o malgol.tab.o

malgol: malgol.c malgol.l malgol.y cutils
	$(CC) $(CFLAGS) -o malgol malgol.c $(OBJS) $(LDFLAGS) -lcutils

test: test_actiongoto.c $(OBJS) cutils
	$(CC) $(CFLAGS) -o test test_actiongoto.c $(OBJS) $(LDFLAGS) -lcutils -lm

.PHONY: cutils
cutils:
	$(MAKE) -C $(CUTILS_DIR)


.PHONY: clean
clean:
	rm -f *.o malgol *.tab.* lex.yy.c jit a.out test parser interpreter *.bc *.ll
	$(MAKE) clean -C $(CUTILS_DIR)
