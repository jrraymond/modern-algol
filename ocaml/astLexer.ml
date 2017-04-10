


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


let cons_ne xs xss =
  if xs = []
  then xss
  else implode (List.rev xs)::xss;;


let rec lex_h chars acc tkns = 
  match chars with
  | '-'::'>'::rem -> lex_h rem [] ("->"::cons_ne acc tkns)
  | '<'::'-'::rem -> lex_h rem [] ("<-"::cons_ne acc tkns)
  | ':'::'='::rem -> lex_h rem [] (":="::cons_ne acc tkns)
  | '*'::'*'::rem -> lex_h rem [] ("**"::cons_ne acc tkns)
  | '.'::rem -> lex_h rem [] ("."::cons_ne acc tkns)
  | '@'::rem -> lex_h rem [] ("@"::cons_ne acc tkns)
  | ':'::rem -> lex_h rem [] (":"::cons_ne acc tkns)
  | ';'::rem -> lex_h rem [] (";"::cons_ne acc tkns)
  | '['::rem -> lex_h rem [] ("["::cons_ne acc tkns)
  | ']'::rem -> lex_h rem [] ("]"::cons_ne acc tkns)
  | '('::rem -> lex_h rem [] ("("::cons_ne acc tkns)
  | ')'::rem -> lex_h rem [] (")"::cons_ne acc tkns)
  | '\\'::rem -> lex_h rem [] ("\\"::cons_ne acc tkns)
  | '/'::rem -> lex_h rem [] ("/"::cons_ne acc tkns)
  | '*'::rem -> lex_h rem [] ("*"::cons_ne acc tkns)
  | '+'::rem -> lex_h rem [] ("+"::cons_ne acc tkns)
  | '-'::rem -> lex_h rem [] ("-"::cons_ne acc tkns)
  | '%'::rem -> lex_h rem [] ("%"::cons_ne acc tkns)
  | '^'::rem -> lex_h rem [] ("^"::cons_ne acc tkns)
  | '|'::rem -> lex_h rem [] ("|"::cons_ne acc tkns)
  | '_'::rem -> lex_h rem [] ("_"::cons_ne acc tkns)
  | ch::rem when is_sep ch -> lex_h rem [] (cons_ne acc tkns)
  | ch::rem -> lex_h rem (ch::acc) tkns
  | [] -> List.rev (cons_ne acc tkns)


let lex inp = lex_h (explode inp) [] [];;
