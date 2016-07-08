#include "parser.h"

void ma_parse(
    struct DynArray *tkns,
    struct hashtable *keyword_table,
    struct maExp *top_level
    )
{
  int idx = 0;
  struct DynArray stack;
  da_DynArray_init(&stack, 0, sizeof(struct maExp));
  while (idx < tkns->size) {
    struct maToken *t;
    da_get_ref(tkns, idx, (void**) &t);
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
/* ACTION & GOTO TABLE FOR JUST ARITHMETIC
 * State  ACTION  GOTO
 *    | +  | -  | *  |  /  |  %  |  (  |  )  |  id | $  | E'  | E  | T  | F
 *  0 |    |    |    |     |     |  s4 |     |  s5 |    |     |  1 |  2 |  3
 *  1 | s6 | s7 |    |     |     |     |     |     | acc|     |    |    |
 *  2 | r3 | r3 | s8 |  s9 | s10 |     |  r3 |     | r3 |     |    |    |
 *  3 | r7 | r7 | r7 |  r7 | r7  |     | r7  |     | r7 |     |    |    |
 *  4 |    |    |    |     |     |  s4 |     |  s5 |    |     | 11 |  2 |  3
 *  5 | r9 | r9 | r9 |  r9 |  r9 |     | r9  |     | r9 |     |    |    |
 *  6 |    |    |    |     |     |  s4 |     |  s5 |    |     |    | 12 |  3
 *  7 |    |    |    |     |     |  s4 |     |  s5 |    |     |    | 13 |  3
 *  8 |    |    |    |     |     |  s4 |     |  s5 |    |     |    |    | 14
 *  9 |    |    |    |     |     |  s4 |     |  s5 |    |     |    |    | 15
 * 10 |    |    |    |     |     |  s4 |     |  s5 |    |     |    |    | 16
 * 11 | s6 | s7 |    |     |     |     |     |     |    |     |    |    | s17            
 * 12 | r1 | r1 | s8 |  s9 | s10 |     |  r1 |     | r1 |     |    |    |
 * 13 | r2 | r2 | s8 |  s9 | s10 |     |  r2 |     | r2 |     |    |    |
 * 14 | r4 | r4 | r4 |  r4 |  r4 |  r4    r4         
 * 15 | r5 | r5 | r5 |  r5 |  r5 |  r5    r5         
 * 16 | r6 | r6 | r6 | r6  r6    r6    r6         
 * 17 | r8 | r8 | r8 | r8  r8    r8    r8         
 * /

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
