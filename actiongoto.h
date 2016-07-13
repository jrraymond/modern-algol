#ifndef __ACTIONGOTO_H
#define __ACTIONGOTO_H

#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <dynamic_array.h>
#include <unordered_set.h>
#include <hash_functions.h>


struct TokenPair {
  uint32_t id;
  char *str;
};

struct Production {
  uint32_t lhs;
  struct DynArray rhs;
};

void Production_copy(struct Production *to, struct Production *from);

void print_production(struct Production *p);
/* We will need sets of Items */
struct Item {
  struct Production production;
  size_t dot;
};

uint32_t production_hash(struct Production p);
bool production_eq(struct Production a, struct Production b);
uint32_t item_hash(struct Item i);
bool item_eq(struct Item i, struct Item j);

UNORDERED_SET_DECLARE(item, extern, struct Item, uint32_t)

/* generates action/goto tables for shift-reduce parsing */
enum ActionE {
  SHIFT=0,
  REDUCE
};

/* An action struct is a pair of the state and whether to shift or reduce */
struct Action {
  uint32_t state;
  enum ActionE sr;
};

/* An action table is a two dimensional array where the rows are the state, the
 * cols are the terminals, and the items in the cell is the action to perform
 * for the current state and terminal token
 * The struct holds the dimensions of the array.
 */
struct ActionTable {
  struct Action **table;
  size_t terminals;
  size_t states;
};

/* A goto table is a two dimensional array where the rows are states, the cols
 * are nonterminal tokens, and the item in the cell is the state to goto for
 * the given state and nonterminal token.
 * The struct holds the dimensions of the array.
 */
struct GotoTable {
  uint32_t **table;
  size_t nonterminals;
  size_t states;
};

void gen_table(
  char *fname,
  struct ActionTable *action_table,
  struct GotoTable *goto_table
  );

/* Initializes action table struct by allocating memory and setting dimension
 * fields.
 */
void action_table_init(
  struct ActionTable *action_table,
  size_t terminals,
  size_t states
  );

/* Initializes goto table struct by allocating memory and setting dimension
 * fields.
 */
void goto_table_init(
  struct GotoTable *goto_table,
  size_t nonterminals,
  size_t states
  );

/* Frees memory held by action table struct */
void action_table_del(struct ActionTable *action_table);

/* Frees memory held by goto table struct */
void goto_table_del(struct GotoTable *goto_table);


void skip_spaces(const char *const buffer, int *const ix);

bool find_token(struct DynArray *tkns, char *token, uint32_t *tkn_id);

/* parses a single token from a character buffer starting at ix
 * returns true of token parsed, false otherwise
 */
bool parse_token(
  const char *const buffer,               //char buffer
  const size_t buffer_sz,           //length of buffer
  struct DynArray *const tkns,      //dynamic array of TokenPair
  int *const ix,                    //index to start looking
  uint32_t *const tkn_id        //index of token that is parsed
  );

/* parses line of input into a production */
void parse_line(
  const char *const buffer,
  const size_t buffer_sz,
  struct DynArray *const tkns,
  struct Production *const prod //initialized production
   );

/* parses file and fills two dynamic array with productions and a token map
 * from strings to ids, respectively
 */
void parse_grammar(
  const char *const fname,                  //filename
  struct DynArray *const productions, //initialized dynamic array of struct Production
  struct DynArray *const token_map    //initialized dynamic array of struct TokenPair
  );

void production_init(struct Production *prod);
void production_del(struct Production *prod);

static const size_t MAX_TOKEN_SZ = 32;


/* generates all items from a production and adds them to the item set.
 */
void gen_prod_items(
  struct Production *p, 
  us_item_t *item_set
  );

void print_item(struct Item *item);
  


#endif
