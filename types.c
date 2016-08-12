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
void ma_typ_del(struct maTyp *t)
{
  switch (t->tag) {
    case MA_TYP_PROD:
    case MA_TYP_ARROW:
      ma_typ_del(t->a);
      free(t->a);
      ma_typ_del(t->b);
      free(t->b);
    default:
      break;
  }
}

bool ma_primop_has_arg(enum ma_prim_op t)
{
  return true;
}

void ma_po_init(struct maPrimOp *p) {}
void ma_po_mv(struct maPrimOp *to, struct maPrimOp *from) {}
void ma_po_cp(struct maPrimOp *to, struct maPrimOp *from) {}
void ma_po_del(struct maPrimOp *p)
{
  ma_exp_del(p->arg);
  free(p->arg);
}


void ma_app_init(struct maApp *a) {}
void ma_app_mv(struct maApp *to, struct maApp *from) {}
void ma_app_cp(struct maApp *to, struct maApp *from) {}
void ma_app_del(struct maApp *a)
{
  ma_exp_del(a->fun);
  free(a->fun);
  ma_exp_del(a->arg);
  free(a->arg);
}


void ma_fix_init(struct maFix *a) {}
void ma_fix_mv(struct maFix *to, struct maFix *from) {}
void ma_fix_cp(struct maFix *to, struct maFix *from) {}
void ma_fix_del(struct maFix *a)
{
  ma_exp_del(a->body);
  free(a->body);
  ma_typ_del(&a->typ);
  free(a->var.name);
}


void ma_abs_init(struct maAbs *a) {}
void ma_abs_mv(struct maAbs *to, struct maAbs *from) {}
void ma_abs_cp(struct maAbs *to, struct maAbs *from) {}
void ma_abs_del(struct maAbs *a)
{
  ma_typ_del(&a->typ);
  ma_exp_del(a->body);
  free(a->body);
  free(a->var.name);
}

void ma_tuple_init(struct maTuple *a) {}
void ma_tuple_mv(struct maTuple *to, struct maTuple *from) {}
void ma_tuple_cp(struct maTuple *to, struct maTuple *from) {}
void ma_tuple_del(struct maTuple *a)
{
  ma_exp_del(a->fst);
  free(a->fst);
  ma_exp_del(a->snd);
  free(a->snd);
}


void ma_exp_init(struct maExp *a) { }
void ma_exp_mv(struct maExp *to, struct maExp *from)
{
  *to = *from;
}
void ma_exp_cp(struct maExp *to, struct maExp *from) {}
void ma_exp_del(struct maExp *a)
{
  switch (a->tag) {
    case MA_EXP_TYP:
      ma_typ_del(&a->val.typ);
      break;
    case MA_EXP_SUCC:
      ma_exp_del(a->val.succ);
      free(a->val.succ);
      break;
    case MA_EXP_FIX:
      ma_fix_del(&a->val.fix);
      break;
    case MA_EXP_ABS:
      ma_abs_del(&a->val.abs);
      break;
    case MA_EXP_APP:
      ma_app_del(&a->val.app);
      break;
    case MA_EXP_CMD:
      ma_cmd_del(&a->val.cmd);
      break;
    case MA_EXP_TUPLE:
      ma_tuple_del(&a->val.tuple);
      break;
    case MA_EXP_PRIM_OP:
      ma_po_del(&a->val.op);
      break;
    case MA_EXP_VAR:
      free(a->val.var.name);
    default:
      break;
  }
}


void ma_bind_init(struct maBind *a) {}
void ma_bind_mv(struct maBind *to, struct maBind *from) {}
void ma_bind_cp(struct maBind *to, struct maBind *from) {}
void ma_bind_del(struct maBind *a)
{
  ma_exp_del(a->exp);
  free(a->exp);
  ma_cmd_del(a->cmd);
  free(a->cmd);
  free(a->var.name);
}


void ma_dcl_init(struct maDcl *a) {}
void ma_dcl_mv(struct maDcl *to, struct maDcl *from) {}
void ma_dcl_cp(struct maDcl *to, struct maDcl *from) {}
void ma_dcl_del(struct maDcl *a)
{
  ma_exp_del(a->exp);
  free(a->exp);
  ma_cmd_del(a->cmd);
  free(a->cmd);
}


void ma_assign_init(struct maAssign *a) {}
void ma_assign_mv(struct maAssign *to, struct maAssign *from) {}
void ma_assign_cp(struct maAssign *to, struct maAssign *from) {}
void ma_assign_del(struct maAssign *a)
{
  ma_exp_del(a->exp);
  free(a->exp);
}


void ma_cmd_init(struct maCmd *a) {}
void ma_cmd_mv(struct maCmd *to, struct maCmd *from) {}
void ma_cmd_cp(struct maCmd *to, struct maCmd *from) {}
void ma_cmd_del(struct maCmd *a)
{
  switch (a->tag) {
    case MA_CMD_RET:
      ma_exp_del(a->val.ret);
      free(a->val.ret);
    default:
      break;
  }
}
