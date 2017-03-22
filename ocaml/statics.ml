open Result;;
open Ast;;




let ctx_of_list xs = 
  let ctx = Hashtbl.create 32 in
  let () = List.iter (fun (v, t) -> Hashtbl.add ctx v t) xs in
  ctx;;

let asg_of_list xs = 
  let ctx = Hashtbl.create 32 in
  let () = List.iter (fun (v, t) -> Hashtbl.add ctx v t) xs in
  ctx;;


let string_of_ctx ctx = "";;


let type_check ctx asg = 
  let rec tc_exp i e =
    match e with
    | Int i -> Ok IntTyp
    | Var v ->
        (try
          Ok (Hashtbl.find ctx v.index)
        with Not_found ->
          Error v.label)
    | Fix (x, t, e) ->
        let () = Hashtbl.add ctx i t in
        (match tc_exp (i + 1) e with
        | Ok t0 ->
            let () = Hashtbl.remove ctx i in
            Ok t0
        | e -> e)
    | Abs (x, t, e0) ->
        let () = Hashtbl.add ctx i t in
        (match tc_exp (i + 1) e0 with
        | Ok t0 when t0 = t ->
            let () = Hashtbl.remove ctx i in
            Ok t
        | Ok t0 -> Error (string_of_typ t0)
        | e -> e)
    | App (e0, e1) ->
        let r0 = tc_exp i e0 in
        (match r0 with
        | Ok (FunTyp (t0a, t0b)) ->
            (match tc_exp i e1 with
            | Ok t1 when t0a = t1 -> Ok t0b
            | Ok t1 -> Error (string_of_typ t1)
            | e -> e)
        | Ok t0 -> Error (string_of_typ t0)
        | e -> e)
    | Cmd m -> tc_cmd i m
  and tc_cmd i m =
    match m with
    | Ret e ->
        (match tc_exp i e with
        | Ok IntTyp -> Ok CmdTyp
        | Ok t -> Error (string_of_typ t)
        | e -> e)
    | _ -> Error "TODO"
  in tc_cmd 0
;;

