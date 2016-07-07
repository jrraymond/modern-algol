#include "parser.h"

void ma_parse(
    struct DynArray *tkns,
    struct hashtable *symbol_table,
    struct maExp *top_level
    )
{
  int idx = 0;
  struct DynArray stack;
  da_DynArray_init(&stack, 0, sizeof(maExp));
  while (idx < tkns->size) {
    maToken* t;
    da_get_ref(tkns, idx, &t);
    switch (t->tag) {
      case MA_TKN_NAT:
        da_append(&stack, t);
        break;
      case MA_TKN_VAR:
        da_append(&stack, t);
        break;
        /*
      MA_TKN_NAT_TYPE,
      MA_TKN_ARROW_TYPE,
      MA_TKN_CMD_TYPE,
      MA_TKN_LBRACKET,
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
      MA_TKN_SYMBOL,
      */
    }
  }
  da_DynArray_del(&stack);
}

/*  SHIFT REDUCE TABLE
 *    + , - , / , % , * , ^ , NAT , VAR , { , } , ( , ) , \ , | , . 
 *
 *
 *
 *
 *
 *
 *
 *    ; , -> , <- , := , fix , is , cmd , ret , bnd , dcl , in , @
 *  
 *
 *
 *
 *
 *
 */
