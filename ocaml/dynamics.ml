open Ast;;
open Utils;;


exception Stuck;;


type state = { cmd : cmd; memory : (string, exp) Hashtbl.t };;

let eq_state a b =
  let subset_of a b =
    try
      let () = Hashtbl.iter (fun k v ->
        if v = Hashtbl.find b.memory k
        then ()
        else raise Not_found
      ) a.memory
      in true
    with Not_found -> false
  in a = b && subset_of a b && subset_of b a;;


let string_of_state state = 
  let cmd = string_of_cmd state.cmd in
  let mem = Hashtbl.fold (fun k v acc ->
    Printf.sprintf "%s:%s" k (string_of_exp v) :: acc)
    state.memory
    []
  in 
  cmd ^ "||" ^ intercalate "," mem;;
      

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


let rec step_exp (e : exp) : exp = 
  match e with
  | App (Abs (x, _, e0), e1) when is_exp_val e1 -> subst_exp e1 0 e0
  | App (Abs _ as e0, e1) -> App (e0, step_exp e1)
  | App (e0, e1) -> App (step_exp e0, e1)
  | Fix (x, _, e0) -> subst_exp e 0 e0
  | _ -> raise Stuck;;


let step_state (s : state) : state =
  let rec step_cmd (m : cmd) : cmd =
    match m with
    | Ret e ->
        Ret (step_exp e)
    | Bnd (x, Cmd (Ret e), m) when is_exp_val e ->
        subst_cmd e 0 m
    | Bnd (x, Cmd m1, m2) ->
        let m1' = step_cmd m1 in
        Bnd (x, Cmd m1', m2)
    | Bnd (x, e, m) ->
        Bnd (x, step_exp e, m)
    | Dcl (a, e, Ret e') when is_exp_val e && is_exp_val e' ->
        Ret e'
    | Dcl (a, e, m) when is_exp_val e ->
        let () = Hashtbl.add s.memory a e in
        let m' = step_cmd m in
        let e' = Hashtbl.find s.memory a in
        let () = Hashtbl.remove s.memory a in
        Dcl (a, e', m')
    | Dcl (a, e, m) ->
        Dcl (a, step_exp e, m)
    | Get a -> Ret (Hashtbl.find s.memory a)
    | Set (a, e) when is_exp_val e ->
        let () = Hashtbl.replace s.memory a  e in
        Ret e
    | Set (a, e) ->
        let e' = step_exp e in
        Set (a, e')
  in { s with cmd = step_cmd s.cmd };;
  

let rec eval_exp ctx e = 
  if is_exp_val e 
  then e
  else eval_exp ctx (step_exp e);;


let rec eval_cmd ctx s = 
  if is_final s.cmd
  then s.cmd
  else eval_cmd ctx (step_state s);;
