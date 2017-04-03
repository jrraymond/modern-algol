open Ast;;
open OUnit2;;
open Result;;
open Statics;;


let id_fun = Abs ("x", IntTyp, Var { label = "x"; index = 0});;


let string_of_result err ok x =
  match x with
  | Ok a -> "Ok " ^ ok a
  | Error a -> "Error " ^ err a;;


let string_of_typ_result =
  string_of_result (fun s -> s) string_of_typ;;


let well_typed_exp_tests = List.map (fun (ctx, exp, ans) ->
  let vs = string_of_ctx ctx ^ "," ^ string_of_exp exp in
  let asg = asg_of_list [] in
  let te = type_exp ctx asg exp in
  let res = Utils.rmap TypedAst.typ_of_exp te in
  let m = string_of_typ_result res ^ "<>" ^ string_of_typ_result ans in
  vs >:: (fun _ -> assert_equal ~msg:m ans res))
  [ (ctx_of_list [IntTyp], Var { label = "x"; index = 0 }, Ok IntTyp)
  ; (ctx_of_list [], Int 0, Ok IntTyp)
  ; (ctx_of_list [], id_fun, Ok (FunTyp (IntTyp, IntTyp)))
  ; (ctx_of_list [], App (id_fun, Int 0), Ok IntTyp)
  ; (ctx_of_list [], Fix ("x", IntTyp, App (id_fun, Var { label = "x"; index = 0 })), Ok IntTyp)
  ; (ctx_of_list [], Cmd (Ret (Int 0)), Ok CmdTyp)
  ; (ctx_of_list [], Case (Int 0, [(Lit 0, Int 1); (Binder "x", Var { label = "x"; index = 0 })]), Ok IntTyp)
  ];;


let well_typed_cmd_tests = List.map (fun (asg, cmd, ans) ->
  let vs = string_of_asg asg ^ "," ^ string_of_cmd cmd in
  let ctx = ctx_of_list [] in
  let tm = type_cmd ctx asg cmd in
  let res = Utils.rmap TypedAst.typ_of_cmd tm in
  let m = string_of_typ_result res ^ " <> " ^ string_of_typ_result ans in
  vs >:: (fun _ -> assert_equal ~msg:m ans res))
  [ (asg_of_list [], Ret (Int 0), Ok CmdTyp)
  ; (asg_of_list [], Bnd ("x", Cmd (Ret (Int 0)), Ret (Var { label = "x"; index = 0 })), Ok CmdTyp)
  ; (asg_of_list [], Dcl ("a", Int 0, Get "a"), Ok CmdTyp)
  ; (asg_of_list [("a", IntTyp)], Get "a", Ok CmdTyp)
  ; (asg_of_list [("a", IntTyp)], Set ("a", Int 0), Ok CmdTyp)
  ];;


let () = run_test_tt_main ("statics" >:::
  [ "exp" >::: well_typed_exp_tests
  ; "cmd" >::: well_typed_cmd_tests
  ]);;
