#include "actiongoto.h"

#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>

#include "debug.h"

UNORDERED_SET_IMPL(item, inline, struct Item, uint64_t, item_hash, item_eq)


void gen_table(
  char *fname,
  struct ActionTable *action_table,
  struct GotoTable *goto_table
  )
{
  struct DynArray productions;
  struct DynArray token_map;

  da_DynArray_init(&productions, 1024, sizeof(struct Production));
  da_DynArray_init(&token_map, 1024, sizeof(struct TokenPair));

  /* parse productions of grammar from file */
  parse_grammar(fname, &productions, &token_map);


  /* create set of all items from productions */
  us_item_t items;
  us_item_init(&items, productions.size * 8);

  for (int i=0; i<productions.size; ++i) {
    struct Production *p;
    da_get_ref(&productions, i, (void**) &p);
    gen_prod_items(p, &items);
  }


  da_DynArray_del(&productions);
  da_DynArray_del(&token_map);

  us_item_del(&items);
}

void action_table_init(
  struct ActionTable *action_table,
  size_t terminals,
  size_t states
  )
{
  action_table->terminals = terminals;
  action_table->states = states;
  action_table->table = malloc(sizeof(struct Action*) * states);
  for (int i=0; i<states; ++i)
    action_table->table[i] = malloc(sizeof(struct Action) * terminals);
}

void goto_table_init(
  struct GotoTable *goto_table,
  size_t nonterminals,
  size_t states
  )
{
  goto_table->nonterminals = nonterminals;
  goto_table->states = states;
  goto_table->table = malloc(sizeof(unsigned int*) * states);
  for (int i=0; i<states; ++i)
    goto_table->table[i] = malloc(sizeof(unsigned int) * nonterminals);
}

void action_table_del(struct ActionTable *action_table) {
  for (int i=0; i<action_table->states; ++i)
    free(action_table->table[i]);
  free(action_table->table);
}

void goto_table_del(struct GotoTable *goto_table) {
  for (int i=0; i<goto_table->states; ++i)
    free(goto_table->table[i]);
  free(goto_table->table);
}


/* ******************** PARSING ******************** */
void skip_spaces(const char *const buffer, int *const ix) {
  while (buffer[*ix] == ' ')
    ++(*ix);
}

bool find_token(struct DynArray *tkns, char *token, unsigned int *tkn_id) {
  for (int i=0; i<tkns->size; ++i) {
    struct TokenPair *tkn_pair;
    da_get_ref(tkns, i, (void**) &tkn_pair);
    if (strcmp(tkn_pair->str, token) == 0) {
      *tkn_id = tkn_pair->id;
      return true;
    }
  }
  return false;
}

bool parse_token(
  const char *const buffer,               //char buffer
  const size_t buffer_sz,           //length of buffer
  struct DynArray *const tkns,      //dynamic array of TokenPair
  int *const ix,                    //index to start looking
  unsigned int *const tkn_id        //index of token that is parsed
  )
{
  char *token_buffer = malloc(MAX_TOKEN_SZ * sizeof(char));
  int i = *ix;
  int j = 0; //length of token
  while (j < MAX_TOKEN_SZ - 1 && i < buffer_sz && !isspace(buffer[i]))
    token_buffer[j++] = buffer[i++];
  if (i > buffer_sz) {
    free(token_buffer);
    return false;
  }
  token_buffer[j] = '\0';

  bool exists = find_token(tkns, token_buffer, tkn_id);
  if (!exists) {
    struct TokenPair new_tp = {.id = tkns->size, .str = token_buffer};
    *tkn_id = new_tp.id;
    da_append(tkns, &new_tp);
  } else {
    free(token_buffer);
  }
  *ix = i;
  return true;
}

