


#define _GNU_SOURCE //access to nonstandard GNU/Linux extensions, like get_line

#include <stdio.h>
#include <stdbool.h>
#include "types.h"
#include "lexer.h"



void test_lexer() {
  struct hashtable keyword_table;
  keyword_table_init(&keyword_table);

#if DEBUG
  for (int i=0; i<ma_tkn_num_keywords; ++i) {
    char* k = (char*) ma_tkn_keywords[i].str;
    enum maTokenE *v;
    if (ht_get_ref(&keyword_table, (void**) &k, (void**) &v))
      printf("%i, %s, %u\n", i, k, *v);
  }
#endif

  char* line = NULL;
  size_t line_sz;
  while (getline(&line, &line_sz, stdin) > 0) {
    struct DynArray tkns;
    da_DynArray_init(&tkns, line_sz/8, sizeof(struct maToken));
    ma_lex(line, &tkns, &keyword_table);
    ma_print_tokens(&tkns);
    da_map(&tkns,(void(*)(void*))&ma_tkn_del);
    da_DynArray_del(&tkns);
  };
  keyword_table_del(&keyword_table);
}

int main(int argc, char** argv) {
  printf("Modern Algol\n");
  test_lexer();
  return 0;
}
