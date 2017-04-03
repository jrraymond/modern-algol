open Result;;
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


let rec type_exp ctx asg e = 
  match e with
  | Ast.Int i -> Ok (TypedAst.Int i)
  | Ast.Var v ->
      (match get_from_ctx v.label ctx v.index with
      | Ok t -> Ok (TypedAst.Var (v, t))
      | Error e -> Error e)
  | Ast.Fix (x, t, e0) ->
      let ctx' = add_to_ctx ctx t in
      (match type_exp ctx' asg e0 with
      | Ok te0 ->
          let t0 = TypedAst.typ_of_exp te0 in
          Ok (TypedAst.Fix (x, t, te0, t0))
      | e -> e)
  | Ast.Abs (x, t, e0) ->
      let ctx' = add_to_ctx ctx t in
      (match type_exp ctx' asg e0 with
      | Ok te0 ->
          let t0 = TypedAst.typ_of_exp te0 in
          Ok (TypedAst.Abs (x, t, te0, FunTyp (t, t0)))
      | e -> e)
  | Ast.App (e0, e1) ->
      (match type_exp ctx asg e0 with
      | Error e -> Error e
      | Ok te0 ->
        (match TypedAst.typ_of_exp te0 with
        | FunTyp (t0a, t0b) as t0 ->
            (match type_exp ctx asg e1 with
            | Ok te1 ->
                let t1 = TypedAst.typ_of_exp te1 in
                if t0 = t1
                then Ok (TypedAst.App (te0, te1, t0b))
                else Error (string_of_typ t1 ^ "<>" ^ string_of_typ t0a)
            | e -> e)
        | t0 -> Error ("expected function, found " ^ string_of_typ t0)))
  | Ast.Cmd m ->
      (match type_cmd ctx asg m with
      | Ok tm ->
          let t = TypedAst.typ_of_cmd tm in
          Ok (TypedAst.Cmd (tm, t))
      | Error e -> Error e)
  | Ast.Case (e0, cs) ->
      (match type_exp ctx asg e0 with
      | Error e -> Error e
      | Ok te0 ->
          let t0 = TypedAst.typ_of_exp te0 in
          (match type_cases t0 ctx asg cs with
          | Ok (t, tcs) -> Ok (TypedAst.Case (te0, tcs, t))
          | Error e -> Error e))
and type_cases t ctx asg =
  let rec tcc_h mt ts cs =
    match cs with
    | [] ->
        (match mt with
        | None -> raise (Failure "empty case")
        | Some t -> Ok (t, List.rev ts))
    | (p, e)::cs' -> 
        let ctx' = 
          match p with
          | Lit i -> ctx
          | Binder x -> t::ctx
        in
        (match mt, type_exp ctx' asg e with
        | None, Ok te1 ->
            let t1 = TypedAst.typ_of_exp te1 in
            tcc_h (Some t1) ((p, te1)::ts) cs'
        | Some t0, Ok te1 -> 
            let t1 = TypedAst.typ_of_exp te1 in
            if t0 = t1
            then tcc_h mt ((p, te1)::ts) cs'
            else 
              let t0s = string_of_typ t0 in
              let t1s = string_of_typ t1 in
              let e = Printf.sprintf "expected %s, found %s" t0s t1s in
              Error e
        | _, Error e -> Error e)
  in tcc_h None []
and type_cmd ctx asg m =
  match m with
  | Ast.Ret e ->
      (match type_exp ctx asg e with
      | Ok te -> 
          (match TypedAst.typ_of_exp te with
          | IntTyp -> Ok (TypedAst.Ret (te, IntTyp))
          | t -> Error (string_of_typ t))
      | Error e -> Error e)
  | Ast.Bnd (x, e, m0) ->
      (match type_exp ctx asg e with
      | Ok te ->
          (match TypedAst.typ_of_exp te with
          | CmdTyp ->
            let ctx' = add_to_ctx ctx IntTyp in
            (match type_cmd ctx' asg m0 with
            | Ok tm0 ->
                let t0 = TypedAst.typ_of_cmd tm0 in
                Ok (TypedAst.Bnd (x, te, tm0, t0))
            | Error e -> Error e)
          | t ->
            Error ("expected Cmd, found " ^ string_of_typ t))
      | Error e -> Error e)
  | Ast.BndT _ -> raise (Failure "toplevel")
  | Ast.DclT _ -> raise (Failure "toplevel")
  | Ast.Dcl (a, e, m0) ->
      (match type_exp ctx asg e with
      | Ok te -> 
          let t = TypedAst.typ_of_exp te in
          if t <> IntTyp
          then Error ("expected IntTyp, got " ^ string_of_typ t)
          else
            let () = Hashtbl.add asg a IntTyp in
            (match type_cmd ctx asg m0 with
            | Ok tm0 ->
                let t0 = TypedAst.typ_of_cmd tm0 in
                if t0 <> CmdTyp
                then Error ("expected CmdTyp, got " ^ string_of_typ t0)
                else
                  let () = Hashtbl.remove asg a in
                  Ok (TypedAst.Dcl (a, te, tm0, t0))
            | e -> e)
      | Error e -> Error e)
  | Ast.Get x ->
      (try
        let t = Hashtbl.find asg x in
        Ok (TypedAst.Get (x, t))
      with Not_found ->
        Error ("Assignable " ^ x ^ " not in scope"))
  | Ast.Set (x, e) ->
      if Hashtbl.mem asg x
      then 
        (match type_exp ctx asg e with
        | Ok te -> 
            let t = TypedAst.typ_of_exp te in
            if t = IntTyp
            then Ok (TypedAst.Set (x, te, CmdTyp))
            else Error ("expected IntTyp, got " ^ string_of_typ t)
        | Error e -> Error e)
      else Error ("Assignable " ^ x ^ " not in scope");;


let type_toplevel ctx asg m =
  match m with
  | Ast.BndT (x, e) ->
      (match type_exp ctx asg e with
      | Ok te ->
          let t = TypedAst.typ_of_exp te in
          Ok (t, t::ctx)
      | Error e -> Error e)
  | Ast.DclT (a, e) -> 
      (match type_exp ctx asg e with
      | Ok te ->
          let t = TypedAst.typ_of_exp te in
          if t <> CmdTyp
          then Error ("expected CmdTyp, got " ^ string_of_typ t)
          else
            let () = Hashtbl.add asg a t in
            Ok (CmdTyp, ctx)
      | Error e -> Error e)
  |  _ ->
      (match type_cmd ctx asg m with
      | Ok tm ->
          let t = TypedAst.typ_of_cmd tm in
          Ok (t, ctx)
      | Error e -> Error e);;
