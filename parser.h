#ifndef __MODERN_ALGOL_PARSER_H
#define __MODERN_ALGOL_PARSER_H

void ma_parse(struct DynArray *tkns, struct hashtable *symbol_table, struct maExp *top_level);

#endif
