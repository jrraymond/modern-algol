open OUnit2;;


let rec intercalate sep xs =
  match xs with
  | [] -> ""
  | [x] -> x
  | x::xs' -> x ^ sep ^ intercalate sep xs';;


let lexer = List.map (fun (arg, ans) ->
  arg >:: fun _ ->
    let res = Lexer.lex arg in
    let m = intercalate "," res ^ "<>" ^ intercalate "," ans in
    assert_equal ~msg:m ans res)
  [ ("int -> int", ["int"; "->"; "int"])
  ; ("int->int", ["int"; "->"; "int"])
  ; ("fix x : int is 0", ["fix"; "x"; ":"; "int"; "is"; "0"])
  ; ("fix x:int is 0", ["fix"; "x"; ":"; "int"; "is"; "0"])
  ; ("\\ x : int . 1", ["\\"; "x"; ":"; "int"; "."; "1"])
  ; ("\\x:int.1", ["\\"; "x"; ":"; "int"; "."; "1"])
  ; ("x ( y )", ["x"; "("; "y"; ")"])
  ; ("x(y)", ["x"; "("; "y"; ")"])
  ; ("cmd m", ["cmd"; "m"])
  ; ("ret 0", ["ret"; "0"])
  ; ("bnd x <- e ; m", ["bnd"; "x"; "<-"; "e"; ";"; "m"])
  ; ("bnd x<-e;m", ["bnd"; "x"; "<-"; "e"; ";"; "m"])
  ; ("dcl a := 0 in m", ["dcl"; "a"; ":="; "0"; "in"; "m"])
  ; ("dcl a:=0 in m", ["dcl"; "a"; ":="; "0"; "in"; "m"])
  ; ("@ a", ["@"; "a"])
  ; ("@a", ["@"; "a"])
  ; ("a := e", ["a"; ":="; "e"])
  ; ("a:=e", ["a"; ":="; "e"])
  ; ("0*0", ["0"; "*"; "0"])
  ; ("0/0", ["0"; "/"; "0"])
  ; ("0-0", ["0"; "-"; "0"])
  ; ("0+0", ["0"; "+"; "0"])
  ; ("0%0", ["0"; "%"; "0"])
  ];;


 

let () = run_test_tt_main ("lexer" >::: lexer);;