void parse_line(
  const char *const buffer,
  const size_t buffer_sz,
  struct DynArray *const tkns,
  struct Production *const prod //initialized production
  ) 
{
  int ix = 0;
  unsigned int lhs_id;
  bool succ = parse_token(buffer, buffer_sz, tkns, &ix, &lhs_id);
  if (!succ) {
    fprintf(stderr, "ERROR: COULD NOT PARSE LHS: %s\n", buffer);
    exit(EXIT_SUCCESS);
  }
  prod->lhs = lhs_id;
  printf("LHS: %u\n", prod->lhs);

  skip_spaces(buffer, &ix);
  if (buffer[ix++] != '-' || buffer[ix++] != '>') {
    fprintf(stderr, "ERROR: EXPECTED '->'");
    exit(EXIT_SUCCESS);
  }

  printf("RHS:");
  while (ix < buffer_sz && buffer[ix] != '\n') {
    skip_spaces(buffer, &ix);

    unsigned int tkn_id;
    bool ok = parse_token(buffer, buffer_sz, tkns, &ix, &tkn_id);
    if (!ok) {
      break;
    }
    da_append(&prod->rhs, (void**) &tkn_id);
    printf("%u,", tkn_id);
  }
  printf("%s", "\n");
}

void parse_grammar(
  const char *const fname,
  struct DynArray *const productions,
  struct DynArray *const token_map
  )
{
  const int MAX_LINE_SZ = 128;
  FILE *fp;
  char line[MAX_LINE_SZ];

  fp = fopen(fname, "r");
  if (!fp) {
    fprintf(stderr, "ERROR: file not found\n");
    exit(EXIT_FAILURE);
  }
  debug_print("opened file: %s\n", fname);

  while (fgets(line, MAX_LINE_SZ, fp) != NULL) {
    size_t len = strlen(line);
    debug_print("read %zu chars\n", len);
    struct Production p;
    production_init(&p);
    parse_line(line, len, token_map, &p);
    da_append(productions, &p); //move, so no del

    printf("tokens:\n");
    for (int i=0; i<token_map->size; ++i) {
      struct TokenPair *p;
      da_get_ref(token_map, i, (void**) &p);
      printf("%u:%s,",p->id,p->str);
    }
    printf("\n");
  }
  int err = fclose(fp);

  debug_print("closed file: %s\n", fname);
  if (err)
    fprintf(stderr, "ERROR: while closing file %s\n", fname);
}

void production_init(struct Production *prod) {
  da_DynArray_init(&prod->rhs, 0, sizeof(unsigned int));
}

void production_del(struct Production *prod) {
  da_DynArray_del(&prod->rhs);
}

/* Items */

uint64_t item_hash(struct Item item) {
  int i, j;
  uint32_t h0 = uint32_hash_thomas_mueller(item.lhs);
  for (i = 0; i < item.before_size; ++i) {
    uint32_t hi = uint32_hash_thomas_mueller(item.before[i]);
    h0 += hi * (i + 1);
  }
  for (j = 0; j < item.after_size; ++j) {
    uint32_t hj = uint32_hash_thomas_mueller(item.after[j]);
    h0 += hj * (j + i + 1);
  }
  return h0;
}

bool item_eq(struct Item a, struct Item b) {
  if (a.lhs != b.lhs)
    return false;
  if (a.before_size != b.before_size)
    return false;
  if (a.after_size != b.after_size)
    return false;
  for (int i=0; i<a.before_size; ++i) {
    if (a.before[i] != b.before[i])
      return false;
  }
  for (int i=0; i<a.after_size; ++i) {
    if (a.after[i] != b.after[i])
      return false;
  }
  return true;
}

void gen_prod_items(
  struct Production *p, 
  us_item_t *item_set
  ) {
  for (int i=0; i<=p->rhs.size; ++i) {
    struct Item item;
    item.lhs = p->lhs;
    item.before_size = i;
    item.before = malloc(item.before_size * sizeof(uint32_t));
    for (int j=0; j<item.before_size; ++j) {
      da_get(&p->rhs, j, (void*) &item.before[j]);
    }
    item.after_size = p->rhs.size - i;
    for (int j=0; j<item.after_size; ++j) {
      da_get(&p->rhs, i+j, (void*) &item.before[j]);
    }
  }
}

void print_item(struct Item *item) {
  printf("%lu -> ", item->lhs);
  for (int i=0; i<item->before_size; ++i) {
    printf("%lu ", item->before[i]);
  }
  printf(". ");
  for (int i=0; i<item->after_size; ++i) {
    printf("%lu ", item->after[i]);
  }
  printf("\n");
}

