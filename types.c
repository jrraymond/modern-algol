#include "types.h"

/* ********** IMPLEMENTATION ********** */
void ma_exp_enum_print(enum ma_exp e)
{
  switch (e) {
    case MA_EXP_TYP:
      printf("typ");
      break;
    case MA_EXP_VAR:
      printf("var");
      break;
    case MA_EXP_ZERO:
      printf("Z");
      break;
    case MA_EXP_SUCC:
      printf("S");
      break;
    case MA_EXP_NUM:
      printf("num");
      break;
    case MA_EXP_FIX:
      printf("fix");
      break;
    case MA_EXP_ABS:
      printf("abs");
      break;
    case MA_EXP_APP:
      printf("app");
      break;
    case MA_EXP_CMD:
      printf("cmd");
      break;
    case MA_EXP_TUPLE:
      printf("tuple");
      break;
    case MA_EXP_PRIM_OP:
      printf("primop");
      break;
  };
}

void ma_typ_init(struct maTyp *t) {}
void ma_typ_mv(struct maTyp *to, struct maTyp *from) {}
void ma_typ_cp(struct maTyp *to, struct maTyp *from) {}
void ma_typ_del(struct maTyp *t) {}

void ma_po_init(struct maPrimOp *p) {}
void ma_po_mv(struct maPrimOp *to, struct maPrimOp *from) {}
void ma_po_cp(struct maPrimOp *to, struct maPrimOp *from) {}
void ma_po_del(struct maPrimOp *p) {}


void ma_app_init(struct maApp *a) {}
void ma_app_mv(struct maApp *to, struct maApp *from) {}
void ma_app_cp(struct maApp *to, struct maApp *from) {}
void ma_app_del(struct maApp *a) {}

void ma_fix_init(struct maApp *a) {}
void ma_fix_mv(struct maApp *to, struct maApp *from) {}
void ma_fix_cp(struct maApp *to, struct maApp *from) {}
void ma_fix_del(struct maApp *a) {}


void ma_abs_init(struct maFix *a) {}
void ma_abs_mv(struct maFix *to, struct maFix *from) {}
void ma_abs_cp(struct maFix *to, struct maFix *from) {}
void ma_abs_del(struct maFix *a) {}

void ma_tuple_init(struct maTuple *a) {}
void ma_tuple_mv(struct maTuple *to, struct maTuple *from) {}
void ma_tuple_cp(struct maTuple *to, struct maTuple *from) {}
void ma_tuple_del(struct maTuple *a) {}


void ma_exp_init(struct maExp *a) { }
void ma_exp_mv(struct maExp *to, struct maExp *from)
{
  *to = *from;
}
void ma_exp_cp(struct maExp *to, struct maExp *from) {}
void ma_exp_del(struct maExp *a){}


void ma_bind_init(struct maBind *a) {}
void ma_bind_mv(struct maBind *to, struct maBind *from) {}
void ma_bind_cp(struct maBind *to, struct maBind *from) {}
void ma_bind_del(struct maBind *a) {}


void ma_dcl_init(struct maDcl *a) {}
void ma_dcl_mv(struct maDcl *to, struct maDcl *from) {}
void ma_dcl_cp(struct maDcl *to, struct maDcl *from) {}
void ma_dcl_del(struct maDcl *a) {}


void ma_assign_init(struct maAssign *a) {}
void ma_assign_mv(struct maAssign *to, struct maAssign *from) {}
void ma_assign_cp(struct maAssign *to, struct maAssign *from) {}
void ma_assign_del(struct maAssign *a) {}

void ma_cmd_init(struct maCmd *a) {}
void ma_cmd_mv(struct maCmd *to, struct maCmd *from) {}
void ma_cmd_cp(struct maCmd *to, struct maCmd *from) {}
void ma_cmd_del(struct maCmd *a) {}
