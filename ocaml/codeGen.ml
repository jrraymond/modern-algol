open FlatAst;;
open Typ;;


let llctx = Llvm.global_context ();;
let i32_t = Llvm.i32_type llctx;;
let void_t = Llvm.void_type llctx;;


let mk_typ t =
  match t with
  | IntTyp -> i32_t
  | CmdTyp -> void_t
  | _ -> raise (Failure ("Unsupported type " ^ string_of_typ t));;


let rec gen_exp llm e builder =
  match e with
  | Int i -> Llvm.const_int i32_t i
  | UnOp (Neg, e0, IntTyp) ->
      let c0 = gen_exp llm e0 builder in
      let z = Llvm.const_int i32_t 0 in
      Llvm.build_sub z c0 "negtmp" builder
  | BinOp (op, e0, e1, IntTyp) ->
      let lhs = gen_exp llm e0 builder in
      let rhs = gen_exp llm e1 builder in
      (match op with
      | Add -> Llvm.build_add lhs rhs "addtmp" builder
      | Sub -> Llvm.build_sub lhs rhs "addtmp" builder
      | Mult -> Llvm.build_mul lhs rhs "addtmp" builder
      | Div -> Llvm.build_sdiv lhs rhs "addtmp" builder
      | Pow -> raise (Failure "pow unimplemented"))
  | App (Fun f, e1, t) ->
      let callee = 
        match Llvm.lookup_function f llm with
        | Some c -> c
        | None -> raise (Failure ("unknown function " ^ f))
      in
      let args = Array.make 1 (gen_exp llm e1 builder) in
      Llvm.build_call callee args "calltmp" builder
  | App (e0, e1, t) ->
      let lhs = gen_exp llm e0 builder in
      let rhs = gen_exp llm e1 builder in
      raise (Failure ("first class functions unimplemented"))
  | _ -> raise (Failure "unimplemented")
and gen_cmd llm m =
  match m with
  | _ -> raise (Failure "unimplemented");;


let code_gen_exp e = 
  let llm = Llvm.create_module llctx "main" in
  let fty = Llvm.function_type i32_t [| |] in
  let f = Llvm.define_function "main" fty llm in
  let builder = Llvm.builder_at_end llctx (Llvm.entry_block f) in
  let v = gen_exp llm e builder in
  llm;;
