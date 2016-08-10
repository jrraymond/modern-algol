#include <stdlib.h>
#include <stdio.h>

#include "codegen.h"
#include "malgol.tab.h"

CUTILS_ARRAY(char, static inline, char)

extern void parse(char *, struct maExp **);

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
  if (!LLVMCreateExecutionEngineForModule(&eng, mod, &error)) {
    printf("Failed to create execution engine");
    abort();
  }
  if (error) {
    printf("ERROR: %s\n", error);
    LLVMDisposeMessage(error);
    exit(EXIT_FAILURE);
  }

  while (read_until(&buffer, '\n')) {
    array_char_append(&buffer, '\n');
    array_char_append(&buffer, '\0');

    parse(buffer.elems, &exp);

    LLVMValueRef v = cgen_exp(builder, exp, &vals);

    array_char_clear(&buffer);
  }

  //LLVMValueRef v = cgen_exp(builder, e, &vals);

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
