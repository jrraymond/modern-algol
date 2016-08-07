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

[ \t]    ; /* skip whitespace */
.         printf("invalid character: %s\n", yytext);

%%

int yywrap(void)
{
  return 1;
}
