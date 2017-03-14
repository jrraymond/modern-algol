open Ast;;
open Utils;;


exception Stuck of string;;


type state = { cmd : cmd; memory : (string, int) Hashtbl.t };;


let string_of_state state = 
  let cmd = string_of_cmd state.cmd in
  let mem = Hashtbl.fold (fun k v acc ->
    Printf.sprintf "%s:%i" k v :: acc)
    state.memory
    []
  in 
  cmd ^ intercalate "," mem;;
      

let is_exp_value e = 
  match e with
  | Abs _ -> true
  | Int _ -> true
  | _ -> false;;


(* subst e for x in d *)
let subst (e : exp) (x : string) (d : exp) : exp = d;;


let rec step_exp (e : exp) : exp = 
  match e with
  | App (Abs (x, _, e0), e1) when is_exp_value e1 -> subst e1 x e0
  | App (Abs _ as e0, e1) -> App (e0, step_exp e1)
  | App (e0, e1) -> App (step_exp e0, e1)
  | Fix (x, _, e0) -> subst e x e0
  | _ -> raise (Stuck (string_of_exp e));;


let step_cmd (m : cmd) : cmd = m;;


let step_state (s : state) : state = s;;
 

let eval_exp (e : exp) : exp = Int 0;;


let eval (m : cmd) : cmd = Ret (Int 0);;
