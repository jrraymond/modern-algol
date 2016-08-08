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
| exp '\n'  { printf ("\t%" PRIu64 "\n", $1); }
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
    $$ = (struct maExp) {.tag = MA_EXP_NAT, .val = $1};
  }
| exp MA_TKN_PLUS exp 
  {
    struct maTuple a;
    a.fst = malloc(sizeof(maExp))
    *a.fst = $1;
    a.snf = malloc(sizeof(maExp))
    *a.snd = $3;
    struct maExp arg = {.tag = MA_EXP_TUPLE, .val.tuple = a};
    struct maPrimOp e = {.tag = MA_PO_ADD, .arg = arg};
    $$ = (struct maExp) {.tag = MA_EXP_PRIM_OP, .val.op = e};
  }
| exp MA_TKN_DASH exp 
  {
    struct maTuple a;
    a.fst = malloc(sizeof(maExp))
    *a.fst = $1;
    a.snf = malloc(sizeof(maExp))
    *a.snd = $3;
    struct maExp arg = {.tag = MA_EXP_TUPLE, .val.tuple = a};
    struct maPrimOp e = {.tag = MA_PO_SUB, .arg = arg};
    $$ = (struct maExp) {.tag = MA_EXP_PRIM_OP, .val.op = e};
  }
| exp MA_TKN_ASTERISK exp
  {
    struct maTuple a;
    a.fst = malloc(sizeof(maExp))
    *a.fst = $1;
    a.snf = malloc(sizeof(maExp))
    *a.snd = $3;
    struct maExp arg = {.tag = MA_EXP_TUPLE, .val.tuple = a};
    struct maPrimOp e = {.tag = MA_PO_MUL, .arg = arg};
    $$ = (struct maExp) {.tag = MA_EXP_PRIM_OP, .val.op = e};
  }
| exp MA_TKN_FWD_SLASH exp
  {
    struct maTuple a;
    a.fst = malloc(sizeof(maExp))
    *a.fst = $1;
    a.snf = malloc(sizeof(maExp))
    *a.snd = $3;
    struct maExp arg = {.tag = MA_EXP_TUPLE, .val.tuple = a};
    struct maPrimOp e = {.tag = MA_PO_DIV, .arg = arg};
    $$ = (struct maExp) {.tag = MA_EXP_PRIM_OP, .val.op = e};
  }
| exp MA_TKN_CARROT exp 
  {
    struct maTuple a;
    a.fst = malloc(sizeof(maExp))
    *a.fst = $1;
    a.snf = malloc(sizeof(maExp))
    *a.snd = $3;
    struct maExp arg = {.tag = MA_EXP_TUPLE, .val.tuple = a};
    struct maPrimOp e = {.tag = MA_PO_POW, .arg = arg};
    $$ = (struct maExp) {.tag = MA_EXP_PRIM_OP, .val.op = e};
  }
| MA_TKN_LPAREN exp MA_TKN_RPAREN 
  {
    $$ = $2;
  }
;

%%

struct maExp mk_prim_op(enum ma_prim_op op, struct maExp *a, struct maExp *b)
{
    struct maTuple t;
    t.fst = malloc(sizeof(maExp))
    *t.fst = $1;
    t.snf = malloc(sizeof(maExp))
    *t.snd = $3;
    struct maExp arg = {.tag = MA_EXP_TUPLE, .val.tuple = t};
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
