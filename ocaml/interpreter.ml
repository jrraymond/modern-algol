
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
      Ast.Var { Ast.label; Ast.index }
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
  | ParseAst.BndT (x, e) ->
      Ast.BndT (x, db_of_exp e ctx)
  | ParseAst.Dcl (a, e, m0) ->
      let e' = db_of_exp e ctx in
      let m0' = db_of_cmd m0 ctx in
      Ast.Dcl (a, e', m0')
  | ParseAst.DclT (a, e) ->
      Ast.DclT (a, db_of_exp e ctx)
  | ParseAst.Get a -> Ast.Get a
  | ParseAst.Set (a, e) ->
      let e' = db_of_exp e ctx in
      Ast.Set (a, e');;


let is_cmd tkns =
  match tkns with
  | t0::t1::_ -> t1 = ":=" || List.mem t0 ["ret"; "bnd"; "dcl"; "@"]
  | _ -> false


let rec run ctx env memory =
  let inp = read_line () in
  let tkns = AstLexer.lex inp in
  try 
    if is_cmd tkns
    then
      let m, _ = AstParser.parse_cmd tkns in
      let cmd = db_of_cmd m [] in
      (match Statics.type_check_cmd ctx env cmd with
      | Error e -> Printf.printf "%s\n" e
      | Ok t -> Printf.printf ": %s\n" (Ast.string_of_typ t));
      let m' = Dynamics.eval_cmd ctx { Dynamics.cmd ; Dynamics.memory } in
      Printf.printf "> %s\n" (Ast.string_of_cmd m');
      run ctx env memory
    else
      let e, _ = AstParser.parse_expe tkns in
      let exp = db_of_exp e [] in
      (match Statics.type_check_exp ctx env exp with
      | Error e -> Printf.printf "%s\n" e
      | Ok t -> Printf.printf ": %s\n" (Ast.string_of_typ t));
      let e' = Dynamics.eval_exp ctx exp in
      Printf.printf "> %s\n" (Ast.string_of_exp e');
      run ctx env memory
  with
  | AstParser.ParseFailure msg ->
      Printf.printf "%s\n" msg;
      run ctx env memory
  | Not_found ->
      Printf.printf "undefined variable\n";
      run ctx env memory;;


let () = run [] (Statics.asg_of_list []) (Hashtbl.create 8);;
