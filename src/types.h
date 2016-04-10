#ifndef __MODERN_ALGOL_TYPES_H
#define __MODERN_ALGOL_TYPES_H

enum MA_Type {
  MA_NAT_T,
  MA_ARROW_T,
  MA_CMD_T
};

enum MA_Expression {
  MA_VAR,
  MA_ZERO,
  MA_SUCC,
  MA_REC,
  MA_ABS,
  MA_APP,
  MA_CMD,
};

enum MA_Command {
  MA_RET,
  MA_BIND,
  MA_DCL,
  MA_FETCH,
  MA_ASSIGN,
};

struct ma_exp; //forward declare so we can have mutually recursive structs
struct ma_cmd;

//not using typedefs because it pollutes the global namespace
// and linus thinks its a terrible idea
//
// The other choice was to declare these structs outside the unions

//application
struct ma_app {
  struct ma_exp* fun;
  struct ma_exp* arg;
};

//rec construct
struct ma_rec {
  struct ma_exp* e;
  struct ma_exp* zcase;
  unsigned int x;
  unsigned int y;
  struct ma_exp* scase;
};

//abstraction
struct ma_abs {
  unsigned int var;
  enum MA_Type type;
};

// for recursive structs, we need to use pointers, otherwise the
// compiler would not be able to tell how big the structs are. So since the
// types for expressions or commands are mutually recursive, at they cannot
// contain each other, so at least one must contain a pointer to the other.
// The question is where do the pointers go. Should we have a struct always be
// a pointer to another struct, or should it only be one way. If so, which
// struct should contain the pointer?

struct ma_exp {
  enum MA_Expression tag;
  union {
    unsigned int var; //debruijn indexes
    struct ma_exp* e0; //successor, need a better name for this
    struct ma_rec rec; //three children rec
    struct ma_abs abs; //abstraction
    struct ma_app app; //application
    struct ma_cmd* cmd; //command
  };
};

struct ma_bind {
  unsigned int var;
  struct ma_exp exp;
  struct ma_cmd* cmd;
};

struct ma_dcl {
  unsigned int ass; 
  struct ma_exp exp;
  struct ma_cmd* cmd;
};

struct ma_assign {
  unsigned int ass;
  struct ma_exp exp;
};

struct ma_cmd {
  enum MA_Command tag;
  union {
    struct ma_exp ret; //return
    struct ma_bind bnd; //sequence
    struct ma_dcl dcl; //new assignable
    unsigned int at; //fetch
    struct ma_assign assign; //assign
  };
};
#endif
