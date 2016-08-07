#include "lexer.h"

#include <assert.h>

struct maTknStrPair ma_tkn_keywords[] =
  { { MA_TKN_NAT_TYPE, "nat\0"},
    { MA_TKN_CMD, "cmd\0"},
    { MA_TKN_SUCC, "S\0"},
    { MA_TKN_ZERO, "Z\0"},
    { MA_TKN_FIX, "fix\0"},
    { MA_TKN_IS, "is\0"},
    { MA_TKN_IN, "in\0"},
    { MA_TKN_RET, "ret\0"},
    { MA_TKN_BND, "bnd\0"},
    { MA_TKN_DCL, "dcl\0"}
  };

size_t ma_tkn_num_keywords = sizeof(ma_tkn_keywords)/sizeof(struct maTknStrPair);

bool is_tag_keyword(enum maTokenE tag) {
  for (int i=0; i<ma_tkn_num_keywords; ++i) {
    if (tag == ma_tkn_keywords[i].tkn)
      return true;
  }
  return false;
}

/* returns char* to string corresponding to keyword tag.
 * NULL if tag does not correspond to a stringy keyword.
 * char* does NOT need to be freed.
 */
char* keyword_string(enum maTokenE tag) {
  for (int i=0; i<ma_tkn_num_keywords; ++i) {
    if (tag == ma_tkn_keywords[i].tkn)
      return ma_tkn_keywords[i].str;
  }
  return NULL;
}

void ma_tkn_del(struct maToken* tkn) {
  switch (tkn->tag) {
    case MA_TKN_VAR:
      free(tkn->val.contents);
      break;
    default:
      (void) 0;
  }
}

bool is_num(char* buffer, size_t sz) {
  for (int i=0; i<sz; ++i) {
    if (!isdigit(buffer[i])) {
      return false;
    }
  }
  return true;
}

bool is_variable_char(char c) {
  return isalpha(c) || isdigit(c) || c == '_';
}

bool string_cmp(void* p0, void* p1) {
  char* s0 = *(char**) p0;
  char* s1 = *(char**) p1;
  return strcmp(s0, s1) == 0;
}

/* initializes the keyword table, which is a map from the keyword to their
 * corresponding token.
 * The keyword table owns the strings and is responsible for freeing them.
 *
 */
void keyword_table_init(struct hashtable *table) {
  ht_init(table, (unsigned int (*)(void*)) &str_hash, &string_cmp, sizeof(char*), sizeof(enum maTokenE), 2*ma_tkn_num_keywords);
  for (int i=0; i<ma_tkn_num_keywords; ++i) {
    char* key = malloc(sizeof(char)*(strlen(ma_tkn_keywords[i].str) + 1));
    strcpy(key, ma_tkn_keywords[i].str);
    ht_insert(table, &key, (void*) &ma_tkn_keywords[i].tkn);
  }
}

/* deletes keyword table by freeing strings which are the keys and then calling
 * hashtable delete.
 */
void keyword_table_del(struct hashtable* table) {
  for (int i=0; i<table->size; ++i) {
    free(table->keys + i*table->key_sz);
  }
  ht_del(table);
}


void add_tkn(char* buffer, size_t b_sz, struct DynArray *tkns, struct hashtable *keyword_table) {
  struct maToken t;
  enum maTokenE  *keyword_tkn;
  buffer[b_sz] = '\0';
  bool result = ht_get_ref(keyword_table, (void**) &buffer, (void**) &keyword_tkn);

  debug_print("add_tkn: %s,%i\n", buffer, result);

  if (result) {
    t.tag = *keyword_tkn;
  } else if (is_num(buffer, b_sz)) {
    t.tag = MA_TKN_NAT;
    t.val.nat = strtoul(buffer, NULL, 10);
  } else {
    t.tag = MA_TKN_VAR;
    t.val.contents = malloc(sizeof(char)*(b_sz+1));
    strcpy(t.val.contents, buffer);
  }
  da_append(tkns, &t);
}

