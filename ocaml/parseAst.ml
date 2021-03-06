open Typ;;



type exp =
  | Var of string
  | Int of int
  | Fix of string * typ * exp
  | Abs of string * typ * exp
  | App of exp * exp
  | Cmd of cmd
  | Case of exp * (pattern * exp) list
  | UnOp of unop * exp
  | BinOp of binop * exp * exp
and cmd =
  | Ret of exp
  | Bnd of string * exp * cmd
  | BndT of string * exp
  | Dcl of string * exp * cmd
  | DclT of string * exp
  | Get of string
  | Set of string * exp;;


let rec string_of_exp e =
  match e with
  | Var x -> x
  | Int i -> string_of_int i
  | Fix (x, t, e') ->
      "fix " ^ x ^ " : " ^ string_of_typ t ^ " is " ^ string_of_exp e'
  | Abs (x, t, e') ->
      "(\\" ^ x ^ " : " ^ string_of_typ t ^ " . " ^ string_of_exp e' ^ ")"
  | App (e0, e1) ->
      string_of_exp e0 ^ "(" ^ string_of_exp e1 ^ ")"
  | Cmd m -> "cmd " ^ string_of_cmd m
  | Case (e, cases) ->
      let cs = List.map (fun (p, e) ->
        Printf.sprintf "\n| %s -> %s" (string_of_pattern p) (string_of_exp e))
        cases
      in "case " ^ string_of_exp e ^ " of " ^ Utils.intercalate "" cs
  | UnOp (p, e) ->
      let ps = string_of_unop p in
      let es = string_of_exp e in
      Printf.sprintf "%s %s" ps es
  | BinOp (p, e0, e1) ->
      let ps = string_of_binop p in
      let e0s = string_of_exp e0 in
      let e1s = string_of_exp e1 in
      Printf.sprintf "%s %s %s" e0s ps e1s
and string_of_cmd c =
  match c with
  | Ret e -> "ret " ^ string_of_exp e
  | Bnd (x, e, m) ->
      "bnd " ^ x ^ " <- " ^ string_of_exp e ^ "; " ^ string_of_cmd m
  | BndT (x, e) ->
      "bnd " ^ x ^ " <- " ^ string_of_exp e
  | Dcl (x, e, m) ->
      "dcl " ^ x ^ " := " ^ string_of_exp e ^ " in " ^ string_of_cmd m
  | DclT (x, e) ->
      "dcl " ^ x ^ " := " ^ string_of_exp e
  | Get a -> "@" ^ a
  | Set (a, e) -> a ^ " := " ^ string_of_exp e;;
