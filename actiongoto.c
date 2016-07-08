#include "actiongoto.h"

#include <stdlib.h>

void gen_table(
  char *fname,
  struct ActionTable *action_table,
  struct GotoTable *goto_table
  ) {

}

void action_table_init(
  struct ActionTable *action_table,
  size_t terminals,
  size_t states
  ) {
  action_table->terminals = terminals;
  action_table->states = states;
  action_table->table = malloc(sizeof(struct Action*)*states);
  for (int i=0; i<states; ++i)
    action_table->table[i] = malloc(sizeof(struct Action) * terminals);
}

void goto_table_init(
  struct GotoTable *goto_table,
  size_t nonterminals,
  size_t states
  ) {
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
