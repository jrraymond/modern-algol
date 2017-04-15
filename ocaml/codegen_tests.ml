open OUnit2;;
open CodeGen;;
open Typ;;
open FlatAst;;

let exp_tests = List.map (fun exp ->
  let vs = string_of_exp exp in
  let res = code_gen_exp exp in
  let () = Llvm.dump_module res in
  vs >:: (fun _ -> assert_equal 0 0))
  [ Int 0
  ; UnOp (Neg, Int 1, IntTyp)
  ; BinOp (Add, Int 1, Int 2, IntTyp)
  ; BinOp (Sub, Int 1, Int 2, IntTyp)
  ; BinOp (Mult, Int 1, Int 2, IntTyp)
  ; BinOp (Div, Int 1, Int 2, IntTyp)
  ];;


let cmd_tests = [];;

let () = run_test_tt_main ("code gen" >:::
  [ "exp" >::: exp_tests
  ; "cmd" >::: cmd_tests
  ]);;
