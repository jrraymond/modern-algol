type typ = IntTyp | FunTyp of typ * typ | CmdTyp

type exp =
  | Var of string
  | Int of int
  | Fix of string * typ * exp
  | Abs of string * typ * exp
  | App of exp * exp
  | Cmd of cmd
and cmd =
  | Ret of exp
  | Bnd of string * exp * cmd
  | Dcl of string * exp * cmd
  | Get of string
  | Set of string * exp;;



let rec string_of_typ t =
  match t with
  | IntTyp -> "int"
  | CmdTyp -> "cmd"
  | FunTyp (FunTyp (a, b), c) ->
      "(" ^ string_of_typ a ^ " -> " ^ string_of_typ b ^ ") -> " ^ string_of_typ c
  | FunTyp (a, b) -> string_of_typ a ^ " -> " ^ string_of_typ b;;


let rec base_typ_of_string s =
  match s with
  | "int" -> IntTyp
  | "cmd" -> CmdTyp
  | _ -> raise (Failure "base_typ_of_string");;


let rec string_of_exp e =
  match e with
  | Var x -> x
  | Int i -> string_of_int i
  | Fix (x, t, e') -> "fix " ^ x ^ " : " ^ string_of_typ t ^ " is " ^ string_of_exp e'
  | Abs (x, t, e') -> "(\\" ^ x ^ " : " ^ string_of_typ t ^ " . " ^ string_of_exp e' ^ ")"
  | App (e0, e1) -> string_of_exp e0 ^ "(" ^ string_of_exp e1 ^ ")"
  | Cmd m -> "cmd " ^ string_of_cmd m
and string_of_cmd c =
  match c with
  | Ret e -> "ret " ^ string_of_exp e
  | Bnd (x, e, m) -> "bnd " ^ x ^ " <- " ^ string_of_exp e ^ "; " ^ string_of_cmd m
  | Dcl (x, e, m) -> "dcl " ^ x ^ " := " ^ string_of_exp e ^ " in " ^ string_of_cmd m
  | Get a -> "@" ^ a
  | Set (a, e) -> a ^ " := " ^ string_of_exp e;;
