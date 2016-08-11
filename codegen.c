#include "codegen.h"


static char POW_F64_NAME[] = "llvm.pow.f64";

LLVMValueRef lvr_get(struct Array_lvr *vals, char *name)
{
  const char *v_name;
  LLVMValueRef v;
  for (Array_lvr_Itr i = array_lvr_begin(vals);
      i != array_lvr_end(vals);
      array_lvr_next(vals, &i)) {
    v = array_lvr_get(vals, i);
    v_name = LLVMGetValueName(v);
    if (strcmp(v_name, name) == 0)
      return v;
  }
  printf("function '%s' does not exist\n", name);
  exit(1);
}

void main_driver(char *name, struct maExp *e)
{
  struct Array_lvr vals;
  array_lvr_init(&vals, 64);

  LLVMModuleRef mod = LLVMModuleCreateWithName(name);

  mk_pow(mod, &vals);

  LLVMBuilderRef builder = LLVMCreateBuilder(); /*in context???*/

  LLVMValueRef v = cgen_exp(builder, e, &vals);

  /* cleanup */
  LLVMDisposeBuilder(builder);
  array_lvr_del(&vals);
}

void mk_pow(LLVMModuleRef m, struct Array_lvr *vals)
{
  LLVMTypeRef param_types[] = { LLVMDoubleType(), LLVMDoubleType() };
  LLVMTypeRef fn_type = LLVMFunctionType(LLVMDoubleType(), param_types, 2, false);
  LLVMValueRef fn = LLVMAddFunction(m, POW_F64_NAME, fn_type);
  array_lvr_append(vals, fn);
}


LLVMValueRef cgen_prim_op(LLVMBuilderRef b, struct maPrimOp *op, struct Array_lvr *vals)
{
  //assume all primops are binary ops on a tuple
  LLVMValueRef args[2];
  args[0] = cgen_exp(b, op->arg->val.tuple.fst, vals);
  args[1] = cgen_exp(b, op->arg->val.tuple.snd, vals);

  switch (op->tag) {
    case MA_PO_ADD:
      return LLVMBuildAdd(b, args[0], args[1], "add");
    case MA_PO_SUB:
      return LLVMBuildSub(b, args[0], args[1], "sub");
    case MA_PO_MUL:
      return LLVMBuildMul(b, args[0], args[1], "mul");
    case MA_PO_DIV:
      return LLVMBuildSDiv(b, args[0], args[1], "div");
    case MA_PO_REM:
      return LLVMBuildSRem(b, args[0], args[1], "rem");
    case MA_PO_POW:;
      args[0] = LLVMBuildSIToFP(b, args[0], LLVMInt32Type(), "si2fp");
      args[1] = LLVMBuildSIToFP(b, args[1], LLVMInt32Type(), "si2fp");
      LLVMValueRef pow = lvr_get(vals, POW_F64_NAME);
      return LLVMBuildCall(b, pow, args, 2, "pow");
  }
  return NULL;
}

LLVMValueRef cgen_num(LLVMBuilderRef b, unsigned int num)
{
  return LLVMConstInt(LLVMInt32Type(), num, false);
}

LLVMValueRef cgen_exp(LLVMBuilderRef b, struct maExp *e, struct Array_lvr *vals)
{
  switch (e->tag) {
    case MA_EXP_PRIM_OP:
      return cgen_prim_op(b, &e->val.op, vals);
    case MA_EXP_NUM:
      return cgen_num(b, e->val.num);
    default:
      printf("UNIMPLIMENTED\n");
      exit(1);
  }
}
