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
      


let step_exp (e : exp) : exp = Int 0;;


let step_cmd (m : cmd) : cmd = m;;


let step_state (s : state) : state = s;;
 

let eval_exp (e : exp) : exp = Int 0;;


let eval (m : cmd) : cmd = Ret (Int 0);;
