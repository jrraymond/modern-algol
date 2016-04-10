


#define _GNU_SOURCE //access to nonstandard GNU/Linux extensions, like get_line

#include <stdio.h>
#include <stdbool.h>
#include "types.h"
#include "lexer.h"


int main(int argc, char** argv) {
  printf("Modern Algol\n");

  char* line = NULL;
  size_t line_sz;
  while (getline(&line, &line_sz, stdin) > 0) {
    printf("%s", line);

    struct DynArray tkns;
    da_DynArray_init(&tkns, line_sz/8, sizeof(struct maToken));
    lex(line, &tkns);
    da_DynArray_del(&tkns);
  };

  return 0;
}
