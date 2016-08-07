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

"-"       { return MA_TKN_DASH; }
"+"       { return MA_TKN_PLUS; }
"*"       { return MA_TKN_ASTERISK; }
"/"       { return MA_TKN_FWD_SLASH; }
"%"       { return MA_TKN_PERCENT; }
"^"       { return MA_TKN_CARROT; }
"("       { return MA_TKN_LPAREN; }
")"       { return MA_TKN_RPAREN; }
[-+\n]    { return *yytext; }

[ \t]    ; /* skip whitespace */
.         printf("invalid character: %s\n", yytext);

%%

YYSTYPE yylval;

int yywrap(void)
{
  return 1;
}

#if DMAIN
int main(void)
{
  int token;
  while ((token = yylex()) != 0) {
    printf("Token: %d (%s)\n", token, yytext);
  }
  return EXIT_SUCCESS;
}
#endif
