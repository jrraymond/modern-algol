type typ = IntTyp | FunTyp of typ * typ | CmdTyp


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
