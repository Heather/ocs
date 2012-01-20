open Printf
open Ocs_env
open Ocs_types

let print_sval v =
  let port = Ocs_port.output_port Pervasives.stdout in
  Ocs_print.print port false v;
  Ocs_port.flush port;
  print_endline "\n"
let test () =
  let env = Ocs_top.make_env () in
  let thread = Ocs_top.make_thread () in
  let run_test v =
    print_endline "call run_test from ocaml";
    print_sval v;
    Sstring "string from ocaml:run_test\n"
  in
  let handler v =
    print_endline "call handler from ocaml";
    print_sval v
  in
  let code =
    let sval = (Ocs_read.read_from_string "(display (run-fun))") in
    print_endline "create-dynmic-code:";
    print_sval sval;
    Ocs_compile.compile env sval
  in
  print_endline "set bindings";
  Ocs_env.set_pf1 env run_test "run-test";
  print_endline "load make.scm";
  Ocs_prim.load_file env thread "make.scm";
  print_endline "load fun.scm";
  Ocs_prim.load_file env thread "fun.scm";
  print_endline "run dynamic-code";
  Ocs_eval.eval thread handler code;
  print_endline "Test done succesfull"
let _ =
  print_endline "Run test...";
  test ()
