open Printf
open Ocs_env
open Ocs_types

let print_sval v =
  let port = Ocs_port.output_port Pervasives.stdout in
  Ocs_print.print port false v;
  Ocs_port.flush port;
  print_endline "\n"
let _ =
  let thread = Ocs_top.make_thread () in
  let handler v = print_sval v in
  let code =
    let sval = (Ocs_read.read_from_string "
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		(system \"make\")
		(system \"pause\")
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		") in
	let env = Ocs_top.make_env () in
    Ocs_compile.compile env sval
  in
  print_endline "Runing make...";
  Ocs_eval.eval thread handler code