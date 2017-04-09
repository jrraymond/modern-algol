module T = TypedAst;;
module F = FlatAst;;
let id_src = ref 0;;

let next_id () =
  let i = !id_src in
  id_src := i + 1;
  i;;


let transform env e =
  let rec go env defs e =
    match e with
    | T.Var (v, t) -> F.Var (v, t), defs
    | T.Int i -> F.Int i, defs
    | T.App (e0, e1, t) ->
        let e0', defs0 = go env defs e0 in
        let e1', defs1 = go env defs e1 in
        F.App (e0', e1', t), defs0 @ defs1
    | T.Fix (x, tx, e0, t) ->
        let e0', defs0 = go env defs e0 in
        F.Fix (x, tx, e0', t), defs0
    | T.Abs (var, argt, e0, typ) ->
        let i = next_id () in
        let body, defs' = go ((var, argt)::env) defs e0 in
        let fvs = T.free_vars_exp 0 e0 in
        let d = { F.var; F.argt; F.env = fvs; F.body; F.typ } in
        F.Fun i, d::defs'
    | T.Op (p, es, t) ->
        let (env, defs'), es' = Utils.accum_left (fun (env, defs) ei ->
          let ei', defs' = go env defs ei in
          ((env, defs'), ei')) (env, defs) es
        in
        F.Op (p, es', t), defs'
    | _ -> raise (Failure "unimplimented")
  in go env [] e;;
