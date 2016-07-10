#include "actiongoto.h"


void test_parse_grammar() {
  char* fname = "test_grammar_arith.txt";

  struct DynArray productions;
  struct DynArray token_map;

  da_DynArray_init(&productions, 1024, sizeof(struct Production));
  printf("initialized productions\n");
  da_DynArray_init(&token_map, 1024, sizeof(struct TokenPair));
  printf("initialized tokenpair\n");

  parse_grammar(fname, &productions, &token_map);
  printf("parsed grammar\n");

  da_DynArray_del(&productions);
  printf("destructed productions\n");
  da_DynArray_del(&token_map);
  printf("destructed tokenpair\n");
}

int main(int argc, char** argv) {

  test_parse_grammar();

  return EXIT_SUCCESS;
}
