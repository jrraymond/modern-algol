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
  int yylex(void);
  void yyerror(char const *);

  uint64_t pow_u64(uint64_t b, uint64_t e);
%}

/* DECLARATIONS
 *
 */
%define api.value.type {uint64_t}
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

exp:
  MA_TKN_NAT                          { $$ = $1;           }
| exp MA_TKN_PLUS exp                 { $$ = $1 + $3;      }
| exp MA_TKN_DASH exp                 { $$ = $1 - $3;      }
| exp MA_TKN_ASTERISK exp             { $$ = $1 * $3;      }
| exp MA_TKN_FWD_SLASH exp            { $$ = $1 / $3;      }
| MA_TKN_DASH exp  %prec MA_TKN_DASH  { $$ = -$2;          }
| exp MA_TKN_CARROT exp               { $$ = pow_u64($1, $3); }
| MA_TKN_LPAREN exp MA_TKN_RPAREN     { $$ = $2;           }
;

%%

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
