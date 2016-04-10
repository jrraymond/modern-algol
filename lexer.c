#include "lexer.h"

enum maTokenE ma_tokens[17] = 
  { MA_TKN_NAT_TYPE,
    MA_TKN_ARROW_TYPE,
    MA_TKN_CMD_TYPE,
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
    MA_TKN_SYMBOL};

void lex(char* inp, struct DynArray* tkns) {
  int tkn_ix = tkns->size;
  int i = 0;
  while (inp[i]) {
    switch (inp[i]) {
      case '{':
        da_append(tkns, &ma_tokens[MA_TKN_LBRACKET]);
        break;
      case '}':
        da_append(tkns, &ma_tokens[MA_TKN_RBRACKET]);
        break;
      case '(':
        da_append(tkns, &ma_tokens[MA_TKN_LPAREN]);
        break;
      case ')':
        da_append(tkns, &ma_tokens[MA_TKN_RPAREN]);
        break;
      case '\\':
        da_append(tkns, &ma_tokens[MA_TKN_LAMBDA]);
        break;
      case '|':
        da_append(tkns, &ma_tokens[MA_TKN_VBAR]);
        break;
      case  '.':
        da_append(tkns, &ma_tokens[MA_TKN_DOT]);
        break;
      case  'w':
        i+1; //noop, wont compile without
        char with[] = "with";
        if (strncmp(inp+i, with, 4)) {
          da_append(tkns, &ma_tokens[MA_TKN_DOT]);
          i += 3;
        }
        break;
      case ':':
        if (inp[i+1] == '=') {
          da_append(tkns, &ma_tokens[MA_TKN_ASSIGN]);
          ++i;
        } else {
          da_append(tkns, &ma_tokens[MA_TKN_COLON]);
        }
        break;
      case ';':
        da_append(tkns, &ma_tokens[MA_TKN_SEMICOLON]);
        break;
      case '<':
        if (inp[i+1] == '-') {
          da_append(tkns, &ma_tokens[MA_TKN_LEFTARROW]);
          ++i;
        }
        break;
    }
    ++i;
  }
}

void print_token(struct maToken t) {
  switch (t.tag) {
    case MA_TKN_NAT_TYPE:
      printf("nat");
      break;
    case MA_TKN_ARROW_TYPE:
      printf("->");
      break;
    case MA_TKN_CMD_TYPE:
      printf("cmd");
      break;
    case MA_TKN_VAR:
      printf("%s", t.val.contents);
      break;
    case MA_TKN_LBRACKET:
      printf("{");
      break;
    case MA_TKN_RBRACKET:
      printf("}");
      break;
    case MA_TKN_LPAREN:
      printf("(");
      break;
    case MA_TKN_RPAREN:
      printf(")");
      break;
    case MA_TKN_LAMBDA:
      printf("\\");
      break;
    case MA_TKN_VBAR:
      printf("|");
      break;
    case MA_TKN_DOT:
      printf(".");
      break;
    case MA_TKN_WITH:
      printf("with");
      break;
    case MA_TKN_COLON:
      printf(":");
      break;
    case MA_TKN_SEMICOLON:
      printf(";");
      break;
    case MA_TKN_LEFTARROW:
      printf("<-");
      break;
    case MA_TKN_ASSIGN:
      printf(":=");
      break;
    case MA_TKN_SYMBOL:
      printf("%u", t.val.symbol_id);
      break;
  }
}

void print_tokens(struct DynArray* tkns) {
  struct maToken *t;
  for (int i=0; i<tkns->size; ++i) {
    da_get_ref(tkns, i, (void**) &t);
    print_token(*t);
    printf(",");
  }
  printf("\n");
}
