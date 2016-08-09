#ifndef __MODERN_ALGOL_CODEGEN_H
#define __MODERN_ALGOL_CODEGEN_H

#include <llvm-c/Core.h>
#include <llvm-c/ExecutionEngine.h>
#include <llvm-c/Target.h>
#include <llvm-c/Analysis.h>
#include <llvm-c/BitWriter.h>


#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#include "types.h"
#include "malgol.tab.h"

#include "cutils/array.h"

CUTILS_ARRAY(lvr, static inline, LLVMValueRef)

void code_gen(char *name, struct maExp *e);

void mk_pow(LLVMModuleRef m, struct Array_lvr *functions);

LLVMValueRef cgen_exp(LLVMBuilderRef b, struct maExp *e, struct Array_lvr *vals);

LLVMValueRef cgen_tuple(LLVMBuilderRef b, struct maTuple *t);

LLVMValueRef cgen_prim_op(LLVMBuilderRef b, struct maPrimOp *op, struct Array_lvr *vals);

LLVMValueRef cgen_num(LLVMBuilderRef b, unsigned int num);

LLVMValueRef lvr_get(struct Array_lvr *vals, char *name) ;
#endif
