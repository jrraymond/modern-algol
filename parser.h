#ifndef __MODERN_ALGOL_PARSER_H
#define __MODERN_ALGOL_PARSER_H

#include "cutils/dynamic_array.h"
#include "cutils/hashtable.h"
#include "types.h"
#include "lexer.h"

void ma_parse(struct DynArray *tkns, struct hashtable *keyword_table, struct maExp *top_level);

#endif
