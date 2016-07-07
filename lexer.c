#include "lexer.h"

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

void keyword_table_init(struct hashtable *table) {
  ht_init(table, (unsigned int (*)(void*)) &str_hash, &string_cmp, sizeof(char*), sizeof(unsigned int), 2*ma_tkn_num_keywords);
  unsigned int uid = 0;
  for (int i=0; i<ma_tkn_num_keywords; ++i) {
    char* key = malloc(sizeof(char)*(strlen(ma_tkn_keywords[i]) + 1));
    strcpy(key, ma_tkn_keywords[i]);
    ht_insert(table, &key, &uid);
    ++uid;
  }
}

void keyword_table_del(struct hashtable* table) {
  for (int i=0; i<table->size; ++i) {
    free(table->keys + i*table->key_sz);
  }
  ht_del(table);
}

void add_tkn(char* buffer, size_t b_sz, struct DynArray *tkns, struct hashtable *keyword_table) {
  struct maToken t;
  unsigned int *keyword_id;
  buffer[b_sz] = '\0';
  bool result = ht_get_ref(keyword_table, (void**) &buffer, (void**) &keyword_id);

  debug_print("add_tkn: %s,%i\n", buffer, result);

  if (result) {
    t.tag = MA_TKN_SYMBOL;
    t.val.keyword_id = *keyword_id;
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
    if (buffer_ix > 0 && (isspace(inp[i]) || !is_variable_char(inp[i]))) {
      add_tkn(buffer, buffer_ix, tkns, keyword_table);
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
      case ':':
        if (inp[i+1] == '=') {
          t.tag = MA_TKN_ASSIGN;
          ++i;
        } else {
          t.tag = MA_TKN_COLON;
        }
        da_append(tkns, &t);
        break;
      case ';':
        t.tag = MA_TKN_SEMICOLON;
        da_append(tkns, &t);
        break;
      case '-':
        if (inp[i+1] == '>') {
          t.tag = MA_TKN_RIGHTARROW;
          da_append(tkns, &t);
          ++i;
          break;
        }
        goto default_label;
      case '<':
        if (inp[i+1] == '-') {
          t.tag = MA_TKN_LEFTARROW;
          da_append(tkns, &t);
          ++i;
          break;
        }
        goto default_label;
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
    add_tkn(buffer, buffer_ix, tkns, keyword_table);
  }
  debug_print("%zu, %zu\n", strlen(inp), tkns->size);
}

void ma_print_token(struct maToken t) {
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
    case MA_TKN_SYMBOL:
      printf("SYMBOL#%u", t.val.keyword_id);
      break;
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
