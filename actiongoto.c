#include "actiongoto.h"

#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>

#include "debug.h"
#include "dense_graph.h"
#include "unordered_set.h"



/* We need to keep track of sets of items */
UNORDERED_SET_IMPL(item, inline, struct Item, uint32_t, item_hash, item_eq)

uint32_t us_item_hash(us_item_t *item_set) {
  uint32_t hash = 0;
  for (size_t itr = us_item_begin(item_set);
      itr != us_item_end(item_set);
      us_item_next(item_set, &itr)
      ) {
    hash += item_hash(item_set->elems[itr]);
  }
  return hash;
}


UNORDERED_SET_DECLARE(usitem, static inline, us_item_t*, uint32_t)
UNORDERED_SET_IMPL(usitem, static, us_item_t*, uint32_t, us_item_hash, us_item_eq)

/* The DFA has nodes of sets of items and edges as symbols */
DENSE_GRAPH_INIT(us_item_u8, uint32_t, us_item_t, uint32_t)


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
    da_append(&prod->rhs, (void*) &tkn_id);
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
bool production_eq(struct Production a, struct Production b) {
  if (a.lhs != b.lhs)
    return false;
  if (a.rhs.size != b.rhs.size)
    return false;
  uint32_t x, y;
  for (int i=0; i<a.rhs.size; ++i) {
    da_get(&a.rhs, i, (void*) &x);
    da_get(&b.rhs, i, (void*) &y);
    if (x != y)
      return false;
  }
  return true;
}

uint32_t production_hash(struct Production p) {
  uint32_t h0 = uint32_hash_thomas_mueller(p.lhs);
  for (int i=0; i<p.rhs.size; ++i) {
    uint32_t x;
    da_get(&p.rhs, i, (void*) &x);
    uint32_t hi = uint32_hash_thomas_mueller(x);
    h0 += hi * (i+1);
  }
  return h0;
}

void Production_copy(struct Production *to, struct Production *from) {
  to->lhs = from->lhs;
  da_DynArray_copy(&to->rhs, &from->rhs);
}

uint32_t item_hash(struct Item item) {
  uint32_t h0 = uint32_hash_thomas_mueller(item.dot);
  uint32_t h1 = production_hash(item.production);
  return h0 + h1;
}

bool item_eq(struct Item a, struct Item b) {
  if (a.dot != b.dot)
    return false;
  return production_eq(a.production, b.production);
}

void gen_prod_items(
  struct Production *p, 
  us_item_t *item_set
  ) {
  for (int i=0; i<=p->rhs.size; ++i) {
    struct Item item;
    Production_copy(&item.production, p);
    item.dot = i;
    us_item_insert(item_set, item);
  }
}
void gen_closure(
  us_item_t *to,
  us_item_t *from,
  us_item_t *all_items
  )
{
  /* todo is a stack of items to be added to the closure and also have their
   * subitems added to the closure
   */
  struct DynArray todo;
  da_DynArray_init(&todo, from->size, sizeof(struct Item));

  for (size_t itr = us_item_begin(from);
      itr != us_item_end(from);
      us_item_next(from, &itr))
  {
    /* every item in from is in closure(from) */
    da_append(&todo, &from->elems[itr]);
  }
  while (todo.size > 0) {
    struct Item item;
    da_get(&todo, todo.size - 1, &item);
    da_pop(&todo);

    /* if item is of the form A -> alpha B beta, we must check for items B ->
     * gamma and add them to the todo. We do a brute for search by considering
     * each possible single grammar symbol of A -> alpha B beta, and then
     * search for productions B -> gamma.
     */
    for (size_t i=0; i<item.production.rhs.size; ++i) {
      uint32_t b;
      da_get(&todo, i, (void*) &b);
      for (size_t itr = us_item_begin(all_items);
          itr != us_item_end(all_items);
          us_item_next(all_items, &itr))
      {
        struct Item *itm_ptr = &all_items->elems[itr];
        if (itm_ptr->dot != 0)
          continue;
        if (itm_ptr->production.lhs != b)
          continue;
        da_append(&todo, itm_ptr);
      }
    }
    us_item_insert(to, item); //copy memory????
  }

  da_DynArray_del(&todo);
}

