#include <stdlib.h>
#include <stdio.h>

#include "codegen.h"
#include "malgol.tab.h"

CUTILS_ARRAY(char, static inline, char)

extern struct maExp* ast_res;
#if YYDEBUG
extern int yydebug;
#endif

void driver(void)
{
#if YYDEBUG
  yydebug=1;
#endif
  bool dump_bitcode = true;
  struct maExp *exp;
  struct Array_char buffer;
  array_char_init(&buffer, 256);
  struct Array_lvr vals;
  array_lvr_init(&vals, 64);

  LLVMModuleRef mod = LLVMModuleCreateWithName("jit");

  mk_pow(mod, &vals);


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

  for (uint32_t line_no=0;;++line_no) {
    printf(">>>");
    switch (yyparse()) {
      case 1:
        printf("ERROR: invalid input\n");
        continue;
      case 2:
        printf("ERROR: memory exhaustion\n");
        continue;
    }
    char fun_name[64];
    sprintf(fun_name, "l%u", line_no);

    LLVMValueRef fun = LLVMAddFunction(mod, fun_name, LLVMFunctionType(LLVMInt32Type(), NULL, 0, 0));
    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(fun, "entry");
    LLVMBuilderRef builder = LLVMCreateBuilder();
    LLVMPositionBuilderAtEnd(builder, entry);

    LLVMValueRef v = cgen_exp(builder, ast_res, &vals);
    LLVMBuildRet(builder, v);

    LLVMGenericValueRef res = LLVMRunFunction(eng, fun, 0, NULL);
    printf("%d\n", (int)LLVMGenericValueToInt(res, 0));

    if (dump_bitcode && LLVMWriteBitcodeToFile(mod, "interpreter.bc") != 0)
        printf("ERROR: failed to write bitcode to file");

    LLVMDisposeBuilder(builder);
  }

  /* cleanup */
  LLVMDisposeExecutionEngine(eng);
  array_lvr_del(&vals);
  array_char_del(&buffer);
}


int main(int argc, char **argv)
{
  driver();
  return EXIT_SUCCESS;
}
