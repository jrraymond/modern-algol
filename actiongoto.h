#ifndef __ACTIONGOTO_H
#define __ACTIONGOTO_H

/* generates action/goto tables for shift-reduce parsing */
enum ActionE = { SHIFT=0, REDUCE };

/* An action struct is a pair of the state and whether to shift or reduce */
struct Action {
  unsigned int state;
  enum ActionE sr;
}

/* An action table is a two dimensional array where the rows are the state, the
 * cols are the terminals, and the items in the cell is the action to perform
 * for the current state and terminal token
 * The struct holds the dimensions of the array.
 */
struct ActionTable {
  struct Action **table;
  size_t terminals;
  size_t states;
}

/* A goto table is a two dimensional array where the rows are states, the cols
 * are nonterminal tokens, and the item in the cell is the state to goto for
 * the given state and nonterminal token.
 * The struct holds the dimensions of the array.
 */
struct GotoTable {
  unsigned int **table;
  size_t nonterminals;
  size_t states;
}

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


#endif
