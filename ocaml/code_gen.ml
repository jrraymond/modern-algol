open Ast;;

let () = 
  let llctx = Llvm.global_context () in
  let llm = Llvm.create_module llctx "m0" in
  let i32_t = Llvm.i32_type llctx in
  let fty = Llvm.function_type i32_t [| |] in
  let f = Llvm.define_function "main" fty llm in
  let llbuilder = Llvm.builder_at_end llctx (Llvm.entry_block f) in
  let _ = Llvm.build_ret (Llvm.const_int i32_t 0) llbuilder in
  Llvm.dump_module llm;
  ();;
