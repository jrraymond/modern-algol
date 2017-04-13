open ParseAst;;
open Utils;;
open Typ;;
 

exception ParseFailure of string;;


let shunt_typ = 
  let rec pusher stack queue tkns =
    match tkns with
    | [] -> List.rev queue @ stack
    | "("::tkns' -> pusher ("("::stack) queue tkns'
    | ")"::tkns' ->
        let mv, stack0 = split_while ((<>) "(") stack in
        (match stack0 with
        | "("::stack1 -> pusher stack1 (mv @ queue) tkns'
        | _ -> raise (ParseFailure "unmatched ')'"))
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
        | _ -> raise (ParseFailure ("expected operands")))
    | "int"::rem -> go (IntTyp::stack) rem
    | "cmd"::rem -> go (CmdTyp::stack) rem
    | t::_ -> raise (ParseFailure ("unexpected '" ^ t ^ "'"))
    | [] -> 
        (match stack with
        | [ast] -> ast
        | _ ->
            let m = intercalate "," (List.map string_of_typ stack) in
            raise (ParseFailure ("parse error:" ^ m)))
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
 * We describe the grammar using EBNF. {} means 0 or more times.
 *
 *  e ::= e0 {e0}
 *  e0 ::= e1 | fix x:t is e | \x:t.e | cmd m
 *      | case e of \| p -> e { | p -> e}
 *  e1 ::= e2 {+|- e1}
 *  e2 ::= e3 {*/% e2}
 *  e3 ::= e4 | -e3
 *  e4 ::= e5 {** e4}
 *  e5 ::= (e) | <int> | <var>
 *
 *
 * The syntax for commands is
 *  m ::= ret e | bnd x <- e ; m | dcl a := e in m | @ a | a := e
 *)
let parse_pattern tkn =
  try Lit (int_of_string tkn)
  with Failure _ -> Binder tkn;;

(* given c, b, a and binary operator op, constructs expression
 * op (op (a, b), c)
 *)
let right_assoc op exps =
  match List.rev exps with
  | [] -> raise (Failure "expected expression")
  | e::es -> List.fold_left op e es;;

let rec parse_cmd tkns =
  match tkns with
  | "ret"::tkns' -> 
      let e, tkns1 = parse_expe tkns' in
      Ret e, tkns1
  | "bnd"::v::"<-"::tkns' ->
      let e, tkns1 = parse_expe tkns' in
      (match tkns1 with
      | ";"::tkns2 ->
        let m, tkns3 = parse_cmd tkns2 in
        Bnd (v, e, m), tkns3
      | [] -> BndT (v, e), []
      | _ -> raise (ParseFailure "expected ';'"))
  | "dcl"::a::":="::tkns' ->
      let e, tkns1 = parse_expe tkns' in
      (match tkns1 with
      | "in"::tkns2 ->
        let m, tkns3 = parse_cmd tkns2 in
        Dcl (a, e, m), tkns3
      | [] -> DclT (a, e), []
      | _ -> raise (ParseFailure "expected 'in'"))
  | "@"::e::tkns' ->
      Get e, tkns'
  | a::":="::tkns' ->
      let e, tkns1 = parse_expe tkns' in
      Set (a, e), tkns1
  | _ -> raise (ParseFailure "failed to parse cmd")
