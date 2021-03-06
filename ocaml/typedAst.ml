open Typ;;

type exp = 
  | Var of var * typ
  | Int of int
  | Fix of string * typ * exp * typ
  | Abs of string * typ * exp * typ
  | App of exp * exp * typ
  | Cmd of cmd * typ
  | Case of exp * (pattern * exp) list * typ
  | UnOp of unop * exp * typ
  | BinOp of binop * exp * exp * typ
and cmd =
  | Ret of exp * typ
  | Bnd of string * exp * cmd * typ
  | BndT of string * exp * typ
  | Dcl of string * exp * cmd * typ
  | DclT of string * exp * typ
  | Get of string * typ
  | Set of string * exp * typ;;


let rec free_vars_exp i e =
  match e with
  | Var (v, t) when v.index > i -> [(v.label, t)]
  | Var _ -> []
  | Int _ -> []
  | Fix (x, _, e0, _) ->
      free_vars_exp (i + 1) e0
  | Abs (x, _, e0, _) ->
      free_vars_exp (i + 1) e0
  | App (e0, e1, _) ->
      free_vars_exp i e0 @ free_vars_exp i e1
  | Cmd (m, t) ->
      free_vars_cmd i m
  | Case (e, cs, _) ->
      let evs = free_vars_exp i e in
      evs @ List.fold_left (fun vs (p, e0) ->
        vs @ match p with
        | Lit _ -> free_vars_exp i e0
        | Binder x -> free_vars_exp (i + 1) e0) [] cs
  | UnOp (_, e0, _) -> free_vars_exp i e0
  | BinOp (_, e0, e1, _) -> free_vars_exp i e0 @ free_vars_exp i e1
and free_vars_cmd i m =
  match m with
  | Ret (e, _) -> free_vars_exp i e
  | _ -> raise (Failure "uniplemented");;


let typ_of_exp (e : exp) : typ =
  match e with
  | Var (_, t) -> t
  | Int _ -> IntTyp
  | Fix (_, _, _, t) -> t
  | Abs (_, _, _, t) -> t
  | App (_, _, t) -> t
  | Case (_, _, t) -> t
  | Cmd (_, t) -> t
  | UnOp (_, _, t) -> t
  | BinOp (_, _, _, t) -> t;;


let typ_of_cmd m =
  match m with 
  | Ret (_, t) -> t
  | Bnd (_, _, _, t) -> t
  | BndT (_, _, t) -> t
  | Dcl (_, _, _, t) -> t
  | DclT (_, _, t) -> t
  | Get (_, t) -> t
  | Set (_, _, t) -> t;;


let rec string_of_exp e =
  match e with
  | Var (x, _) -> x.label
  | Int i -> string_of_int i
  | Fix (x, tx, e', t) ->
      let txs = string_of_typ tx in
      let es = string_of_exp e' in
      let ts = string_of_typ t in
      Printf.sprintf "(fix %s : %s is %s) : %s" x txs es ts
  | App (e0, (App _ as e1), t) ->
      let s0 = string_of_exp e0 in
      let s1 = string_of_exp e1 in
      let ts = string_of_typ t in
      Printf.sprintf "(%s (%s)) : %s" s0 s1 ts
  | App (e0, e1, t) ->
      let s0 = string_of_exp e0 in
      let s1 = string_of_exp e1 in
      let ts = string_of_typ t in
      Printf.sprintf "(%s %s) : %s" s0 s1 ts
  | Abs (x, tx, e0, t) ->
      let s0 = string_of_exp e0 in
      let txs = string_of_typ tx in
      let ts = string_of_typ t in
      Printf.sprintf "\\%s : %s . %s : %s" x txs s0 ts
  | Cmd (m, t) ->
      let ms = string_of_cmd m in
      let ts = string_of_typ t in
      Printf.sprintf "cmd %s : %s" ms ts
  | Case (e, cases, t) ->
      let cs = List.map (fun (p, e) ->
        Printf.sprintf "\n| %s -> %s" (string_of_pattern p) (string_of_exp e))
        cases
      in
      let es = string_of_exp e in
      let ts = string_of_typ t in
      Printf.sprintf "(case %s of %s) : %s" es (Utils.intercalate "" cs) ts
  | UnOp (p, e, t) ->
      let ps = string_of_unop p in
      let es = string_of_exp e in
      let ts = string_of_typ t in
      Printf.sprintf "(%s %s) : %s" ps es ts
  | BinOp (p, e0, e1, t) ->
      let ps = string_of_binop p in
      let e0s = string_of_exp e0 in
      let e1s = string_of_exp e1 in
      let ts = string_of_typ t in
      Printf.sprintf "(%s %s %s) : %s" e0s ps e1s ts
and string_of_cmd c =
  match c with
  | Ret (e, t) ->
      let es = string_of_exp e in
      let ts = string_of_typ t in
      Printf.sprintf "ret %s : %s" es ts
  | Bnd (x, e, m, t) ->
      let es = string_of_exp e in
      let ms = string_of_cmd m in
      let ts = string_of_typ t in
      Printf.sprintf "bnd %s <- %s; %s : %s" x es ms ts
  | BndT (x, e, t) ->
      let es = string_of_exp e in
      let ts = string_of_typ t in
      Printf.sprintf "bnd %s <- %s : %s" x es ts
  | Dcl (x, e, m, t) ->
      let es = string_of_exp e in
      let ms = string_of_cmd m in
      let ts = string_of_typ t in
      Printf.sprintf "dcl %s := %s in %s : %s" x es ms ts
  | DclT (x, e, t) ->
      let es = string_of_exp e in
      let ts = string_of_typ t in
      Printf.sprintf "dcl %s := %s : %s" x es ts
  | Get (a, t) -> "@" ^ a ^ " : " ^ string_of_typ t
  | Set (a, e, t) -> a ^ " := " ^ string_of_exp e ^ " : " ^ string_of_typ t;;

