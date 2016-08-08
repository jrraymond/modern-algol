/* PROLOGUE
 * Contains macro definitions and declarations of functions and variable that
 * are used in the actions in the grammar rules.
 */
%{
  #include <math.h>
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdint.h>
  #include <inttypes.h>
  
  #include "types.h"

  int yylex(void);
  void yyerror(char const *);

  uint64_t pow_u64(uint64_t b, uint64_t e);

  struct maExp mk_prim_op(enum ma_prim_op op, struct maExp *a, struct maExp *b);

%}

/* DECLARATIONS
 *
 */
%define api.value.type { struct maExp }
%token MA_TKN_NAT_TYPE    /*types*/
%token MA_TKN_ARROW_TYPE
%token MA_TKN_VAR         /*variables*/
%token MA_TKN_LBRACKET    /*not stringy tokens*/
%token MA_TKN_RBRACKET
%token MA_TKN_LPAREN
%token MA_TKN_RPAREN
%token MA_TKN_LAMBDA
%token MA_TKN_VBAR
%token MA_TKN_DOT
%token MA_TKN_COLON
%token MA_TKN_SEMICOLON
%token MA_TKN_RIGHTARROW
%token MA_TKN_LEFTARROW
%token MA_TKN_ASSIGN
%token MA_TKN_FIX         /*stringy tokens*/
%token MA_TKN_CMD
%token MA_TKN_RET
%token MA_TKN_BND
%token MA_TKN_IN
%token MA_TKN_IS
%token MA_TKN_DCL
%token MA_TKN_AT
%token MA_TKN_SUCC
%token MA_TKN_ZERO
%token MA_TKN_NAT /* natural numbers and their ops */
%token MA_TKN_PLUS
%token MA_TKN_DASH
%token MA_TKN_ASTERISK
%token MA_TKN_PERCENT
%token MA_TKN_FWD_SLASH
%token MA_TKN_CARROT

%left MA_TKN_PLUS MA_TKN_DASH 
%left MA_TKN_ASTERISK MA_TKN_PERCENT MA_TKN_FWD_SLASH
%right MA_TKN_CARROT

%%


/* GRAMMAR
 *
 * actions: C code inside braces. executed each time instance of that rule is
 * recognized. most actions compute a semantic value for the group built from
 * the semantic values associated with tokens or smaller groupings.
 */
input:
  %empty
| input line
;

line:
  '\n'
| exp '\n'  { ma_exp_enum_print($1.tag); }
;

typ:
  MA_TKN_NAT_TYPE
  {
    struct maTyp t = {.t = MA_TYPE_NAT};
    struct maExp e = {.tag = MA_EXP_TYP, .val = t};
    $$ = e;
  }
| typ MA_TKN_RIGHTARROW typ
  { 
    struct maTyp t = {.t = MA_TYPE_ARROW, .a = &$1, .b = &$3}; /*(malloc???)*/
    struct maExp e = {.tag = MA_EXP_TYP, .val = t};
    $$ = e;
  }
| MA_TKN_CMD
  { 
    struct maTyp t = {.t = MA_TYPE_CMD};
    struct maExp e = {.tag = MA_EXP_TYP, .val = t};
    $$ = e;
  }

/* abstract prim ops to functions */
exp:
  MA_TKN_NAT                          
  { 
    $$ = (struct maExp) {.tag = MA_EXP_NAT, .val.nat = $1};
  }
| exp MA_TKN_PLUS exp 
  {
    $$ = mk_prim_op(MA_PO_ADD, &$1, &$3);
  }
| exp MA_TKN_DASH exp 
  {
    $$ = mk_prim_op(MA_PO_SUB, &$1, &$3);
  }
| exp MA_TKN_ASTERISK exp
  {
    $$ = mk_prim_op(MA_PO_MUL, &$1, &$3);
  }
| exp MA_TKN_FWD_SLASH exp
  {
    $$ = mk_prim_op(MA_PO_DIV, &$1, &$3);
  }
| exp MA_TKN_PERCENT exp
  {
    $$ = mk_prim_op(MA_PO_REM, &$1, &$3);
  }
| exp MA_TKN_CARROT exp 
  {
    $$ = mk_prim_op(MA_PO_POW, &$1, &$3);
  }
| MA_TKN_LPAREN exp MA_TKN_RPAREN 
  {
    $$ = $2;
  }
;

%%

/* creates expression node by moving subexpressions out of arguments */
struct maExp mk_prim_op(enum ma_prim_op op, struct maExp *a, struct maExp *b)
{
    struct maTuple t = {.fst = a, .snd = b};
    struct maExp *arg = malloc(sizeof(struct maExp));
    arg->tag = MA_EXP_TUPLE;
    arg->val.tuple = t;
    struct maPrimOp e = {.tag = op, .arg = arg};
    return (struct maExp) {.tag = MA_EXP_PRIM_OP, .val.op = e};
}

uint64_t pow_u64(uint64_t b, uint64_t e)
{
  return pow(b, e);
}

void yyerror(char const *s)
{
  fprintf(stderr, "%s\n", s);
}

int main(void)
{
  yyparse();
  return EXIT_SUCCESS;
}
