#ifndef __MODERN_ALGOL_TYPES_H
#define __MODERN_ALGOL_TYPES_H

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "array.h"

enum ma_exp {
  MA_EXP_TYP,
  MA_EXP_VAR,
  MA_EXP_ZERO,
  MA_EXP_SUCC,
  MA_EXP_NUM,
  MA_EXP_FIX,
  MA_EXP_ABS,
  MA_EXP_APP,
  MA_EXP_CMD,
  MA_EXP_TUPLE,
  MA_EXP_PRIM_OP,
};

void ma_exp_enum_print(enum ma_exp e);

enum ma_cmd {
  MA_CMD_RET,
  MA_CMD_BIND,
  MA_CMD_DCL,
  MA_CMD_FETCH,
  MA_CMD_ASSIGN,
};

/* variables may be numbers (debuijn) or \0 terminated strings */
union maVar {
  int db;
  char* name;
};

struct maExp; //forward declare so we can have mutually recursive structs
struct maTyp;

/* Types are nums, cmd, or arrow */
enum ma_typ {
  MA_TYP_NUM,
  MA_TYP_ARROW,
  MA_TYP_PROD,
  MA_TYP_CMD
};

/* only MA_TYP_ARROW has recursive typ */
struct maTyp {
  enum ma_typ tag;
  struct maTyp *a;
  struct maTyp *b;
};

void ma_typ_init(struct maTyp *t);
void ma_typ_mv(struct maTyp *to, struct maTyp *from);
void ma_typ_cp(struct maTyp *to, struct maTyp *from);
void ma_typ_del(struct maTyp *t);

/* primitive operations on numbers */
enum ma_prim_op {
  MA_PO_ADD,
  MA_PO_SUB,
  MA_PO_MUL,
  MA_PO_DIV,
  MA_PO_REM,
  MA_PO_POW,
  MA_PO_GT,
  MA_PO_GTE,
  MA_PO_LT,
  MA_PO_LTE,
  MA_PO_ET,
  MA_PO_NE,
  MA_PO_AND,
  MA_PO_OR
};

struct maPrimOp {
  enum ma_prim_op tag;
  struct maExp *arg;
};

bool ma_primop_has_arg(enum ma_prim_op);

void ma_po_init(struct maPrimOp *p);
void ma_po_mv(struct maPrimOp *to, struct maPrimOp *from);
void ma_po_cp(struct maPrimOp *to, struct maPrimOp *from);
void ma_po_del(struct maPrimOp *p);



//not using typedefs because it pollutes the global namespace
// and linus thinks its a terrible idea
//
// the other choice was to declare these structs outside the unions

//application
struct maApp {
  struct maExp* fun;
  struct maExp* arg;
};


void ma_app_init(struct maApp *a);
void ma_app_mv(struct maApp *to, struct maApp *from);
void ma_app_cp(struct maApp *to, struct maApp *from);
void ma_app_del(struct maApp *a);

//rec construct
struct maFix {
  union maVar var;
  struct maExp* body;
  struct maTyp typ;
};

void ma_fix_init(struct maFix *a);
void ma_fix_mv(struct maFix *to, struct maFix *from);
void ma_fix_cp(struct maFix *to, struct maFix *from);
void ma_fix_del(struct maFix *a);

//abstraction
struct maAbs {
  union maVar var;
  struct maTyp typ;
  struct maExp *body;
};

void ma_abs_init(struct maAbs *a);
void ma_abs_mv(struct maAbs *to, struct maAbs *from);
void ma_abs_cp(struct maAbs *to, struct maAbs *from);
void ma_abs_del(struct maAbs *a);

//tuples
struct maTuple {
  struct maExp *fst;
  struct maExp *snd;
};

void ma_tuple_init(struct maTuple *a);
void ma_tuple_mv(struct maTuple *to, struct maTuple *from);
void ma_tuple_cp(struct maTuple *to, struct maTuple *from);
void ma_tuple_del(struct maTuple *a);


struct maBind {
  union maVar var;
  struct maExp *exp;
  struct maCmd *cmd;
};

void ma_bind_init(struct maBind *a);
void ma_bind_mv(struct maBind *to, struct maBind *from);
void ma_bind_cp(struct maBind *to, struct maBind *from);
void ma_bind_del(struct maBind *a);

struct maDcl {
  union maVar var;
  struct maExp *exp;
  struct maCmd *cmd;
};

void ma_dcl_init(struct maDcl *a);
void ma_dcl_mv(struct maDcl *to, struct maDcl *from);
void ma_dcl_cp(struct maDcl *to, struct maDcl *from);
void ma_dcl_del(struct maDcl *a);


struct maAssign {
  union maVar var;
  struct maExp *exp;
};

void ma_assign_init(struct maAssign *a);
void ma_assign_mv(struct maAssign *to, struct maAssign *from);
void ma_assign_cp(struct maAssign *to, struct maAssign *from);
void ma_assign_del(struct maAssign *a);

struct maCmd {
  enum ma_cmd tag;
  union val {
    struct maExp *ret; //return
    struct maBind bnd; //sequence
    struct maDcl dcl; //new assignable
    union maVar at; //fetch
    struct maAssign assign; //assign
  } val;
};

void ma_cmd_init(struct maCmd *a);
void ma_cmd_mv(struct maCmd *to, struct maCmd *from);
void ma_cmd_cp(struct maCmd *to, struct maCmd *from);
void ma_cmd_del(struct maCmd *a);


// for recursive structs, we need to use pointers, otherwise the
// compiler would not be able to tell how big the structs are. so since the
// types for expressions or commands are mutually recursive, at they cannot
// contain each other, so at least one must contain a pointer to the other.
// the question is where do the pointers go. should we have a struct always be
// a pointer to another struct, or should it only be one way. if so, which
// struct should contain the pointer?

struct maExp {
  enum ma_exp tag;
  union {
    int num;
    union maVar var;
    struct maExp* succ; //successor, need a better name for this
    struct maFix fix; //three children rec
    struct maAbs abs; //abstraction
    struct maApp app; //application
    struct maCmd cmd; //command
    struct maTyp typ;  //type
    struct maTuple tuple; //tuple
    struct maPrimOp op; //primitive operations
  } val;
};

void ma_exp_init(struct maExp *a);
void ma_exp_mv(struct maExp *to, struct maExp *from);
void ma_exp_cp(struct maExp *to, struct maExp *from);
void ma_exp_del(struct maExp *a);

struct maDef {
  char *name;
  struct maTyp typ;
  struct maExp val;
};

void ma_def_del(struct maDef *d);

CUTILS_ARRAY(def, static inline, struct maDef)

#endif
