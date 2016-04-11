


#define _GNU_SOURCE //access to nonstandard GNU/Linux extensions, like get_line

#include <stdio.h>
#include <stdbool.h>
#include "types.h"
#include "lexer.h"



void test_lexer() {
  char* line = NULL;
  size_t line_sz;
  while (getline(&line, &line_sz, stdin) > 0) {
    struct DynArray tkns;
    da_DynArray_init(&tkns, line_sz/8, sizeof(struct maToken));
    ma_lex(line, &tkns);
    ma_print_tokens(&tkns);
    da_map(&tkns,(void(*)(void*))&ma_tkn_del);
    da_DynArray_del(&tkns);
  };

}

int main(int argc, char** argv) {
  printf("Modern Algol\n");
  test_lexer();
  return 0;
}
