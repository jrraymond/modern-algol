open Ast;;
open Dynamics;;
open OUnit2;;


let id_fun = Abs ("x", IntTyp, Var { label = "x"; index = 0 } );;


(* test exp values do not step *)
let exp_value_tests = List.map (fun v -> 
  let vs = string_of_exp v in
  let res = fun () -> step_exp [] v in
  let m = "expect raises Stuck" in
  vs >:: (fun _ -> assert_raises ~msg:m Stuck res))
  [ Int 0 (* 19.2a *)
  ; Int 1 (* 19.2b *)
  ; id_fun (* 19.2c *)
  ; Cmd (Ret id_fun) (* 34.2a *)
  ];;



(* test single step of expressions *)
let exp_step_tests = List.map (fun (arg, ans) ->
  let ctx = [("x", Int 0)] in
  let s = string_of_exp arg in
  let res = step_exp ctx arg in
  let m = string_of_exp res ^ "<>" ^ string_of_exp ans in
  s >:: (fun _ -> assert_equal ~msg:m ans res))
  [ (App (id_fun, id_fun), id_fun) (* 19.3g *)
  ; (App(App (id_fun, id_fun),  App (id_fun, id_fun)), App (id_fun, App (id_fun, id_fun))) (* 19.3e *)
  ; (App (id_fun, App (id_fun, id_fun)), App (id_fun, id_fun)) (* 19.3f *)
  ; (Fix ("x", IntTyp, App (id_fun, Abs ("z", IntTyp, Var { label = "x"; index = 1} ))),
    App (id_fun, Abs ("z", IntTyp, Fix ("x", IntTyp, App (id_fun, Abs ("z", IntTyp, Var { label = "x"; index = 1 } )))))) (* 19.3h *)
  ; (Var { label = "x"; index = 0 }, Int 0)
  ; (Case (App (id_fun, Int 0), [(Lit 0, Int 1); (Binder "x", Var { label = "x"; index = 0 })]),
    (Case (Int 0, [(Lit 0, Int 1); (Binder "x", Var { label = "x"; index = 0 })])))
  ; (Case (Int 0, [(Lit 0, Int 1); (Binder "x", Var { label = "x"; index = 0 })]), Int 1)
  ; (Case (Int 2, [(Lit 0, Int 1); (Binder "x", Var { label = "x"; index = 0 })]), Int 2)
  ];;


(* test cmd final state *)
let cmd_final_state_test = 
  let cmd = Ret (Int 0) in
  let mem = Hashtbl.create 0 in (* 34.3a *)
  let s = string_of_cmd cmd in
  let m = "expect raises stuck" in
  let res = fun () -> step_cmd mem [] cmd in
  s >:: (fun _ -> assert_raises ~msg:m Stuck res)


(* test single step of commands *)
let memory = Hashtbl.create 0;;

let state_step_tests = List.map (fun (cmd, mem, ans, mem') ->
  let s = string_of_cmd cmd in
  let res = step_cmd mem [] cmd in
  let c = string_of_cmd res ^ "<>" ^ string_of_cmd ans in
  let m = string_of_memory mem ^ "<>" ^ string_of_memory mem' in
  let msg = c ^ " || " ^ m in
  let eq (m0, x0) (m1, x1) = m0 = m1 && eq_memory x0 x1 in
  s >:: (fun _ -> assert_equal ~cmp:eq ~msg:msg (res, mem) (ans, mem')))
  [ (* 34.3b *)
    ( Ret (App (id_fun, id_fun)), Hashtbl.copy memory, Ret id_fun, memory )
  ; (* 34.3c *)
    ( Bnd ("x", Cmd (Ret (App (id_fun, id_fun))), Ret (Int 0)), Hashtbl.copy memory
    , Bnd ("x", Cmd (Ret id_fun), Ret (Int 0)), memory )
  ; (* 34.3d *)
    ( Bnd ("x", Cmd (Ret (Int 0)), Ret (Var { label = "x"; index = 0 })), Hashtbl.copy memory
    , Ret (Int 0), memory )
  ; (* 34.3e *)
      let m = Hashtbl.create 4 in
      let () = Hashtbl.add m "a0" (Int 0) in
      let m' = Hashtbl.create 4 in
      let () = Hashtbl.add m' "a0" (Int 1) in
    ( Bnd ("x", Cmd (Set ("a0", Int 1)), Ret (Var { label = "x"; index = 0 })), m
    , Bnd ("x", Cmd (Ret (Int 1)), Ret (Var { label = "x"; index = 0 })), m' )
    (* 34.3f *)
  ; let memory = Hashtbl.create 4 in
    let () = Hashtbl.add memory "a0" (Int 0) in
    ( Get "a0", memory, Ret (Int 0), memory )
    (* 34.3g *)
  ; ( Set ("a0", App (id_fun, Int 1)), memory
    , Set ("a0", Int 1), memory )
    (* 34.3h *)
  ; let m = Hashtbl.create 4 in
    let () = Hashtbl.add m "a0" (Int 0) in
    let m' = Hashtbl.create 4 in
    let () = Hashtbl.add m' "a0" (Int 1) in
    ( Set ("a0", Int 1), m
    , Ret (Int 1), m' )
    (* 34.3i *)
  ; ( Dcl ("a", App (id_fun, Int 0), Get "a"), memory
    , Dcl ("a", Int 0, Get "a"), memory )
    (* 34.3j step modifies memory *)
  ; ( let memory = Hashtbl.create 4 in
      let () = Hashtbl.add memory "a2" (Int 2) in
      Dcl ("a", Int 0, Bnd ("x", Cmd (Set ("a2", Int 4)), Get "a")), memory
    , let memory = Hashtbl.create 4 in
      let () = Hashtbl.add memory "a2" (Int 4) in
      Dcl ("a", Int 0, Bnd ("x", Cmd (Ret (Int 4)), Get "a")), memory )
    (* step modifies memory assignable points to *)
  ; ( let memory = Hashtbl.create 4 in
      Dcl ("a", Int 0, Bnd ("x", Cmd (Set ("a", Int 4)), Get "a")), memory
    , let memory = Hashtbl.create 4 in
      Dcl ("a", Int 4, Bnd ("x", Cmd (Ret (Int 4)), Get "a")), memory )
    (* 34.3k *)
  ; ( Dcl ("a", Int 0, Ret (Int 1)), memory
    , Ret (Int 1), memory )
  ];;


let () = run_test_tt_main ("dynamics" >:::
  [ "exp values" >::: exp_value_tests
  ; "exp step" >::: exp_step_tests
  ; "cmd final state" >: cmd_final_state_test
  ; "state step" >::: state_step_tests
  ]);;
