open Ast;;
open Utils;;

type associativity = Left | Right;;
 
 
let op_tbl =
  let t = Hashtbl.create 5 in
  let () = List.iter (fun (op, prec, assoc) ->
    Hashtbl.add t op (prec, assoc))
    [ ("^", 4, Right)
    ; ("*", 3, Left)
    ; ("/", 3, Left)
    ; ("+", 2, Left)
    ; ("-", 2, Left) ]
  in t;;
 
 
let shunt_typ = 
  let rec pusher stack queue tkns =
    match tkns with
    | [] -> List.rev queue @ stack
    | "("::tkns' -> pusher ("("::stack) queue tkns'
    | ")"::tkns' ->
        let mv, "("::stack' = split_while ((<>) "(") stack in
        pusher stack' (mv @ queue) tkns'
    | "->"::tkns' -> pusher ("->"::stack) queue tkns'
    | t::tkns' -> pusher stack (t::queue) tkns'
  in pusher [] [];;
 

(* constructs AST from token list in reverse polish notaton *)
let build_typ =
  let rec go stack tkns =
    match tkns with
    | "->"::rem ->
        (match stack with
        | a::b::stack' -> go (FunTyp (b, a)::stack') rem
        | _ -> raise (Failure ("expected operands")))
    | "int"::rem -> go (IntTyp::stack) rem
    | "cmd"::rem -> go (CmdTyp::stack) rem
    | t::_ -> raise (Failure ("unexpected '" ^ t ^ "'"))
    | [] -> 
        (match stack with
        | [ast] -> ast
        | _ ->
            let m = intercalate "," (List.map string_of_typ stack) in
            raise (Failure ("parse error:" ^ m)))
  in go [];;


(* The grammar for type is simple
 * t ::= nat | cmd | (t) | t -> t
 *)
let parse_typ tkns = shunt_typ tkns |> build_typ;;

(* We use recusive descent to parse expressions and commands.
 * We require the grammar be non-left-recursive. The rule 'e ::= e(e)'
 * violates that. 
 *  e ::= d | d(e)
 *  d ::= <int> | fix x:t is e | \x:t.e | cmd m
 *)
let rec parse_cmd tkns =
  match tkns with
  | "ret"::tkns' -> 
      let e, tkns'' = parse_expe tkns' in
      Ret e, tkns''
  | _ -> raise (Failure "todo")
and parse_expe tkns =
  let e0, tkns' = parse_expd tkns in
  if tkns' = []
  then e0, tkns'
  else
    let e1, tkns'' = parse_expe tkns' in
    App (e0, e1), tkns''
and parse_expd tkns =
  match tkns with
  | [] -> raise (Failure "Unexpected end of input")
  | "cmd"::tkns' ->
      let m, tkns'' = parse_cmd tkns' in
      Cmd m, tkns''
  | t::tkns' ->
      try
        let i = int_of_string t in
        Int i, tkns'
      with Failure _ ->
        Var t, tkns';;


let parse tkns = parse_cmd tkns |> fst;;
