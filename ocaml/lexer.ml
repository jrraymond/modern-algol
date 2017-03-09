

let keywords = [ "nat"; "cmd"; "fix"; "cmd"; "ret"; "bnd"; "dcl"; "S"; "Z"];;

type token =
  | Var of string
  | LBracket    (* non-stringy tokens *)
  | RBracket
  | LParen
  | RParen
  | Lambda
  | VBar
  | Dot
  | Colon
  | Semicolon
  | Arrow
  | RArrow
  | LArrow
  | Assign
  | Fix         (* stringy tokens *)
  | Nat
  | Cmd
  | Ret
  | Bnd
  | In
  | Is
  | Dcl
  | At
  | Int of int (* Numbers and their operations *)
  | Plus
  | Dash
  | Star
  | Pct
  | FSlash
  | Carrot;;


(* convert a string to a list of chars *)
let explode s =
  let rec go i acc =
    if i < 0
    then acc
    else go (i - 1) (s.[i] :: acc)
  in go (String.length s - 1) [];;


(* convert is list of char to a string *)
let implode cs =
  let bs = Bytes.create (List.length cs) in
  let () = List.iteri (Bytes.set bs) cs in
  Bytes.to_string bs;;


(* return if xs is a prefix of ys *)
let rec is_prefix_of xs ys =
  match (xs, ys) with
  | ([], _) -> true
  | (_, []) -> false
  | (x::xs', y::ys') -> x = y && is_prefix_of xs' ys';;


(* return if p is a prefix of s *)
let starts_with p s =
  let rec go i =
    if i >= String.length p
    then true
    else p.[i] <> s.[i] && go (i + 1)
  in go 0;;


(* separators that are not tokens themselves *)
let is_sep = String.contains " \t\r\n";;


(* separators that are tokens *)
let is_tkn_sep = String.contains "()[]|\\/@.;+-*%^";;


let token_of_string cs =
  match cs with
  | "nat" -> Nat
  | "->" -> Arrow
  | "[" -> LBracket
  | "]" -> RBracket
  | "(" -> LParen
  | ")" -> RParen
  | "\\" -> Lambda
  | "|" -> VBar
  | "." -> Dot
  | ":" -> Colon
  | ";" -> Semicolon
  | ">" -> RArrow
  | "<" -> LArrow
  | ":=" -> Assign
  | "fix" -> Fix
  | "cmd" -> Cmd
  | "ret" -> Ret
  | "bnd" -> Bnd
  | "in" -> In
  | "is" -> Is
  | "dcl" -> Dcl
  | "@" -> At
  | "+" -> Plus
  | "-" -> Dash
  | "*" -> Star
  | "%" -> Pct
  | "/" -> FSlash
  | "^" -> Carrot
  | wd ->
      try
        Int (int_of_string wd)
      with Failure "int_of_string" ->
        Var wd;;

let rec lex_h chars acc tkns = 
  match chars with
  | 'n'::'a'::'t'::rem -> lex_h rem [] (Nat::tkns)
  | 'f'::'i'::'x'::rem -> lex_h rem [] (Nat::tkns)
  | ch::rem when is_sep ch ->
      let wd = implode (List.rev acc) in
      let t = token_of_string wd in
      lex_h rem [] (t::tkns)
  | ch::rem when is_tkn_sep ch ->
      let wd = implode (List.rev (ch::acc)) in
      let t = token_of_string wd in
      lex_h rem [] (t::tkns)
  | ch::rem -> lex_h rem (ch::acc) tkns
  | [] when acc <> [] -> 
      let wd = implode (List.rev acc) in
      let t = token_of_string wd in
      List.rev (t::tkns)
  | [] -> List.rev tkns;; 


let lex inp = lex_h (explode inp) [] [];;
