#include "lexer.h"

void add_var_tkn(char* buffer, size_t b_sz, struct DynArray* tkns) {
  struct maToken t;
  t.tag = MA_TKN_VAR;
  t.val.contents = malloc(sizeof(char)*(b_sz+1));
  memcpy(t.val.contents, buffer, b_sz);
  t.val.contents[b_sz] = '\0';
  da_append(tkns, &t);
}

bool is_variable_char(char c) {
  return isalpha(c) || isdigit(c) || c == '_';
}

void lex(char* inp, struct DynArray* tkns) {
  char with[] = "with";
  char buffer[1024];
  int buffer_ix = 0;
  int tkn_ix = tkns->size;
  int i = 0;
  struct maToken t;
  while (inp[i]) {
    if (buffer_ix > 0 && (isspace(inp[i]) || !is_variable_char(inp[i]))) {
      add_var_tkn(buffer, buffer_ix, tkns);
      buffer_ix = 0;
    } 
    switch (inp[i]) {
      case '{':
        t.tag = MA_TKN_LBRACKET;
        da_append(tkns, &t);
        break;
      case '}':
        t.tag = MA_TKN_RBRACKET;
        da_append(tkns, &t);
        break;
      case '(':
        t.tag = MA_TKN_LPAREN;
        da_append(tkns, &t);
        break;
      case ')':
        t.tag = MA_TKN_RPAREN;
        da_append(tkns, &t);
        break;
      case '\\':
        t.tag = MA_TKN_LAMBDA;
        da_append(tkns, &t);
        break;
      case '|':
        t.tag = MA_TKN_VBAR;
        da_append(tkns, &t);
        break;
      case '.':
        t.tag = MA_TKN_DOT;
        da_append(tkns, &t);
        break;
      case 'w':
        if (strncmp(inp+i, with, 4) == 0) {
          t.tag = MA_TKN_WITH;
          da_append(tkns, &t);
          i += 3;
          break;
        } else {
          goto default_label;
        }
      case ':':
        if (inp[i+1] == '=') {
          t.tag = MA_TKN_ASSIGN;
          da_append(tkns, &t);
          ++i;
        } else {
          t.tag = MA_TKN_COLON;
          da_append(tkns, &t);
        }
        break;
      case ';':
        t.tag = MA_TKN_SEMICOLON;
        da_append(tkns, &t);
        break;
      case '<':
        if (inp[i+1] == '-') {
          t.tag = MA_TKN_LEFTARROW;
          da_append(tkns, &t);
          ++i;
        }
        break;
default_label:
      default:
        if (!isspace(inp[i])) {
          buffer[buffer_ix] = inp[i];
          ++buffer_ix;
        }
    }
    ++i;
  }
  if (buffer_ix > 0) {
    add_var_tkn(buffer, buffer_ix, tkns);
  }
  printf("%zu, %zu\n", strlen(inp), tkns->size);
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
    case MA_TKN_NAT:
      printf("%u", t.val.nat);
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
