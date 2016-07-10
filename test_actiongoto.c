#include "actiongoto.h"


void test_parse_grammar() {
  char* fname = "test_grammar_arith.txt";

  struct DynArray productions;
  struct DynArray token_map;

  da_DynArray_init(&productions, 0, sizeof(struct Production));
  da_DynArray_init(&token_map, 0, sizeof(struct TokenPair));

  parse_grammar(fname, &productions, &token_map);

  da_DynArray_del(&productions);
  da_DynArray_del(&token_map);
}

int main(int argc, char** argv) {

  test_parse_grammar();

  return EXIT_SUCCESS;
}