void gen_goto(
  us_item_t *to,
  us_item_t *from,
  us_item_t *all_items,
  uint32_t symbol
  )
{
  us_item_t set;
  us_item_init(&set, from->size);
  for (size_t itr = us_item_begin(from);
      itr != us_item_end(from);
      us_item_next(from, &itr)
    ){
    struct Item *item = &from->elems[itr];
    size_t x_ix = item->dot;
    //if dot is on the end, we can't move it over x
    if (x_ix >= item->production.rhs.size - 1)
      continue;
    uint32_t x;
    da_get(&item->production.rhs, x_ix, &x);
    struct Item next;
    next.dot = x_ix + 1;
    Production_copy(&next.production, &item->production);
    us_item_insert(&set, next);
  }
  gen_closure(to, &set, all_items);
  us_item_del(&set);
}


void gen_dfa(
  struct DenseGraph_us_item_u8_t *dfa,
  us_item_t *all_items,
  struct Item *start
  )
{
  us_item_t tmp;
  us_item_init(&tmp, 1);
  us_item_insert(&tmp, *start);

  us_item_t start_state;
  us_item_init(&start_state, 8);

  gen_closure(&start_state, &tmp, all_items);

  uint8_t start_index = dg_us_item_u8_add_node(dfa, start_state);

  us_usitem_t states;
  us_usitem_init(&states, 8);
  us_usitem_insert(&states, &start_state);
  

  bool additions;
  do {
    additions = false;
    for (size_t state_itr = dg_us_item_u8_nodes_begin(dfa);
        state_itr != dg_us_item_u8_nodes_end(dfa);
        dg_us_item_u8_nodes_next(dfa, &state_itr)
        ) {
      us_item_t *curr_state;
      dg_us_item_u8_get_node_ref(dfa, state_itr, &curr_state);
      for (size_t item_itr = us_item_begin(curr_state);
          item_itr != us_item_end(curr_state);
          us_item_next(curr_state, &item_itr)
          ) {
        us_item_t new_state;
        us_item_init(&new_state, 0);
        struct Item *item = &curr_state->elems[item_itr];
        if (item->dot == item->production.rhs.size) {
          continue;
        }
        uint8_t symbol;
        da_get(&item->production.rhs, item->dot, &symbol);
        gen_goto(&new_state, curr_state, all_items, symbol);
        //if new state not already a state th
        //then make new one and add an edge from curr state  to new state
        if (!us_usitem_contains(&states, &new_state)) {
          uint8_t new_index = dg_us_item_u8_add_node(dfa, new_state);
          uint8_t new_edge_index = dg_us_item_u8_add_edge(dfa, state_itr, new_index, symbol);
          us_usitem_insert(&states, &new_state);
          additions = true;
        }
      }
    }
  } while (additions);

  us_item_del(&tmp);
  us_usitem_del(&states);
}

void print_production(struct Production *p) {
  printf("%u -> ", p->lhs);
  for (int i=0; i<p->rhs.size; ++i) {
    uint32_t x;
    da_get(&p->rhs, i, (void*) &x);
    printf("%u,", x);
  }
}


void print_item(struct Item *item) {
  printf("%u(%lu|%lu) -> ", item->production.lhs, item->dot, item->production.rhs.size);
  for (int i=0; i<item->dot; ++i) {
    uint32_t x;
    da_get(&item->production.rhs, i, (void*) &x);
    printf("%u ", x);
  }
  printf(". ");
  for (int i=item->dot; i<item->production.rhs.size; ++i) {
    uint32_t x;
    da_get(&item->production.rhs, i, (void*) &x);
    printf("%u ", x);
  }
  printf("\n");
}

