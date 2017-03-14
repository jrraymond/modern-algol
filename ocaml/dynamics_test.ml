open Ast;;
open Dynamics;;
open OUnit2;;


let id_fun = Abs ("x", IntTyp, Var "x");;
exception Stuck of string;;
(* todo what to do on no step, throw exception? *)
(* test exp values do not step *)
let exp_value_tests = List.map (fun v -> 
  let vs = string_of_exp v in
  let res = fun () -> step_exp v in
  let m = "expect raises Stuck" in
  vs >:: (fun _ -> assert_raises ~msg:m (Stuck vs) res))
  [ Int 0 (* 19.2a *)
  ; Int 1 (* 19.2b *)
  ; id_fun (* 19.2c *)
  ];;


(* test cmd values do not step *)
let cmd_value_tests = 
  let v = Ret (App (id_fun, id_fun)) in (* 33.2a *)
  let vs = string_of_cmd v in
  let res = fun () -> step_cmd v in
  let m = "expect raises Stuck" in
  vs >:: (fun _ -> assert_raises ~msg:m (Stuck vs) res)


(* test single step of expressions *)
let exp_step_tests = List.map (fun (arg, ans) ->
  let s = string_of_exp arg in
  let res = step_exp arg in
  let m = string_of_exp res ^ "<>" ^ string_of_exp ans in
  s >:: (fun _ -> assert_equal ~msg:m ans res))
  [ (App (id_fun, id_fun), id_fun) (* 19.3g *)
  ; (App(App (id_fun, id_fun),  App (id_fun, id_fun)), App (id_fun, id_fun)) (* 19.3e *)
  ; (App (id_fun, App (id_fun, id_fun)), App (id_fun, id_fun)) (* 19.3f *)
  ; (Fix ("x", IntTyp, App (id_fun, Abs ("z", IntTyp, Var "x"))),
    App (id_fun, Abs ("z", IntTyp, Fix ("x", IntTyp, App (id_fun, Abs ("z", IntTyp, Var "x")))))) (* 19.3h *)
  ];;


(* test cmd final state *)
let cmd_final_state_test = 
  let state = { cmd = Ret (Int 0); memory = Hashtbl.create 0 } in (* 34.3a *)
  let s = string_of_state state in
  let m = "expect raises stuck" in
  let res = fun () -> step_state state in
  s >:: (fun _ -> assert_raises ~msg:m (Stuck s) res)


(* test single step of commands *)
let state_step_tests = List.map (fun (state, ans) ->
  let s = string_of_state state in
  let res = step_state state in
  let m = string_of_state res ^ "<>" ^ string_of_state ans in
  s >:: (fun _ -> assert_equal ~msg:m ans res))
  [ (* 34.3b *)
    ({ cmd = Ret (App (id_fun, id_fun)); memory = Hashtbl.create 0 },
     { cmd = Ret id_fun; memory = Hashtbl.create 0 })
  ];;





let () = run_test_tt_main ("dynamics" >:::
  [ "exp values" >::: exp_value_tests
  ; "cmd values" >: cmd_value_tests
  ; "exp step" >::: exp_step_tests
  ; "cmd final state" >: cmd_final_state_test
  ; "state step" >::: state_step_tests
  ]);;