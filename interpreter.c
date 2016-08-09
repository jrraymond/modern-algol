#include <stdlib.h>
#include <stdio.h>

#include "codegen.h"

extern int YY_BUFFER_STATE;
int yylex(void);
YY_BUFFER_STATE yy_scan_string(const char *);

CUTILS_ARRAY(char, static inline, char)

bool read_until(struct Array_char *buffer, char delim)
{
  while (true) {
    char c = getc(stdin);
    if (c == EOF)
      return false;
    if (c == delim)
      return true;
    array_char_append(buffer, c);
  }
}

void driver(void)
{
  struct Array_char buffer;
  array_char_init(&buffer, 256);
  struct Array_lvr vals;
  array_lvr_init(&vals, 64);

  /* set flex to read from buffer instead of stdin */

  LLVMModuleRef mod = LLVMModuleCreateWithName("jit");

  mk_pow(mod, &vals);

  LLVMBuilderRef builder = LLVMCreateBuilder(); /*in context???*/

  while (read_until(&buffer, ';')) {
    array_char_append(&buffer, '\0');
    yy_scan_string(buffer.elems);
    yyparse();

    array_char_clear(&buffer);
  }

  //LLVMValueRef v = cgen_exp(builder, e, &vals);

  /* cleanup */
  LLVMDisposeBuilder(builder);
  array_lvr_del(&vals);
  array_char_del(&buffer);
}


int main(int argc, char **argv)
{
  driver();
  return EXIT_SUCCESS;
}