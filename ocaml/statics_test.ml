open Ast;;
open OUnit2;;
open Result;;
open Statics;;

let string_of_result err ok x =
  match x with
  | Ok a -> ok a
  | Error a -> err a;;

let string_of_exp_result =
  string_of_result (fun s -> s) string_of_exp;;

let well_typed_tests = List.map (fun (arg, ans) ->
  let vs = string_of_exp arg in
  let res = type_check arg in
  let m = string_of_exp_result res ^ "<>" ^ string_of_exp_result ans in
  vs >:: (fun _ -> assert_equal ~msg:m ans res))
  [ 
  ];;
