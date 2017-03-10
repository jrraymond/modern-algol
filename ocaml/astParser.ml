open Ast;;
open Utils;;


(* turns token list into reverse polish notation *)
let shunt tkns = 
  let q = Queue.create () in
  (* pops elements from xs and onto q until x is reached, x is popped but not
   * moved *)
  let rec pop_until p xs =
    match xs with
    | y::xs' when p y -> xs'
    | y::xs' -> 
        let () = Queue.add y q in
        pop_until p xs'
    | [] -> raise (Failure "expected ')'")
  in
  (* moves remaining operators from stack to queue *)
  let rec popper stack =
    match stack with
    | [] -> list_of_queue q
    | "->"::stack' ->
        let () = Queue.add "->" q in
        popper stack'
    | t::_ -> raise (Failure ("unexpected '" ^ t ^ "'"))
  in
  let rec pusher stack tkns = 
    match tkns with
    | [] -> popper stack
    | "int"::rem -> 
        let () = Queue.add "int" q in
        pusher stack rem
    | "cmd"::rem ->
        let () = Queue.add "cmd" q in
        pusher stack rem
    | "("::rem ->
        pusher ("("::stack) rem
    | ")"::rem ->
        (
          match pop_until ((=) "(") stack with
          | "->"::stack' ->
              let () = Queue.add "->" q in
              pusher stack' rem
          | stack' ->
              pusher stack' rem
        )
    | "->"::rem ->
        pusher ("->"::stack) rem
    | t::_ -> raise (Failure ("unexpected '" ^ t ^ "'"))
  in pusher [] tkns;;


(* constructs AST from token list in reverse polish notaton *)
let build_typ =
  let rec go stack tkns =
    match tkns with
    | "->"::rem ->
        (
          match stack with
          | a::b::stack' -> go (FunTyp (a, b)::stack') rem
          | _ -> raise (Failure ("expected operands"))
        )
    | "int"::rem -> go (IntTyp::stack) rem
    | "cmd"::rem -> go (CmdTyp::stack) rem
    | t::_ -> raise (Failure ("unexpected '" ^ t ^ "'"))
    | [] -> 
        (
          match stack with
          | [ast] -> ast
          | _ ->
              let m = intercalate "," (List.map string_of_typ stack) in
              raise (Failure ("parse error:" ^ m))
        )
  in go [];;


let parse_typ tkns = shunt tkns |> build_typ;;

let parse tkns = Ret (Var "todo");;
