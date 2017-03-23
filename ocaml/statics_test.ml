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


let well_typed_exp_tests = List.map (fun (arg0, arg1, ans) ->
  let vs = string_of_ctx arg0 ^ "," ^ string_of_exp arg1 in
  let asg = asg_of_list [] in
  let res = type_check_exp arg0 asg 0 arg1 in
  let m = string_of_typ_result res ^ "<>" ^ string_of_typ_result ans in
  vs >:: (fun _ -> assert_equal ~msg:m ans res))
  [ (ctx_of_list [(0, IntTyp)], Var { label = "x"; index = 0 }, Ok IntTyp)
  ; (ctx_of_list [], Int 0, Ok IntTyp)
  ; (ctx_of_list [], id_fun, Ok (FunTyp (IntTyp, IntTyp)))
  ; (ctx_of_list [], App (id_fun, Int 0), Ok IntTyp)
  ; (ctx_of_list [], Fix ("x", IntTyp, App (id_fun, Var { label = "x"; index = 0 })), Ok IntTyp)
  ];;


let well_typed_cmd_tests = [];;


let () = run_test_tt_main ("statics" >:::
  [ "exp" >::: well_typed_exp_tests
  ; "cmd" >::: well_typed_cmd_tests
  ]);;
