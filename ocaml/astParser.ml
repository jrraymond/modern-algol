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
let parse_var tkns = 
  match tkns with
  | t::tkns' -> t, tkns'
  | [] -> raise (Failure "expected variable");;


let rec parse_cmd tkns =
  let () = print_endline ("CMD:" ^ intercalate " " tkns) in
  match tkns with
  | "ret"::tkns' -> 
      let e, tkns1 = parse_expe tkns' in
      Ret e, tkns1
  | "bnd"::v::"<-"::tkns' ->
      let () = print_endline (intercalate " " (snd (parse_expe tkns'))) in 
      let e, ";"::tkns1 = parse_expe tkns' in
      let m, tkns2 = parse_cmd tkns1 in
      Bnd (v, e, m), tkns2
  | "dcl"::a::":="::tkns' ->
      let () = print_endline (intercalate " " (snd (parse_expe tkns'))) in 
      let e, "in"::tkns1 = parse_expe tkns' in
      let m, tkns2 = parse_cmd tkns1 in
      Dcl (a, e, m), tkns2
  | "@"::e::tkns' ->
      Get e, tkns'
  | a::":="::tkns' ->
      let e, tkns1 = parse_expe tkns' in
      Set (a, e), tkns1
  | _ -> raise (Failure "failed to parse cmd")
and parse_expe tkns =
  let () = print_endline ("EXP:" ^ intercalate " " tkns) in
  match tkns with
  | [] -> raise (Failure "unexpected end of input")
  | "("::tkns' ->
      let e, ")"::tkns1 = parse_expe tkns' in
      e, tkns1
  | _ ->
    let e0, tkns' = parse_expd tkns in
    if tkns' = []
    then e0, tkns'
    else
      let e1, tkns'' = parse_expe tkns' in
      App (e0, e1), tkns''
and parse_expd tkns =
  let () = print_endline ("DXP:" ^ intercalate " " tkns) in
  match tkns with
  | [] -> raise (Failure "Unexpected end of input")
  | "cmd"::tkns' ->
      let m, tkns'' = parse_cmd tkns' in
      Cmd m, tkns''
  | "\\"::x::":"::tkns' ->
      let tkns1, "."::tkns2 = split_while ((<>) ".") tkns' in
      let typ = parse_typ tkns1 in
      let e, tkns3 = parse_expe tkns2 in
      Abs (x, typ, e), tkns3
  | "fix"::x::":"::tkns' ->
      let tkns1, "is"::tkns2 = split_while ((<>) "is") tkns' in
      let typ = parse_typ tkns1 in
      let e, tkns3 = parse_expe tkns2 in
      Fix (x, typ, e), tkns3
  | t::tkns' ->
      let () = print_endline t in
      try
        let i = int_of_string t in
        Int i, tkns'
      with Failure _ ->
        Var t, tkns';;


let parse tkns = parse_cmd tkns |> fst;;
