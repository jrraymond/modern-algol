#ifndef __MODERN_ALGOL_LEXER_H
#define __MODERN_ALGOL_LEXER_H

#include <stdbool.h>
#include <ctype.h>
#include "dynamic_array.h"

enum maTokenE {
  MA_TKN_NAT_TYPE,
  MA_TKN_ARROW_TYPE,
  MA_TKN_CMD_TYPE,
  MA_TKN_NAT,
  MA_TKN_VAR,
  MA_TKN_LBRACKET,
  MA_TKN_RBRACKET,
  MA_TKN_LPAREN,
  MA_TKN_RPAREN,
  MA_TKN_LAMBDA,
  MA_TKN_VBAR,
  MA_TKN_DOT,
  MA_TKN_WITH,
  MA_TKN_COLON,
  MA_TKN_SEMICOLON,
  MA_TKN_LEFTARROW,
  MA_TKN_ASSIGN,
  MA_TKN_SYMBOL,
};

enum maSymbolE {
  MA_SYM_REC,
  MA_SYM_CMD,
  MA_SYM_RET,
  MA_SYM_BND,
  MA_SYM_IN,
  MA_SYM_DCL,
  MA_SYM_SUCC,
  MA_SYM_AT,
  MA_SYM_ZERO,
};

struct maToken {
  enum maTokenE tag;
  union {
    unsigned int symbol_id;
    unsigned int nat;
    char* contents;
  } val;
};

void ma_lex(char* inp, struct DynArray *tkns);

void ma_print_token(struct maToken t);
void ma_print_tokens(struct DynArray* tkns);
void ma_tkn_del(struct maToken* tkn);

#endif
