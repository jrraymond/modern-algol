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

#include "types.h"
#include "malgol.tab.h"

void code_gen(struct maExp *e);


#endif
