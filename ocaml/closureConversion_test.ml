open OUnit2;;
open ClosureConversion;;
open Typ;;

module T = TypedAst;;
module F = FlatAst;;


(* TODO this should be more robust *)
let cmp_transform a b = a = b;;


let string_of_ans (exp, defs) =
  let es = F.string_of_exp exp in
  let ds = List.map F.string_of_def defs |> Utils.intercalate "," in
  Printf.sprintf "%s || %s" es ds;;


let transform_tests = List.map (fun (exp0, ans) ->
  let vs = T.string_of_exp exp0 in
  let res = transform [] exp0 in
  let m = string_of_ans res ^ "<>" ^ string_of_ans ans in
  vs >:: (fun _ -> assert_equal ~cmp:cmp_transform ~msg:m ans res))
  [ (T.Abs ("x", IntTyp,
      T.Abs ("y", IntTyp,
        T.Op (Add,
          [ T.Var ({ label = "x"; index = 1 }, IntTyp)
          ; T.Var ({ label = "y"; index = 0 }, IntTyp) ],
          IntTyp)
       , FunTyp (IntTyp, IntTyp))
      , FunTyp (IntTyp, FunTyp (IntTyp, IntTyp)))
    , (F.Fun 0
      , [ { F.var = "x"
          ; F.argt = IntTyp
          ; F.env = []
          ; F.body = F.Fun 1
          ; F.typ = FunTyp (IntTyp, FunTyp (IntTyp, IntTyp))
          }
        ; { F.var = "y"
          ; F.argt = IntTyp
          ; F.env = [("x", IntTyp)]
          ; F.body = 
            F.Op (Add,
              [ F.Var ({ label = "x"; index = 1 }, IntTyp)
              ; F.Var ({ label = "y"; index = 0 }, IntTyp) ],
              IntTyp)
          ; typ = FunTyp (IntTyp, IntTyp)
          }
        ]
      )
    )
  ];;


let () = run_test_tt_main ("closure conversion" >:::
  [ "exp" >::: transform_tests
  ]);;
