let id_src = ref 0;;

let next_id () =
  let i = !id_src in
  id_src := i + 1;
  i;;


let transform env e =
  let rec go i env defs e =
    match e with
    | TypedAst.Var (v, t) -> FlatAst.Var (v, t), defs
    | TypedAst.Int i -> FlatAst.Int i, defs
    | TypedAst.App (e0, e1, t) ->
        let e0', defs0 = go i env defs e0 in
        let e1', defs1 = go i env defs e1 in
        FlatAst.App (e0', e1', t), defs0 @ defs1
    | TypedAst.Fix (x, tx, e0, t) ->
        let e0', defs0 = go (i + 1) env defs e0 in
        FlatAst.Fix (x, tx, e0', t), defs0
    | _ -> raise (Failure "unimplimented")
  in go 0 env [] e;;
