/* PROLOGUE
 * Contains macro definitions and declarations of functions and variable that
 * are used in the actions in the grammar rules.
 */
%{
  #include <stdlib.h>
  #include <stdio.h>
  #include <stdint.h>
  #include <inttypes.h>
  #include <stdbool.h>
  
  #include "types.h"

  int yylex(void);
  void yyerror(char const *);

  struct maExp *mk_prim_op(enum ma_prim_op op, struct maExp *a, struct maExp *b);

  struct maExp *ast_res;

%}

/* DECLARATIONS
 *
 */
%define parse.error verbose

%union {
  int64_t num;
  char *string;
  struct maExp *exp;
  struct maTyp *typ;
  struct maCmd *cmd;
}

%token <exp> MA_TKN_NUM_TYP    /*types*/
%token <exp> MA_TKN_ARROW_TYP
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
%token <exp> MA_TKN_IS
%token <exp> MA_TKN_DCL
%token <exp> MA_TKN_AT
%token <exp> MA_TKN_IF    /* booleans */
%token <exp> MA_TKN_THEN
%token <exp> MA_TKN_ELSE
%token <exp> MA_TKN_TRUE
%token <exp> MA_TKN_FALSE
%token <exp> MA_TKN_AND
%token <exp> MA_TKN_OR
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
%token <exp> MA_TKN_GT
%token <exp> MA_TKN_GTE
%token <exp> MA_TKN_LT
%token <exp> MA_TKN_LTE
%token <exp> MA_TKN_ET
%token <exp> MA_TKN_NE
%token <exp> MA_TKN_EOI /*for interpreter, to signal end of inp*/

%left MA_TKN_PLUS MA_TKN_DASH 
%left MA_TKN_ASTERISK MA_TKN_PERCENT MA_TKN_FWD_SLASH
%right MA_TKN_CARROT

%type <exp> exp;
%type <cmd> cmd;
%type <typ> typ;

%%


/* GRAMMAR
 *
 * actions: C code inside braces. executed each time instance of that rule is
 * recognized. most actions compute a semantic value for the group built from
 * the semantic values associated with tokens or smaller groupings.
 */

input: exp MA_TKN_EOI {
     ast_res = $1;
     return 0;
}


typ:
  MA_TKN_NUM_TYP
  {
    struct maTyp *t = malloc(sizeof(struct maTyp));
    t->tag = MA_TYP_NUM;
    $$ = t;
  }
| typ MA_TKN_RIGHTARROW typ
  { 
    struct maTyp *t = malloc(sizeof(struct maTyp));
    t->tag = MA_TYP_ARROW;
    t->a = $1;
    t->b = $3;
    $$ = t;
  }
| MA_TKN_CMD
  { 
    struct maTyp *t = malloc(sizeof(struct maTyp));
    t->tag = MA_TYP_CMD;
    $$ = t;
  }
| typ MA_TKN_ASTERISK typ
  { 
    struct maTyp *t = malloc(sizeof(struct maTyp));
    t->tag = MA_TYP_PROD;
    t->a = $1;
    t->b = $3;
    $$ = t;
  }
| MA_TKN_LPAREN typ MA_TKN_RPAREN
  {
    $$ = $2;
  }

cmd:
  MA_TKN_RET exp
  {
    struct maCmd *c = malloc(sizeof(struct maCmd));
    c->tag = MA_CMD_RET;
    c->val.ret = $2;
    $$ = c;
  }
| MA_TKN_BND MA_TKN_VAR MA_TKN_LEFTARROW exp MA_TKN_COLON cmd
  {
    struct maCmd *c = malloc(sizeof(struct maCmd));
    c->tag = MA_CMD_BIND;
    c->val.bnd = (struct maBind) {.var.name = $2, .exp = $4, .cmd = $6};
    $$ = c;
  }
| MA_TKN_DCL MA_TKN_VAR MA_TKN_ASSIGN exp MA_TKN_DOT cmd
  {
    struct maCmd *c = malloc(sizeof(struct maCmd));
    c->tag = MA_CMD_DCL;
    c->val.dcl = (struct maDcl) {.var.name = $2, .exp = $4, .cmd = $6};
    $$ = c;
  }
