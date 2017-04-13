open OUnit2;;
open ParseAst;;
open Utils;;
open Typ;;


let typ_tests = List.map (fun (arg, ans) ->
  arg >:: fun _ ->
    let tkns = AstLexer.lex arg in
    let rpn = AstParser.shunt_typ tkns in
    let res = AstParser.parse_typ tkns in
    let m = string_of_typ res ^ "<>" ^ string_of_typ ans ^ "|" ^ intercalate "," rpn in
    assert_equal ~msg:m ans res)
  [ ("int", IntTyp)
  ; ("cmd", CmdTyp)
  ; ("((cmd))", CmdTyp)
  ; ("int -> int", FunTyp (IntTyp, IntTyp))
  ; ("int->int", FunTyp (IntTyp, IntTyp))
  ; ("(((int)->((int))))", FunTyp (IntTyp, IntTyp))
  ; ("int->cmd", FunTyp (IntTyp, CmdTyp))
  ; ("int->int->cmd", FunTyp (IntTyp, FunTyp (IntTyp, CmdTyp)))
  ; ("int->(int->cmd)", FunTyp (IntTyp, FunTyp (IntTyp, CmdTyp)))
  ; ("(int->int)->cmd", FunTyp (FunTyp (IntTyp, IntTyp), CmdTyp))
  ; ("int->(int->cmd)->(int->cmd)", FunTyp (IntTyp, FunTyp (FunTyp (IntTyp, CmdTyp), FunTyp (IntTyp, CmdTyp))))
  ];;


let cmd_tests = List.map (fun (arg, ans) ->
  arg >:: fun _ ->
    let res = AstParser.parse (AstLexer.lex arg) in
    let m = string_of_cmd res ^ "<>" ^ string_of_cmd ans in
    assert_equal ~msg:m ans res)
  [ ("ret 0", Ret (Int 0))
  ; ("ret x", Ret (Var "x"))
  ; ("bnd x<-0; ret x", Bnd ("x", Int 0, (Ret (Var "x"))))
  ; ("bnd x<-cmd bnd y<-0; ret y; ret x", Bnd ("x", Cmd (Bnd ("y", Int 0, Ret (Var "y"))), Ret (Var "x")))
  ; ("a:=1", Set ("a", Int 1))
  ; ("@a", Get "a")
  ; ("dcl a:=1 in @a", Dcl ("a", Int 1, Get "a"))
  ; ("ret fix x:int is 0", Ret (Fix ("x", IntTyp, Int 0)))
  ; ("ret \\x:int.x", Ret (Abs ("x", IntTyp, Var "x")))
  ; ("ret (\\x:int.x)(0)", Ret (App (Abs ("x", IntTyp, Var "x"), Int 0)))
  ; ("ret cmd ret 0", Ret (Cmd (Ret (Int 0))))
  ; ("ret case x of | 0 -> 0 | x -> x", Ret (Case (Var "x", [(Lit 0, Int 0); (Binder "x", Var "x")])))
  ; ("ret (w x y z)", Ret (App (App (App (Var "w", Var "x"), Var "y"), Var "z")))
  ; ("ret 0*0", Ret (Op (Mult, [Int 0; Int 0])))
  ; ("ret 1/0", Ret (Op (Div, [Int 1; Int 0])))
  ; ("ret -0", Ret (Op (Neg, [Int 0])))
  ; ("ret 10-1", Ret (Op (Sub, [Int 10; Int 1])))
  ; ("ret 10+1", Ret (Op (Add, [Int 10; Int 1])))
  ; ("ret 10%1", Ret (Op (Mod, [Int 10; Int 1])))
  ; ("ret 10**1", Ret (Op (Pow, [Int 10; Int 1])))
  ; ("ret 10**1*3", Ret (Op (Mult, [Op (Pow, [Int 10; Int 1]); Int 3])))
  ; ("ret 3-4/2", Ret (Op (Sub, [Int 3; Op (Div, [Int 4; Int 2])])))
  ; ("ret 3*2+-4", Ret (Op (Add, [Op (Mult, [Int 3; Int 2]); Op (Neg, [Int 4])])))
  ; ("ret 3+2-1", Ret (Op (Sub, [Op (Add, [Int 3; Int 2]); Int 1])))
  ; ("ret 3*2/1", Ret (Op (Div, [Op (Mult, [Int 3; Int 2]); Int 1])))
  ; ("ret 3**2**1", Ret (Op (Pow, [Op (Pow, [Int 3; Int 2]); Int 1])))
  ];;


let () = run_test_tt_main ("parser" >::: ["types" >::: typ_tests; "cmds & exps" >::: cmd_tests]);;
