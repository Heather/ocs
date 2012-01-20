open Printf
open Ocs_env
open Ocs_types

let _ =
  let env = Ocs_top.make_env () in
  let thread = Ocs_top.make_thread () in
  print_endline "Runing make...";
  Ocs_prim.load_file env thread "make.scm"