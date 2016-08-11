#include <stdlib.h>
#include <stdio.h>

#include "codegen.h"
#include "malgol.tab.h"

CUTILS_ARRAY(char, static inline, char)

extern struct maExp* ast_res;
#if YYDEBUG
extern int yydebug;
#endif

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
#if YYDEBUG
  yydebug=1;
#endif
  struct maExp *exp;
  struct Array_char buffer;
  array_char_init(&buffer, 256);
  struct Array_lvr vals;
  array_lvr_init(&vals, 64);

  LLVMModuleRef mod = LLVMModuleCreateWithName("jit");

  mk_pow(mod, &vals);

  LLVMBuilderRef builder = LLVMCreateBuilder(); /*in context???*/

  char *error = NULL;
  LLVMVerifyModule(mod, LLVMAbortProcessAction, &error);
  LLVMDisposeMessage(error);

  LLVMExecutionEngineRef eng;
  error = NULL;

#if JIT
  LLVMLinkInMCJIT();
#else
  LLVMLinkInInterpreter();
#endif

  LLVMInitializeNativeTarget();
  if (LLVMCreateExecutionEngineForModule(&eng, mod, &error) != 0) {
    printf("Failed to create execution engine");
    abort();
  }
  if (error) {
    printf("ERROR: %s\n", error);
    LLVMDisposeMessage(error);
    exit(EXIT_FAILURE);
  }

  while (true) {
    printf(">>>");
    switch (yyparse()) {
      case 1:
        printf("ERROR: invalid input\n");
        continue;
      case 2:
        printf("ERROR: memory exhaustion\n");
        continue;
    }


    LLVMValueRef v = cgen_exp(builder, ast_res, &vals);
  }

  /* cleanup */
  LLVMDisposeBuilder(builder);
  LLVMDisposeExecutionEngine(eng);
  array_lvr_del(&vals);
  array_char_del(&buffer);
}


int main(int argc, char **argv)
{
  driver();
  return EXIT_SUCCESS;
}
