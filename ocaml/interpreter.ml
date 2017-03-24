open Typ;;

let get_debruijn =
  let rec go i ctx x =
    match ctx with
    | [] -> raise Not_found
    | y::ys when x = y -> i
    | _::ys -> go (i + 1) ys x
  in go 0;;

let rec db_of_exp e ctx =
  match e with
  | ParseAst.Var label -> 
      let index = get_debruijn ctx label in
      Ast.Var { label; index }
  | ParseAst.Int i -> Ast.Int i
  | ParseAst.Fix (x, t, e0) ->
      let e0' = db_of_exp e0 (x::ctx) in
      Ast.Fix (x, t, e0')
  | ParseAst.App (e0, e1) ->
      let e0' = db_of_exp e0 ctx in
      let e1' = db_of_exp e1 ctx in
      Ast.App (e0', e1')
  | ParseAst.Abs (x, t, e0) ->
      let e0' = db_of_exp e0 (x::ctx) in
      Ast.Abs (x, t, e0')
  | ParseAst.Cmd m -> Ast.Cmd (db_of_cmd m ctx)
and db_of_cmd m ctx =
  match m with
  | ParseAst.Ret e -> Ast.Ret (db_of_exp e ctx)
  | ParseAst.Bnd (x, e, m0) ->
      let e' = db_of_exp e ctx in
      let m0' = db_of_cmd m0 (x::ctx) in
      Ast.Bnd (x, e', m0')
  | ParseAst.Dcl (a, e, m0) ->
      let e' = db_of_exp e ctx in
      let m0' = db_of_cmd m0 ctx in
      Ast.Dcl (a, e', m0')
  | ParseAst.Get a -> Ast.Get a
  | ParseAst.Set (a, e) ->
      let e' = db_of_exp e ctx in
      Ast.Set (a, e');;


let rec run ctx env =
  let inp = read_line () in
  let tkns = AstLexer.lex inp in
  let ast = AstParser.parse tkns in
  let db = db_of_cmd ast [] in
  let () =
    match Statics.type_check_cmd ctx env db with
    | Error e -> print_string e
    | Ok t -> print_string (string_of_typ t ^ "\n")
  in run ctx env


let () = run [] (Statics.asg_of_list []);;
