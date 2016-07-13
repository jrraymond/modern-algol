#include "actiongoto.h"

void print_u32(uint32_t i) {
  printf("%u", i);
}
void print_item_value(struct Item i) {
  print_item(&i);
}


void test_parse_grammar() {
  char* fname = "test_grammar_parens.txt";

  struct DynArray productions;
  struct DynArray token_map;

  da_DynArray_init(&productions, 1024, sizeof(struct Production));
  printf("initialized productions\n");
  da_DynArray_init(&token_map, 1024, sizeof(struct TokenPair));
  printf("initialized tokenpair\n");

  parse_grammar(fname, &productions, &token_map);
  printf("parsed grammar: %zu productions\n", productions.size);

  /* create set of all items from productions */
  us_item_t items;
  us_item_init(&items, productions.size * 8);

  for (int i=0; i<productions.size; ++i) {
    struct Production *p;
    da_get_ref(&productions, i, (void**) &p);
    gen_prod_items(p, &items);
  }
  printf("created %zu items\n", items.size);

  for (size_t itr = us_item_begin(&items);
      itr != us_item_end(&items);
      us_item_next(&items, &itr))
  {
    print_item(&items.elems[itr]);
  }

  da_DynArray_del(&productions);
  printf("destructed productions\n");

  da_DynArray_del(&token_map);
  printf("destructed tokenpair\n");

  us_item_del(&items);
  printf("destructed item set\n");
}

int main(int argc, char** argv) {

  test_parse_grammar();

  return EXIT_SUCCESS;
}
