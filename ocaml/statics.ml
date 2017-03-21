open Result;;
open Ast;;




let ctx_of_list xs = 
  let ctx = Hashtbl.create 32 in
  let () = List.iter (fun (v, t) -> Hashtbl.add ctx v t) xs in
  ctx;;


let string_of_ctx ctx = "";;


let type_check ctx exp = Ok IntTyp;;

