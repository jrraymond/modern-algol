%{
  #include <stdlib.h>
  #include <stdint.h>

  #include "malgol.tab.h"

  void yyerror(char *);
%}

%%

[0-9]+  {
          yylval = atoi(yytext);
          return MA_TKN_NAT;
        }

"nat"                   { return MA_TKN_NAT_TYPE; }    /*types*/
"{"                     { return MA_TKN_LBRACKET; }    /*not stringy tokens*/
"}"                     { return MA_TKN_RBRACKET; }
"("                     { return MA_TKN_LPAREN; }
")"                     { return MA_TKN_RPAREN; }
"\\"                    { return MA_TKN_LAMBDA; }
"|"                     { return MA_TKN_VBAR; }
"."                     { return MA_TKN_DOT; }
":"                     { return MA_TKN_COLON; }
";"                     { return MA_TKN_SEMICOLON; }
"->"                    { return MA_TKN_RIGHTARROW; }
"<-"                    { return MA_TKN_LEFTARROW; }
":="                    { return MA_TKN_ASSIGN; }
"fix"                   { return MA_TKN_FIX; }         /*stringy tokens*/
"cmd"                   { return MA_TKN_CMD; }
"ret"                   { return MA_TKN_RET; }
"bnd"                   { return MA_TKN_BND; }
"in"                    { return MA_TKN_IN; }
"is"                    { return MA_TKN_IS; }
"dcl"                   { return MA_TKN_DCL; }
"@"                     { return MA_TKN_AT; }
"S"                     { return MA_TKN_SUCC; }
"Z"                     { return MA_TKN_ZERO; }
"-"                     { return MA_TKN_DASH; }
"+"                     { return MA_TKN_PLUS; }
"*"                     { return MA_TKN_ASTERISK; }
"/"                     { return MA_TKN_FWD_SLASH; }
"%"                     { return MA_TKN_PERCENT; }
[[:alpha:]]+([[:alnum:]]|_)*  { return MA_TKN_VAR; }         /*variables*/
"^"                     { return MA_TKN_CARROT; }
\n                      { return *yytext; }

[ \t]    ; /* skip whitespace */
.         printf("invalid character: %s\n", yytext);

%%

YYSTYPE yylval;

int yywrap(void)
{
  return 1;
}

#if MAIN
int main(void)
{
  int token;
  while ((token = yylex()) != 0) {
    printf("Token: %d (%s)\n", token, yytext);
  }
  return EXIT_SUCCESS;
}
#endif
