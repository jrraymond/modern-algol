#include "codegen.h"

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

void code_gen(char *name, struct maExp *e)
{
  struct Array_lvr vals;
  array_lvr_init(&vals, 64);

  LLVMModuleRef mod = LLVMModuleCreateWithName(name);

  mk_pow(mod, &vals);

  array_lvr_del(&vals);
}

void mk_pow(LLVMModuleRef m, struct Array_lvr *vals)
{
  LLVMTypeRef param_types[] = { LLVMDoubleType() };
  LLVMTypeRef fn_type = LLVMFunctionType(LLVMDoubleType(), param_types, 2, false);
  LLVMValueRef fn = LLVMAddFunction(m, "llvm.pow.f64", fn_type);
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
      //TODO cast from integer to fp
      LLVMValueRef pow = lvr_get(vals, "llvm.pow.f64");
      return LLVMBuildCall(b, pow, args, 2, "pow");
  }
}

LLVMValueRef cgen_exp(LLVMBuilderRef b, struct maExp *e, struct Array_lvr *vals)
{
  switch (e->tag) {
    case MA_EXP_PRIM_OP:
      return cgen_prim_op(b, &e->val.op, vals);
    default:
      printf("UNIMPLIMENTED\n");
      exit(1);
  }
}
