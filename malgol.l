%{
  #include <stdlib.h>
  #include <inttypes.h>
  #include <string.h>
  #include <stdio.h>

/* To interface with Bison:
 *    Bison expects to call a routing named yylex() to find the next input token.
 *    yylex() returns the type of the next token and puts associated value in
 *    the global yylval. call 'bison -d f.y' to generate a file 'f.tab.h'
 *    containing definitions of all the %tokens appearing in the bison input.
 */
  #include "malgol.tab.h"

  void yyerror(char *);
  char *__strdup(const char *s);
/* flex generates yylex()
 *    yylex reads characters from yyin(default=stdin)
 *    outputs to yyout(default=stdout)
 *  yywrap() is called at end of file(can open another file and continue parsing)
 *    if it opens another file, return 0
 *    to end parsing return 1
 *  each call to yylex returns an integer value representing a token type
 *  each token may optionally have a value which is placed in the variable yylval
 */
%}


%%

[0-9]+  {
          yylval.num = atoi(yytext);
          return MA_TKN_NUM;
        }

"num"                   { return MA_TKN_NUM_TYP; }    /*types*/
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
"is"                    { return MA_TKN_IS; }
"dcl"                   { return MA_TKN_DCL; }
"@"                     { return MA_TKN_AT; }
"if"                    { return MA_TKN_IF; }    /* booleans */
"then"                  { return MA_TKN_THEN; }
"else"                  { return MA_TKN_ELSE; }
"true"                  { return MA_TKN_TRUE; }
"false"                 { return MA_TKN_FALSE; }
"S"                     { return MA_TKN_SUCC; }   /* numbers */
"Z"                     { return MA_TKN_ZERO; }
"-"                     { return MA_TKN_DASH; }
"+"                     { return MA_TKN_PLUS; }
"*"                     { return MA_TKN_ASTERISK; }
"/"                     { return MA_TKN_FWD_SLASH; }
"%"                     { return MA_TKN_PERCENT; }
">"                     { return MA_TKN_GT; }
">="                     { return MA_TKN_GTE; }
"<"                     { return MA_TKN_LT; }
"<="                     { return MA_TKN_LTE; }
"=="                     { return MA_TKN_ET; }
"!="                     { return MA_TKN_NE; }
"&&"                     { return MA_TKN_AND; }
"||"                     { return MA_TKN_OR; }
[[:alpha:]]+([[:alnum:]]|_)* {
    yylval.string = __strdup(yytext);
    return MA_TKN_VAR;
}
"^"                     { return MA_TKN_CARROT; }
";;"                      { return MA_TKN_EOI; }
<<EOF>>   { return MA_TKN_EOF; }

[ \t\n]    ; /* skip whitespace */
.         printf("invalid character: %s\n", yytext);

%%

/*YYSTYPE yylval;*/

int yywrap(void)
{
  return 1;
}

char *__strdup(const char *s)
{
  if (!s)
    return NULL;
  char *t = malloc(strlen(s) + 1);
  if (t)
    strcpy(t, s);
  return t;
}

#if LMAIN
int main(void)
{
  int token;
  while ((token = yylex()) != 0) {
    printf("Token: %d (%s)\n", token, yytext);
  }
  return EXIT_SUCCESS;
}
#endif