void ma_lex(char* inp, struct DynArray* tkns, struct hashtable *keyword_table) {
  char buffer[1024];
  int buffer_ix = 0;
  int i = 0;
  struct maToken t;
  while (inp[i]) {
    bool append = true;
    if (buffer_ix > 0 && (isspace(inp[i]) || !is_variable_char(inp[i]))) {
      add_tkn(buffer, buffer_ix, tkns, keyword_table);
      buffer_ix = 0;
    }
    switch (inp[i]) {
      case '{':
        t.tag = MA_TKN_LBRACKET;
        break;
      case '}':
        t.tag = MA_TKN_RBRACKET;
        break;
      case '(':
        t.tag = MA_TKN_LPAREN;
        break;
      case ')':
        t.tag = MA_TKN_RPAREN;
        break;
      case '\\':
        t.tag = MA_TKN_LAMBDA;
        break;
      case '|':
        t.tag = MA_TKN_VBAR;
        break;
      case '.':
        t.tag = MA_TKN_DOT;
        break;
      case ':':
        if (inp[i+1] == '=') {
          t.tag = MA_TKN_ASSIGN;
          ++i;
        } else {
          t.tag = MA_TKN_COLON;
        }
        break;
      case ';':
        t.tag = MA_TKN_SEMICOLON;
        break;
      case '-':
        if (inp[i+1] == '>') {
          t.tag = MA_TKN_RIGHTARROW;
          ++i;
        } else {
          t.tag = MA_TKN_DASH;
        }
        break;
      case '<':
        if (inp[i+1] == '-') {
          t.tag = MA_TKN_LEFTARROW;
          ++i;
          break;
        }
      case '+':
        t.tag = MA_TKN_PLUS;
        break;
      case '*':
        t.tag = MA_TKN_ASTERISK;
        break;
      case '/':
        t.tag = MA_TKN_FWD_SLASH;
        break;
      case '%':
        t.tag = MA_TKN_PERCENT;
        break;
      case '^':
        t.tag = MA_TKN_CARROT;
        break;
      default:
        if (!isspace(inp[i])) {
          buffer[buffer_ix] = inp[i];
          ++buffer_ix;
        }
        append = false;
    }
    if (append) {
      da_append(tkns, &t);
    }
    append = true;
    ++i;
  }
  if (buffer_ix > 0) {
    add_tkn(buffer, buffer_ix, tkns, keyword_table);
  }
  debug_print("%zu, %zu\n", strlen(inp), tkns->size);
}

void ma_print_token(struct maToken t) {
  switch (t.tag) {
    case MA_TKN_NAT_TYPE:
      printf("nat");
      break;
    case MA_TKN_CMD:
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
    case MA_TKN_COLON:
      printf(":");
      break;
    case MA_TKN_SEMICOLON:
      printf(";");
      break;
    case MA_TKN_RIGHTARROW:
      printf("->");
      break;
    case MA_TKN_LEFTARROW:
      printf("<-");
      break;
    case MA_TKN_ASSIGN:
      printf(":=");
      break;
    case MA_TKN_NAT:
      printf("%u", t.val.nat);
      break;
    case MA_TKN_PLUS:
      printf("+");
      break;
    case MA_TKN_DASH:
      printf("-");
      break;
    case MA_TKN_ASTERISK:
      printf("*");
      break;
    case MA_TKN_PERCENT:
      printf("%%");
      break;
    case MA_TKN_FWD_SLASH:
      printf("/");
      break;
    case MA_TKN_CARROT:
      printf("^");
      break;
    default:
      assert(is_tag_keyword(t.tag));
      printf("%s", keyword_string(t.tag));
  }
}

void ma_print_tokens(struct DynArray* tkns) {
  struct maToken *t;
  for (int i=0; i<tkns->size; ++i) {
    da_get_ref(tkns, i, (void**) &t);
    ma_print_token(*t);
    printf(",");
  }
  printf("\n");
}
