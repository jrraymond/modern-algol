open Typ;;



type exp =
  | Var of var * typ
  | Int of int
  | Fix of string * typ * exp * typ
  | App of exp * exp * typ
  | Cmd of cmd * typ
  | Case of exp * (pattern * exp) list * typ
  | Fun of int
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
  ; argt : typ
  ; env : (string * typ) list
  ; body : exp
  ; typ : typ
  };;


let rec string_of_exp e =
  match e with
  | Var (x, _) -> x.label
  | Int i -> string_of_int i
  | Fix (x, tx, e', t) ->
      let txs = string_of_typ tx in
      let es = string_of_exp e' in
      let ts = string_of_typ t in
      Printf.sprintf "(fix %s : %s is %s) : %s" x txs es ts
  | Fun i -> "$" ^ string_of_int i
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
  | Op _ -> raise (Failure "todo");
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

