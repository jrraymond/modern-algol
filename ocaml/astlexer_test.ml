open OUnit2;;
open Utils;;
open AstLexer;;


let lexer = List.map (fun (arg, ans) ->
  arg >:: fun _ ->
    let res = lex arg in
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
  ; ("0**0", ["0"; "**"; "0"])
  ; ("0/0", ["0"; "/"; "0"])
  ; ("0-0", ["0"; "-"; "0"])
  ; ("0+0", ["0"; "+"; "0"])
  ; ("0%0", ["0"; "%"; "0"])
  ; ("0^0", ["0"; "^"; "0"])
  ; ("case x of | _ -> 1", ["case";"x";"of";"|";"_";"->";"1"])
  ];;


 

let () = run_test_tt_main ("lexer" >::: lexer);;
