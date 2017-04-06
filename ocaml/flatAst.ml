open Typ;;



type exp =
  | Unit
  | Var of var * typ
  | Int of int
  | Fix of string * typ * exp * typ
  | App of exp * exp * typ
  | Cmd of cmd * typ
  | Case of exp * (pattern * exp) list * typ
  | Call of int
  | Op of prim * exp list * typ
and cmd =
  | Ret of exp * typ
  | Bnd of string * exp * cmd * typ
  | BndT of string * exp * typ
  | Dcl of string * exp * cmd * typ
  | DclT of string * exp * typ
  | Get of string * typ
  | Set of string * exp * typ;;


type def =
  { var : string
  ; arg : typ
  ; env : (string * typ) list
  ; body : exp
  ; t : typ
  };;
