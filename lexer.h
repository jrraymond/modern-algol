#ifndef __MODERN_ALGOL_LEXER_H
#define __MODERN_ALGOL_LEXER_H

#include <stdbool.h>
#include <ctype.h>
#include "dynamic_array.h"
#include "hashtable.h"
#include "debug.h"

enum maTokenE {
  MA_TKN_NAT_TYPE,    //types
  MA_TKN_ARROW_TYPE,
  MA_TKN_CMD_TYPE,
  MA_TKN_VAR,         //variables
  MA_TKN_LBRACKET,    //not stringy tokens
  MA_TKN_RBRACKET,
  MA_TKN_LPAREN,
  MA_TKN_RPAREN,
  MA_TKN_LAMBDA,
  MA_TKN_VBAR,
  MA_TKN_DOT,
  MA_TKN_COLON,
  MA_TKN_SEMICOLON,
  MA_TKN_RIGHTARROW,
  MA_TKN_LEFTARROW,
  MA_TKN_ASSIGN,
  MA_TKN_FIX,         //stringy tokens
  MA_TKN_CMD,
  MA_TKN_RET,
  MA_TKN_BND,
  MA_TKN_IN,
  MA_TKN_IS
  MA_TKN_DCL,
  MA_TKN_AT,
  MA_TKN_SUCC,
  MA_TKN_ZERO,
  MA_TKN_NAT,         //actual nats and their ops
  MA_TKN_PLUS,
  MA_TKN_DASH,
  MA_TKN_ASTERISK,
  MA_TKN_PERCENT,
  MA_TKN_FWD_SLASH,
  MA_TKN_CARROT
};

struct maToken {
  enum maTokenE tag;
  union {
    unsigned int nat;
    char* contents;
  } val;
};

void ma_lex(char* inp, struct DynArray *tkns, struct hashtable *keyword_table);

void ma_print_token(struct maToken t);
void ma_print_tokens(struct DynArray* tkns);
void ma_tkn_del(struct maToken* tkn);

void keyword_table_init(struct hashtable *table);
void keyword_table_del(struct hashtable *table);

struct maTknStrPair {
  maTokenE tkn;
  char[4] str;
};

static const size_t ma_tkn_num_keywords = 9;
static const maTknStrPair ma_tkn_keywords[ma_tkn_num_keywords][4] =
  { { MA_TKN_NAT_TYPE, "nat\0"},
    { MA_TKN_CMD_TYPE, "cmd\0"},
    { MA_TKN_SUCC, "S\0"},
    { MA_TKN_ZERO, "Z\0"},
    { MA_TKN_FIX, "fix\0"},
    { MA_TKN_IS, "is\0"},
    { MA_TKN_IN, "in\0"},
    { MA_TKN_RET, "ret\0"},
    { MA_TKN_BDN, "bnd\0"},
    { MA_TKN_DCL, "dcl\0"}
  };

#endif
