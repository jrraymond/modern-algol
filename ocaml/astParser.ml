open Ast;;
open Utils;;
 
 
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
 *  e ::= e e | (e) | <int> | fix x:t is e | \x:t.e | cmd m
 *
 * We can't use a true recursive descent parser because we want
 * left-associativity and left-recursion. So we use a shunting yard algorithm
 * when we want left-associative application.
 *
 * http://cs.stackexchange.com/questions/2696/left-recursion-and-left-factoring-which-one-goes-first?rq=1
 * http://cs.stackexchange.com/questions/56102/how-does-this-left-associative-recursive-descent-parser-work
 *
 *
 *  e ::= d+
 *  d ::= (e) | <int> | fix x:t is e | \x:t.e | cmd m
 *)
let parse_var tkns = 
  match tkns with
  | t::tkns' -> t, tkns'
  | [] -> raise (Failure "expected variable");;


(* creates left-associative application of rev list of expressions *)
let rec appify exps =
  match exps with
  | [e] -> e
  | e0::exps' -> App (appify exps', e0)
  | _ -> raise (Failure "expected expression");;

let rec parse_cmd tkns =
  match tkns with
  | "ret"::tkns' -> 
      let e, tkns1 = parse_expe tkns' in
      Ret e, tkns1
  | "bnd"::v::"<-"::tkns' ->
      let e, ";"::tkns1 = parse_expe tkns' in
      let m, tkns2 = parse_cmd tkns1 in
      Bnd (v, e, m), tkns2
  | "dcl"::a::":="::tkns' ->
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
  match parse_expd tkns with
  | e, [] -> e, []
  | e, (t::_ as tkns0) when t = ")" || t = "in" || t = ";" -> e, tkns0
  | e0, tkns0 ->
      let e1, tkns1 = parse_expe tkns0 in
      App (e0, e1), tkns1
and parse_expd tkns =
  match tkns with
  | [] -> raise (Failure "Unexpected end of input")
  | "("::tkns1 ->
      let e, tkns2 = parse_expe tkns1 in
      (match tkns2 with
      | ")"::tkns3 -> e, tkns3
      | _ -> raise (Failure "expected ')'"))
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
      try
        let i = int_of_string t in
        Int i, tkns'
      with Failure _ ->
        Var t, tkns';;


let parse tkns = parse_cmd tkns |> fst;;
