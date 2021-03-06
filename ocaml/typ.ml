type typ = IntTyp | FunTyp of typ * typ | CmdTyp;;

type binop = Add | Sub | Mult | Div | Mod | Pow;;

type unop = Neg;;

type var = { label : string; index : int };;

type pattern = Lit of int | Binder of string;;

let string_of_pattern p =
  match p with
  | Lit i -> string_of_int i
  | Binder s -> s;;


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


let string_of_binop p =
  match p with
  | Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Mod -> "%"
  | Pow -> "**";;

let string_of_unop p =
  match p with
  | Neg -> "-";;

let binop_of_string p =
  match p with
  | "+" -> Add
  | "-" -> Sub
  | "*" -> Mult
  | "/" -> Div
  | "%" -> Mod
  | "**" -> Pow
  | _ -> raise (Failure ("Unknown operator :" ^ p));;


let unop_of_string p =
  match p with
  | "-" -> Neg
  | _ -> raise (Failure ("Unknown operator :" ^ p));;

