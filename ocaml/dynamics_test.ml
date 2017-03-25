open Ast;;
open Dynamics;;
open OUnit2;;


let id_fun = Abs ("x", IntTyp, Var { label = "x"; index = 0 } );;

let mk_empty_state m = { cmd = m; memory = Hashtbl.create 0 };;

(* test exp values do not step *)
let exp_value_tests = List.map (fun v -> 
  let vs = string_of_exp v in
  let res = fun () -> step_exp v in
  let m = "expect raises Stuck" in
  vs >:: (fun _ -> assert_raises ~msg:m Stuck res))
  [ Int 0 (* 19.2a *)
  ; Int 1 (* 19.2b *)
  ; id_fun (* 19.2c *)
  ; Cmd (Ret id_fun) (* 34.2a *)
  ];;



(* test single step of expressions *)
let exp_step_tests = List.map (fun (arg, ans) ->
  let s = string_of_exp arg in
  let res = step_exp arg in
  let m = string_of_exp res ^ "<>" ^ string_of_exp ans in
  s >:: (fun _ -> assert_equal ~msg:m ans res))
  [ (App (id_fun, id_fun), id_fun) (* 19.3g *)
  ; (App(App (id_fun, id_fun),  App (id_fun, id_fun)), App (id_fun, App (id_fun, id_fun))) (* 19.3e *)
  ; (App (id_fun, App (id_fun, id_fun)), App (id_fun, id_fun)) (* 19.3f *)
  ; (Fix ("x", IntTyp, App (id_fun, Abs ("z", IntTyp, Var { label = "x"; index = 1} ))),
    App (id_fun, Abs ("z", IntTyp, Fix ("x", IntTyp, App (id_fun, Abs ("z", IntTyp, Var { label = "x"; index = 1 } )))))) (* 19.3h *)
  ];;


(* test cmd final state *)
let cmd_final_state_test = 
  let state = { cmd = Ret (Int 0); memory = Hashtbl.create 0 } in (* 34.3a *)
  let s = string_of_state state in
  let m = "expect raises stuck" in
  let res = fun () -> step_state state in
  s >:: (fun _ -> assert_raises ~msg:m Stuck res)


(* test single step of commands *)
let memory = Hashtbl.create 0;;

let state_step_tests = List.map (fun (state, ans) ->
  let s = string_of_state state in
  let res = step_state state in
  let m = string_of_state res ^ "<>" ^ string_of_state ans in
  s >:: (fun _ -> assert_equal ~cmp:eq_state ~msg:m ans res))
  [ (* 34.3b *)
    ( { cmd = Ret (App (id_fun, id_fun)); memory },
      { cmd = Ret id_fun; memory } )
  ; (* 34.3c *)
    ( { cmd = Bnd ("x", Cmd (Ret (App (id_fun, id_fun))), Ret (Int 0)); memory }
    , { cmd = Bnd ("x", Cmd (Ret id_fun), Ret (Int 0)); memory } )
  ; (* 34.3d *)
    ( { cmd = Bnd ("x", Cmd (Ret (Int 0)), Ret (Var { label = "x"; index = 0 })); memory }
    , { cmd = Ret (Int 0); memory } )
  ; (* 34.3e *)
    ( let memory = Hashtbl.create 4 in
      let () = Hashtbl.add memory "a0" (Int 0) in
      { cmd = Bnd ("x", Cmd (Set ("a0", Int 1)), Ret (Var { label = "x"; index = 0 })); memory }
    , let memory = Hashtbl.create 4 in
      let () = Hashtbl.add memory "a0" (Int 1) in
      { cmd = Bnd ("x", Cmd (Ret (Int 1)), Ret (Var { label = "x"; index = 0 })); memory } )
    (* 34.3f *)
  ; ( let memory = Hashtbl.create 4 in
      let () = Hashtbl.add memory "a0" (Int 0) in
      { cmd = Get "a0"; memory }
    , { cmd = Ret (Int 0); memory } )
    (* 34.3g *)
  ; ( { cmd = Set ("a0", App (id_fun, Int 1)); memory }
    , { cmd = Set ("a0", Int 1); memory } )
    (* 34.3h *)
  ; ( let memory = Hashtbl.create 4 in
      let () = Hashtbl.add memory "a0" (Int 0) in
      { cmd = Set ("a0", Int 1); memory }
    , let memory = Hashtbl.create 4 in
      let () = Hashtbl.add memory "a0" (Int 1) in
      { cmd = Ret (Int 1); memory } )
    (* 34.3i *)
  ; ( { cmd = Dcl ("a", App (id_fun, Int 0), Get "a"); memory }
    , { cmd = Dcl ("a", Int 0, Get "a"); memory } )
    (* 34.3j step modifies memory *)
  ; ( let memory = Hashtbl.create 4 in
      let () = Hashtbl.add memory "a2" (Int 2) in
      { cmd = Dcl ("a", Int 0, Bnd ("x", Cmd (Set ("a2", Int 4)), Get "a")); memory }
    , let memory = Hashtbl.create 4 in
      let () = Hashtbl.add memory "a2" (Int 4) in
      { cmd = Dcl ("a", Int 0, Bnd ("x", Cmd (Ret (Int 4)), Get "a")); memory } )
    (* step modifies memory assignable points to *)
  ; ( let memory = Hashtbl.create 4 in
      { cmd = Dcl ("a", Int 0, Bnd ("x", Cmd (Set ("a", Int 4)), Get "a")); memory }
    , let memory = Hashtbl.create 4 in
      { cmd = Dcl ("a", Int 4, Bnd ("x", Cmd (Ret (Int 4)), Get "a")); memory } )
    (* 34.3k *)
  ; ( { cmd = Dcl ("a", Int 0, Ret (Int 1)); memory }
    , { cmd = Ret (Int 1); memory } )

  ];;





let () = run_test_tt_main ("dynamics" >:::
  [ "exp values" >::: exp_value_tests
  ; "exp step" >::: exp_step_tests
  ; "cmd final state" >: cmd_final_state_test
  ; "state step" >::: state_step_tests
  ]);;
