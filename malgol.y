/* PROLOGUE
 * Contains macro definitions and declarations of functions and variable that
 * are used in the actions in the grammar rules.
 */
%{
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdint.h>
  #include <inttypes.h>
  
  #include "types.h"


  int yylex(void);
  void yyerror(char const *);

  struct maExp *mk_prim_op(enum ma_prim_op op, struct maExp *a, struct maExp *b);

  struct maExp *ast_res;
  void parse(char *buffer, struct maExp **e);

%}

/* DECLARATIONS
 *
 */

%union {
  int64_t num;
  char *string;
  struct maExp *exp;
  struct maTyp *typ;
  struct maCmd *cmd;
}

%token <exp> MA_TKN_NUM_TYPE    /*types*/
%token <exp> MA_TKN_ARROW_TYPE
%token <string> MA_TKN_VAR         /*variables*/
/*%token MA_TKN_VAR         /*variables*/
%token <exp> MA_TKN_LBRACKET    /*not stringy tokens*/
%token <exp> MA_TKN_RBRACKET
%token <exp> MA_TKN_LPAREN
%token <exp> MA_TKN_RPAREN
%token <exp> MA_TKN_LAMBDA
%token <exp> MA_TKN_VBAR
%token <exp> MA_TKN_DOT
%token <exp> MA_TKN_COLON
%token <exp> MA_TKN_SEMICOLON
%token <exp> MA_TKN_RIGHTARROW
%token <exp> MA_TKN_LEFTARROW
%token <exp> MA_TKN_ASSIGN
%token <exp> MA_TKN_FIX         /*stringy tokens*/
%token <exp> MA_TKN_CMD
%token <exp> MA_TKN_RET
%token <exp> MA_TKN_BND
%token <exp> MA_TKN_IN
%token <exp> MA_TKN_IS
%token <exp> MA_TKN_DCL
%token <exp> MA_TKN_AT
%token <exp> MA_TKN_SUCC
%token <exp> MA_TKN_ZERO
%token <num> MA_TKN_NUM /*  numbers and their ops */
/*%token MA_TKN_NUM /* numbers and their ops */
%token <exp> MA_TKN_PLUS
%token <exp> MA_TKN_DASH
%token <exp> MA_TKN_ASTERISK
%token <exp> MA_TKN_PERCENT
%token <exp> MA_TKN_FWD_SLASH
%token <exp> MA_TKN_CARROT
%token <exp> MA_TKN_EOI /*for interpreter, to signal end of inp*/

%left MA_TKN_PLUS MA_TKN_DASH 
%left MA_TKN_ASTERISK MA_TKN_PERCENT MA_TKN_FWD_SLASH
%right MA_TKN_CARROT

%type <exp> exp input;
%type <cmd> cmd;
%type <typ> typ;

%%


/* GRAMMAR
 *
 * actions: C code inside braces. executed each time instance of that rule is
 * recognized. most actions compute a semantic value for the group built from
 * the semantic values associated with tokens or smaller groupings.
 */

start: input {
     ast_res = $1;
}

input:
  %empty { $$ = NULL; }
| input exp MA_TKN_EOI { 
     #if PMAIN
        ma_exp_enum_print($2->tag);
     #endif
    $$ = $2;
  }

/*
typ:
  MA_TKN_NUM_TYPE
  {
    struct maTyp t = {.t = MA_TYPE_NUM};
    struct maExp e = {.tag = MA_EXP_TYP, .val = t};
    $$ = e;
  }
| typ MA_TKN_RIGHTARROW typ
  { 
    struct maTyp t = {.t = MA_TYPE_ARROW, .a = &$1, .b = &$3}; todo malloc
    struct maExp e = {.tag = MA_EXP_TYP, .val = t};
    $$ = e;
  }
| MA_TKN_CMD
  { 
    struct maTyp t = {.t = MA_TYPE_CMD};
    struct maExp e = {.tag = MA_EXP_TYP, .val = t};
    $$ = e;
  }
*/

/* abstract prim ops to functions */
exp:
  MA_TKN_NUM                          
  { 
    struct maExp *e = malloc(sizeof(struct maExp));
    e->tag = MA_EXP_NUM;
    e->val.num = $1;
    $$ = e;
  }
| exp MA_TKN_PLUS exp 
  {
    $$ = mk_prim_op(MA_PO_ADD, $1, $3);
  }
| exp MA_TKN_DASH exp 
  {
    $$ = mk_prim_op(MA_PO_SUB, $1, $3);
  }
| exp MA_TKN_ASTERISK exp
  {
    $$ = mk_prim_op(MA_PO_MUL, $1, $3);
  }
| exp MA_TKN_FWD_SLASH exp
  {
    $$ = mk_prim_op(MA_PO_DIV, $1, $3);
  }
| exp MA_TKN_PERCENT exp
  {
    $$ = mk_prim_op(MA_PO_REM, $1, $3);
  }
| exp MA_TKN_CARROT exp 
  {
    $$ = mk_prim_op(MA_PO_POW, $1, $3);
  }
| MA_TKN_LPAREN exp MA_TKN_RPAREN 
  {
    $$ = $2;
  }
;

%%

/* creates expression node by moving subexpressions out of arguments */
struct maExp *mk_prim_op(enum ma_prim_op op, struct maExp *a, struct maExp *b)
{
    struct maTuple t = {.fst = a, .snd = b};

    struct maExp *arg = malloc(sizeof(struct maExp));
    arg->tag = MA_EXP_TUPLE;
    arg->val.tuple = t;

    struct maPrimOp o = {.tag = op, .arg = arg};

    struct maExp *e = malloc(sizeof(struct maExp));
    e->tag = MA_EXP_PRIM_OP;
    e->val.op = o;

    return e;
}


void yyerror(char const *s)
{
  fprintf(stderr, "%s\n", s);
}

#if PMAIN
int main(void)
{
  yyparse();
  return EXIT_SUCCESS;
}
#endif
