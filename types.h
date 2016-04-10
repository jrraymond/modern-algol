#ifndef __MODERN_ALGOL_TYPES_H
#define __MODERN_ALGOL_TYPES_H

enum ma_type {
  MA_TYPE_NAT,
  MA_TYPE_ARROW,
  MA_TYPE_CMD
};

enum ma_exp {
  MA_EXP_VAR,
  MA_EXP_ZERO,
  MA_EXP_SUCC,
  MA_EXP_REC,
  MA_EXP_ABS,
  MA_EXP_APP,
  MA_EXP_CMD,
};

enum ma_cmd {
  MA_CMD_RET,
  MA_CMD_BIND,
  MA_CMD_DCL,
  MA_CMD_FETCH,
  MA_CMD_ASSIGN,
};

struct maExp; //forward declare so we can have mutually recursive structs
struct maCmd;

//not using typedefs because it pollutes the global namespace
// and linus thinks its a terrible idea
//
// the other choice was to declare these structs outside the unions

//application
struct maApp {
  struct maExp* fun;
  struct maExp* arg;
};

//rec construct
struct maRec {
  struct maExp* e;
  struct maExp* zcase;
  unsigned int x;
  unsigned int y;
  struct maExp* scase;
};

//abstraction
struct maAbs {
  unsigned int var;
  enum ma_type type;
};

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
    unsigned int var; //debruijn indexes
    struct maExp* e0; //successor, need a better name for this
    struct maRec rec; //three children rec
    struct maAbs abs; //abstraction
    struct maApp app; //application
    struct maCmd* cmd; //command
  } val;
};

struct maBind {
  unsigned int var;
  struct maExp exp;
  struct maCmd* cmd;
};

struct maDcl {
  unsigned int ass; 
  struct maExp exp;
  struct maCmd* cmd;
};

struct maAssign {
  unsigned int ass;
  struct maExp exp;
};

struct maCmd {
  enum ma_cmd tag;
  union val {
    struct maExp ret; //return
    struct maBind bnd; //sequence
    struct maDcl dcl; //new assignable
    unsigned int at; //fetch
    struct maAssign assign; //assign
  } val;
};
#endif
