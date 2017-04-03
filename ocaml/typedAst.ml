open Typ;;

type exp = 
  | Var of var * typ
  | Int of int
  | Fix of string * typ * exp * typ
  | Abs of string * typ * exp * typ
  | App of exp * exp * typ
  | Cmd of cmd * typ
  | Case of exp * (pattern * exp) list * typ
and cmd =
  | Ret of exp * typ
  | Bnd of string * exp * cmd * typ
  | BndT of string * exp * typ
  | Dcl of string * exp * cmd * typ
  | DclT of string * exp * typ
  | Get of string * typ
  | Set of string * exp * typ;;


let typ_of_exp (e : exp) : typ =
  match e with
  | Var (_, t) -> t
  | Int _ -> IntTyp
  | Fix (_, _, _, t) -> t
  | Abs (_, _, _, t) -> t
  | App (_, _, t) -> t
  | Case (_, _, t) -> t
  | Cmd (_, t) -> t;;


let typ_of_cmd m =
  match m with 
  | Ret (_, t) -> t
  | Bnd (_, _, _, t) -> t
  | BndT (_, _, t) -> t
  | Dcl (_, _, _, t) -> t
  | DclT (_, _, t) -> t
  | Get (_, t) -> t
  | Set (_, _, t) -> t;;