| MA_TKN_AT MA_TKN_VAR
  {
    struct maCmd *c = malloc(sizeof(struct maCmd));
    c->tag = MA_CMD_FETCH;
    c->val.at.name = $2;
    $$ = c;
  }
| MA_TKN_VAR MA_TKN_ASSIGN exp
  {
    struct maCmd *c = malloc(sizeof(struct maCmd));
    c->tag = MA_CMD_ASSIGN;
    c->val.assign = (struct maAssign) {.var.name = $1, .exp = $3};
    $$ = c;
  }


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
| exp MA_TKN_GT exp
  {
    $$ = mk_prim_op(MA_PO_GT, $1, $3);
  }
| exp MA_TKN_GTE exp
  {
    $$ = mk_prim_op(MA_PO_GTE, $1, $3);
  }
| exp MA_TKN_LT exp
  {
    $$ = mk_prim_op(MA_PO_LT, $1, $3);
  }
| exp MA_TKN_LTE exp
  {
    $$ = mk_prim_op(MA_PO_LTE, $1, $3);
  }
| exp MA_TKN_ET exp
  {
    $$ = mk_prim_op(MA_PO_ET, $1, $3);
  }
| exp MA_TKN_NE exp
  {
    $$ = mk_prim_op(MA_PO_NE, $1, $3);
  }
| MA_TKN_LPAREN exp MA_TKN_RPAREN 
  {
    $$ = $2;
  }
| MA_TKN_VAR
  {
    struct maExp *e = malloc(sizeof(struct maExp));
    e->tag = MA_EXP_VAR;
    e->val.var.name = $1;
    $$ = e;
  }
| MA_TKN_ZERO
  {
    struct maExp *e = malloc(sizeof(struct maExp));
    e->tag = MA_EXP_ZERO;
    $$ = e;
  }
| MA_TKN_SUCC exp
  {
    struct maExp *e = malloc(sizeof(struct maExp));
    e->tag = MA_EXP_SUCC;
    e->val.succ = $2;
    $$ = e;
  }
| MA_TKN_LAMBDA MA_TKN_VAR MA_TKN_COLON typ MA_TKN_DOT exp
  {
    struct maExp *e = malloc(sizeof(struct maExp));
    e->tag = MA_EXP_ABS;
    e->val.abs = (struct maAbs) {.var.name = $2, .typ = *$4, .body = $6};
    free($4);
    $$ = e;
  }
| MA_TKN_FIX MA_TKN_VAR MA_TKN_COLON typ MA_TKN_DOT exp
  {
    struct maExp *e = malloc(sizeof(struct maExp));
    e->tag = MA_EXP_FIX;
    e->val.fix = (struct maFix) {.var.name = $2, .typ = *$4,  .body = $6};
    free($4);
    $$ = e;
  }
| exp exp
  {
    struct maExp *e = malloc(sizeof(struct maExp));
    e->tag = MA_EXP_APP;
    e->val.app = (struct maApp) {.fun = $1, .arg = $2};
    $$ = e;
  }
| MA_TKN_CMD cmd
  {
    struct maExp *e = malloc(sizeof(struct maExp));
    e->tag = MA_EXP_CMD;
    e->val.cmd = *$2;
    free($2);
    $$ = e;
  }
| MA_TKN_IF exp MA_TKN_THEN exp MA_TKN_ELSE exp
  {
    struct maExp *e = malloc(sizeof(struct maExp));
    $$ = e;
  }
| exp MA_TKN_AND exp
  {
    $$ = mk_prim_op(MA_PO_AND, $1, $3);
  }
| exp MA_TKN_OR exp
  {
    $$ = mk_prim_op(MA_PO_OR, $1, $3);
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
  #if YYDEBUG
    yydebug=1;
  #endif
  while (true) {
    yyparse();
    if (ast_res) {
      ma_exp_enum_print(ast_res->tag);
      ma_exp_del(ast_res);
      free(ast_res);
    }
  }
  return EXIT_SUCCESS;
}
#endif
