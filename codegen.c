#include "codegen.h"


LLVMValueRef cgen_exp(LLVMBuilderRef b, struct maExp *e);
void code_gen(char *name, struct maExp *e)
{
  LLVMModuleRef mod = LLVMModuleCreateWithName(name);

}
LLVMValueRef cgen_tuple(LLVMBuilderRef b, struct maTuple *t)
{
}

LLVMValueRef cgen_prim_op(LLVMBuilderRef b, struct maPrimOp *op)
{
  //gen instructions for args
  LLVMValueRef a = cgen_exp(b, op->arg);
  switch (op->tag) {
    case MA_PO_ADD:
      break;
  }
}

LLVMValueRef cgen_exp(LLVMBuilderRef b, struct maExp *e)
{
  switch (e->tag) {
    case MA_EXP_PRIM_OP:
      return cgen_prim_op(b, &e->val.op);
    default:
      printf("UNIMPLIMENTED\n");
      exit(1);
  }
}
