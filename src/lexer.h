#ifndef __MODERN_ALGOL_LEXER_H
#define __MODERN_ALGOL_LEXER_H

enum ma_token {
  MA_TKN_NAT_TYPE,
  MA_TKN_ARROW_TYPE,
  MA_TKN_CMD_TYPE,
  MA_TKN_VAR,
  MA_TKN_NAT,
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

enum ma_symbol {
  MA_SYM_REC,
  MA_SYM_CMD,
  MA_SYM_RET,
  MA_SYM_BND,
  MA_SYM_IN,
  MA_SYM_DCL,
  MA_SYM_SUCC,
  MA_SYM_AT,
};

struct maToken {
  enum ma_symbol tag;
  union {
    unsigned int symbol_id;
    char* contents;
  } val;
};
#endif
