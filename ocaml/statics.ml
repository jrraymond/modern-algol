open Result;;
open Ast;;
open Typ;;




let ctx_of_list xs = xs;;

let asg_of_list xs = 
  let asg = Hashtbl.create 32 in
  let () = List.iter (fun (v, t) -> Hashtbl.add asg v t) xs in
  asg;;


let string_of_ctx ctx = 
  List.map string_of_typ ctx |>
  Utils.intercalate ",";;


let string_of_asg asg =
  let xs = Hashtbl.fold (fun k v acc ->
    Printf.sprintf "%s:%s" k (string_of_typ v) :: acc)
    asg []
  in Utils.intercalate "," xs;;


let add_to_ctx ctx t = t::ctx;;


let rec get_from_ctx v ctx i =
  match ctx, i with
  | [], _ -> Error (v ^ "not found")
  | x::ctx', 0 -> Ok x
  | x::ctx', i -> get_from_ctx v ctx' (i - 1);;


let rem_from_ctx ctx =
  match ctx with
  | [] -> raise (Failure "empty context")
  | _::ctx' -> ctx'


let rec type_check_exp ctx asg e = 
  match e with
  | Int i -> Ok IntTyp
  | Var v -> get_from_ctx v.label ctx v.index
  | Fix (x, t, e0) ->
      let ctx' = add_to_ctx ctx t in
      type_check_exp ctx' asg e0
  | Abs (x, t, e0) ->
      let ctx' = add_to_ctx ctx t in
      (match type_check_exp ctx' asg e0 with
      | Ok t0 -> Ok (FunTyp (t, t0) )
      | e -> e)
  | App (e0, e1) ->
      let r0 = type_check_exp ctx asg e0 in
      (match r0 with
      | Ok (FunTyp (t0a, t0b)) ->
          (match type_check_exp ctx asg e1 with
          | Ok t1 when t0a = t1 -> Ok t0b
          | Ok t1 -> Error (string_of_typ t1 ^".")
          | e -> e)
      | Ok t0 -> Error ("expected function, found " ^ string_of_typ t0)
      | e -> e)
  | Cmd m ->
      (match type_check_cmd ctx asg m with
      | Ok _ -> Ok CmdTyp
      | Error e -> Error e)
  | Case (e0, cs) ->
      (match type_check_exp ctx asg e0 with
      | Error e -> Error e
      | Ok t -> type_check_cases t ctx asg cs)
and type_check_cases t ctx asg =
  let rec tcc_h mt cs =
    match cs with
    | [] ->
        (match mt with
        | None -> raise (Failure "empty case")
        | Some t -> Ok t)
    | (p, e)::cs' -> 
        let ctx' = 
          match p with
          | Lit i -> ctx
          | Binder x -> t::ctx
        in
        (match mt, type_check_exp ctx' asg e with
        | None, Ok t1 -> tcc_h (Some t1) cs'
        | Some t0, Ok t1 when t0 = t1 -> tcc_h mt cs'
        | Some t0, Ok t1 ->
            let t0s = string_of_typ t0 in
            let t1s = string_of_typ t1 in
            Error (Printf.sprintf "expected %s, found %s" t0s t1s)
        | _, e -> e)
  in tcc_h None
and type_check_cmd ctx asg m =
  match m with
  | Ret e ->
      (match type_check_exp ctx asg e with
      | Ok IntTyp -> Ok CmdTyp
      | Ok t -> Error (string_of_typ t)
      | e -> e)
  | Bnd (x, e, m0) ->
      (match type_check_exp ctx asg e with
      | Ok CmdTyp ->
          let ctx' = add_to_ctx ctx IntTyp in
          type_check_cmd ctx' asg m0
      | Ok t -> Error ("expected Cmd, found " ^ string_of_typ t)
      | e -> e)
  | BndT _ -> raise (Failure "toplevel")
  | DclT _ -> raise (Failure "toplevel")
  | Dcl (a, e, m0) ->
      (match type_check_exp ctx asg e with
      | Ok IntTyp -> 
          let () = Hashtbl.add asg a IntTyp in
          (match type_check_cmd ctx asg m0 with
          | Ok CmdTyp ->
              let () = Hashtbl.remove asg a in
              Ok CmdTyp
          | e -> e)
      | e -> e)
  | Get x ->
      if Hashtbl.mem asg x
      then Ok CmdTyp
      else Error "Assignable x not in scope"
  | Set (x, e) ->
      if Hashtbl.mem asg x
      then 
        (match type_check_exp ctx asg e with
        | Ok IntTyp -> Ok CmdTyp
        | e -> e)
      else Error "Assignable x not in scope";;


let type_check_toplevel ctx asg m =
  match m with
  | BndT (x, e) ->
      (match type_check_exp ctx asg e with
      | Ok t -> Ok (t, t::ctx)
      | Error e -> Error e)
  | DclT (a, e) -> 
      (match type_check_exp ctx asg e with
      | Ok t ->
          let () = Hashtbl.add asg a t in
          Ok (CmdTyp, ctx)
      | Error e -> Error e)
  |  _ ->
      (match type_check_cmd ctx asg m with
      | Ok t -> Ok (t, ctx)
      | Error e -> Error e);;
