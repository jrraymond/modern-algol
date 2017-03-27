open Ast;;
open Utils;;


exception Stuck;;

type memory = (string, exp) Hashtbl.t;;

let eq_memory a b =
  Utils.subset_of a b && Utils.subset_of b a;;

let string_of_memory m =
  let xs = Hashtbl.fold (fun k v acc ->
    Printf.sprintf "%s:%s" k (string_of_exp v) :: acc)
    m []
  in Utils.intercalate "," xs;;

type context = exp list;;

let eq_context a b = a = b;;

let string_of_context c =
  List.mapi (fun i x -> Printf.sprintf "%i:%s" i (string_of_exp x)) c
  |> Utils.intercalate "," ;;


type state = { cmd : cmd; mem : memory; ctx : context };;


let eq_state a b =
  a.cmd = b.cmd && eq_memory a.mem b.mem && eq_context a.ctx b.ctx;;


let string_of_state state = 
  let cmd = string_of_cmd state.cmd in
  let mem = string_of_memory state.mem in
  let ctx = string_of_context state.ctx in
  ctx ^ " |- " ^ cmd ^ " || " ^ mem;;
      

let is_exp_val e = 
  match e with
  | Abs _ -> true
  | Int _ -> true
  | Cmd _ -> true
  | _ -> false;;

let is_final m =
  match m with
  | Ret e -> is_exp_val e
  | _ -> false;;

(* subst_exp e for x in d *)
let rec subst_exp (e : exp) (i : int) (d : exp) : exp =
  match d with
  | Var v when v.index = i -> e
  | App (e0, e1) -> App (subst_exp e i e0, subst_exp e i e1)
  | Abs (x, t, e0) -> Abs (x, t, subst_exp e (i + 1) e0)
  | Fix (x, t, e0) -> Fix (x, t, subst_exp e (i + 1) e0)
  | Cmd m -> Cmd (subst_cmd e i m)
  | _ -> d
and subst_cmd (e : exp) (i : int) (m : cmd) : cmd =
  match m with
  | Ret e0 -> Ret (subst_exp e i e0)
  | Bnd (x, t, m0) -> Bnd (x, t, subst_cmd e (i + 1) m0)
  | Dcl (a, t, m0) -> Dcl (a, t, subst_cmd e i m0)
  | Set (a, e0) -> Set (a, subst_exp e i e0)
  | _ -> m;;


let step_exp ctx = 
  let rec step e = 
    match e with
    | Var v -> List.nth ctx v.index
    | App (Abs (x, _, e0), e1) when is_exp_val e1 -> subst_exp e1 0 e0
    | App (Abs _ as e0, e1) -> App (e0, step e1)
    | App (e0, e1) -> App (step e0, e1)
    | Fix (x, _, e0) -> subst_exp e 0 e0
    | _ -> raise Stuck
  in step;;


let step_cmd mem ctx =
  let rec step m =
    match m with
    | Ret e -> Ret (step_exp ctx e)
    | Bnd (x, Cmd (Ret e), m) when is_exp_val e ->
        subst_cmd e 0 m
    | Bnd (x, Cmd m1, m2) ->
        let m1' = step m1 in
        Bnd (x, Cmd m1', m2)
    | Bnd (x, e, m) ->
        Bnd (x, step_exp ctx e, m)
    | BndT _ -> raise (Failure "top level")
    | DclT _ -> raise (Failure "top level")
    | Dcl (a, e, Ret e') when is_exp_val e && is_exp_val e' ->
        Ret e'
    | Dcl (a, e, m) when is_exp_val e ->
        let () = Hashtbl.add mem a e in
        let m' = step m in
        let e' = Hashtbl.find mem a in
        let () = Hashtbl.remove mem a in
        Dcl (a, e', m')
    | Dcl (a, e, m) ->
        Dcl (a, step_exp ctx e, m)
    | Get a -> Ret (Hashtbl.find mem a)
    | Set (a, e) when is_exp_val e ->
        let () = Hashtbl.replace mem a e in
        Ret e
    | Set (a, e) ->
        let e' = step_exp ctx e in
        Set (a, e')
  in step;;
  

let rec eval_exp ctx e = 
  if is_exp_val e 
  then e
  else eval_exp ctx (step_exp ctx e);;


let rec eval_cmd mem ctx m = 
  if is_final m
  then m
  else eval_cmd mem ctx (step_cmd mem ctx m);;