and parse_expe tkns =
  (*  e ::= e0 {e0} *)
  let rec parse_e tkns =
    let rec pe acc tkns =
      match parse_e0 tkns with
      | e0, tkns' when tkns' = [] || List.mem (List.hd tkns') [")"; "of"; "|"; ";"; "in"] ->
          let e = right_assoc (fun a b -> App (a, b)) (e0::acc) in
          e, tkns'
      | e0, tkns' -> pe (e0::acc) tkns'
    in pe [] tkns
  (*  e0 ::= <int> | fix x:t is e | \x:t.e | cmd m
   *      | case e of \| p -> e { | p -> e} | e1 *)
  and parse_e0 tkns =
    match tkns with
    | "cmd"::tkns' ->
        let m, tkns'' = parse_cmd tkns' in
        Cmd m, tkns''
    | "\\"::x::":"::tkns' ->
        let tkns1, tkns2 = split_while ((<>) ".") tkns' in
        (match tkns2 with
        | "."::tkns3 ->
          let typ = parse_typ tkns1 in
          let e, tkns4 = parse_e tkns3 in
          Abs (x, typ, e), tkns4
        | _ -> raise (ParseFailure "expected '.'"))
    | "fix"::x::":"::tkns' ->
        let tkns1, tkns2 = split_while ((<>) "is") tkns' in
        (match tkns2 with
        | "is"::tkns3 ->
          let typ = parse_typ tkns1 in
          let e, tkns4 = parse_e tkns3 in
          Fix (x, typ, e), tkns4
        | _ -> raise (ParseFailure "expected 'is'"))
    | "case"::tkns' ->
        let tkns1, "of"::tkns2 = split_while ((<>) "of") tkns' in
        let e, tkns1' = parse_e tkns1 in
        let cs = parse_cases tkns2 in
        (match tkns1', cs with
        | _, [] -> raise (ParseFailure "case cannot be empty")
        | [], _ -> Case (e, cs), []
        | _ -> raise (ParseFailure "expected 'of'"))
    | _ -> parse_e1 tkns
  (*  e1 ::= e2 {+|- e1} *)
  and parse_e1 tkns =
    let rec pe1 args ops tkns =
      match parse_e2 tkns with
      | e, t::tkns' when t = "+" -> pe1 (e::args) (Add::ops) tkns'
      | e, t::tkns' when t = "-" -> pe1 (e::args) (Sub::ops) tkns'
      | e, tkns' ->
          let e0::es = List.rev (e::args) in
          let os = List.rev ops in
          let e' = List.fold_left2 (fun a b p -> Op (p, [a; b])) e0 es os in
          e', tkns'
    in pe1 [] [] tkns
  (*  e2 ::= e3 {*/% e2} *)
  and parse_e2 tkns =
    let rec pe2 args ops tkns =
      match parse_e3 tkns with
      | e, t::tkns' when t = "*" -> pe2 (e::args) (Mult::ops) tkns'
      | e, t::tkns' when t = "/" -> pe2 (e::args) (Div::ops) tkns'
      | e, t::tkns' when t = "%" -> pe2 (e::args) (Mod::ops) tkns'
      | e, tkns' ->
          let e0::es = List.rev (e::args) in
          let os = List.rev ops in
          let e' = List.fold_left2 (fun a b p -> Op (p, [a; b])) e0 es os in
          e', tkns'
    in pe2 [] [] tkns
  (*  e3 ::= e4 | -e3 *)
  and parse_e3 tkns =
    match tkns with
    | "-"::tkns' ->
        let e', tkns'' = parse_e3 tkns' in
        Op (Neg, [e']), tkns''
    | _ -> parse_e4 tkns
  (*  e4 ::= e5 {** e4} *)
  and parse_e4 tkns =
    let rec pe4 acc tkns =
      match parse_e5 tkns with
      | e, t::tkns' when t = "**" -> pe4 (e::acc) tkns'
      | e, tkns' ->
          let e0::es = List.rev (e::acc) in
          let e' = List.fold_left (fun a b -> Op (Pow, [a; b])) e0 es in
          e', tkns'
    in pe4 [] tkns
  (*  e5 ::= (e) | <int> | <var> *)
  and parse_e5 tkns =
    match tkns with
    | [] -> raise  (ParseFailure "unexpected end of input")
    | "("::tkns' ->
        (match parse_e tkns' with
        | e, ")"::tkns'' -> e, tkns''
        | _, tkns'' -> raise (ParseFailure ("expected ')'" ^ List.hd tkns'')))
    | t::tkns' ->
        (try
          let i = int_of_string t in
          Int i, tkns'
        with Failure _ ->
          Var t, tkns')
  and parse_cases tkns =
    match tkns with
    | [] -> []
    | "|"::p::"->"::tkns' ->
        let ptn = parse_pattern p in
        let e, tkns'' = parse_e tkns' in
        (ptn, e)::parse_cases tkns''
    | _ -> raise (ParseFailure ("expected '|', found" ^ (List.hd tkns)))
  in parse_e tkns;;



let parse tkns = parse_cmd tkns |> fst;;
