

let transform e closures =
  match e with
  | TypedAst.Var v -> FlatAst.Var v
  | TypedAst.Int i -> FlatAst.Int i
  | _ -> raise (Failure "unimplimented");;
