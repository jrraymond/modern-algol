#include "actiongoto.h"

#include <stdlib.h>
#include <assert.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

void gen_table(
  char *fname,
  struct ActionTable *action_table,
  struct GotoTable *goto_table
  ) {
  char buffer[4096];

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


/* ******************** PARSING ******************** */
void skip_spaces(char *buffer, int *ix) {
  while (buffer[*ix] == ' ')
    ++(*ix);
}

bool find_token(struct TokenMap *tkns, char *token, unsigned int *tkn_id) {
  for (int i=0; i<tkns->sz; ++i) {
    if (strcmp(tkns->map[i].str, token) == 0) {
      *tkn_id = tkns->map[i].id;
      return true;
    }
  }
  return false;
}

bool parse_token(
  char *buffer,
  size_t buffer_sz,
  struct TokenMap *tkns,
  int *ix,
  unsigned int *tkn_id
  ) {
  char token_buffer[32];
  int i = *ix;
  int j = 0;
  while (i < buffer_sz && buffer[i] != ' ')
    token_buffer[j++] = buffer[i++];
  if (i >= buffer_sz)
    return false;
  token_buffer[j] = '\0';
  if (!find_token(tkns, token_buffer, tkn_id)) {
    printf("ERROR: COULD NOT FIND TOKEN \"%s\"\n", token_buffer);
    exit(0);
  }
  *ix = i;
  return true;
}

void parse_line(char *buffer, size_t buffer_sz, struct TokenMap *tkns, struct Production *prod) {
  char nonterminal[32];
  const int MAX_TOKENS = 32;
  prod->rhs = malloc(MAX_TOKENS*sizeof(unsigned int));
  prod->rhs_sz = MAX_TOKENS;
  int tkn_ix = 0;
  int ix = 0;
  while (buffer[ix] != ' ') {
    nonterminal[ix] = buffer[ix];
    ++ix;
  }
  nonterminal[ix] = '\0';
  unsigned int nonterminal_id;
  if (!find_token(tkns, nonterminal, &prod->nonterminal)) {
    printf("ERROR: COULD NOT FIND TOKEN \"%s\"\n", nonterminal);
    exit(0);
  }

  skip_spaces(buffer, &ix);
  if (buffer[ix] != '=') {
    printf("ERROR: EXPECTED '='");
    exit(0);
  }
  skip_spaces(buffer, &ix);

  while (parse_token(buffer, buffer_sz, tkns, &ix, &prod->rhs[tkn_ix])) {
    ++tkn_ix;
    if (tkn_ix >= MAX_TOKENS) {
      printf("TOO MANY TOKENS");
      exit(0);
    }
  }
  prod->rhs_sz = tkn_ix;
  realloc(prod->rhs, sizeof(unsigned int) * prod->rhs_sz);
}

void production_del(struct Production *prod) {
  free(prod->rhs);
}
