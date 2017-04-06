open OUnit2;;
open ClosureConversion;;
open Typ;;

module T = TypedAst;;
module F = FlatAst;;



let transform_tests = List.map (fun (exp, ans) ->
  let vs = "test" in
  let res = transform [] exp in
  let m = "TODO" in
  vs >:: (fun _ -> assert_equal ~msg:m ans res))
  [ (T.Abs ("x", IntTyp,
      T.Abs ("y", IntTyp,
        T.Op (Add,
          [ T.Var ({ label = "x"; index = 1 }, IntTyp)
          ; T.Var ({ label = "y"; index = 0 }, IntTyp) ],
          IntTyp)
       , FunTyp (IntTyp, IntTyp))
      , FunTyp (IntTyp, FunTyp (IntTyp, IntTyp)))
    , (F.Call 0
      , [ { F.var = "x"
          ; F.arg = IntTyp
          ; F.env = []
          ; F.body = F.Call 1
          ; F.t = FunTyp (IntTyp, FunTyp (IntTyp, IntTyp))
          }
        ; { F.var = "y"
          ; F.arg = IntTyp
          ; F.env = [("x", IntTyp)]
          ; F.body = 
            F.Op (Add,
              [ F.Var ({ label = "x"; index = 1 }, IntTyp)
              ; F.Var ({ label = "y"; index = 0 }, IntTyp) ],
              IntTyp)
          ; t = FunTyp (IntTyp, IntTyp)
          }
        ]
      )
    )
  ];;


let () = run_test_tt_main ("closure conversion" >:::
  [ "exp" >::: transform_tests
  ]);;
