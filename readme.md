General
=======

[![Build Status](https://travis-ci.org/Heather/ocs.png?branch=master)](https://travis-ci.org/Heather/ocs)

Ocs is an implementation of Scheme, as defined by R5RS.  It is
written entirely in OCaml and can be trivially embedded in any
OCaml program.

Known deviations from R5RS:

 - transcript-on and transcript-off are currently not implemented
 - scheme-report-environment and null-environment ignore their
   argument

Anything else that does not work as specified in R5RS is a bug.

Installation
============

Requirements:

 - GNU make or pmake (BSD make)
 - OCaml 3.x (versions 3.06 and newer tested)

Type make or gmake in the src directory.  This should produce the
following:

 - A bytecode library (ocs.cma)
 - A native library (ocs.cmxa, ocs.a)
 - A stand-alone, native interpreter (ocscm)

The 'ocscm' command
===================

If invoked without arguments, the interpreter will run in interactive
mode.

If invoked with arguments, the interpreter will read and evaluate
the files listed as arguments and exit.  The evaluation results are
not printed.


Implementation Details
======================

Implementing Scheme in OCaml is so straightforward that it hardly
needs any documentation.  The following mappings between languages
are done:

 - Scheme is dynamically typed.  Scheme values are represented by
the OCaml type Ocs_types.sval.

 - In Scheme, top-level bindings are global and all variables are
mutable.  Variables references are bound through environments
(Ocs_types.env) to global slots (Ocs_types.gvar) or frame indices
(the actual frames are visible at evaluation-time through
Ocs_types.thread).

 - Scheme has capturable, first-class continuations.  Most of the
evaluator is written in continuation-passing style in order to allow
this.

Where discussing types, the rest of this section assumes that the
types defined in the module Ocs_types are visible.

Evaluation
==========

Scheme values (S-expressions) are of the type sval.

Before evaluation Scheme values are compiled to internal representations
of the type code.  This is done by the function

  Ocs_compile.compile : env -> sval -> code

The env type is used during compilation for variable bindings.  A
new env is created for each new scope and frame.  The base
environment with the basic language bindings can be created using

  Ocs_top.make_env : unit -> env

Evaluation is done by

  Ocs_eval.eval : thread -> (sval -> unit) -> code -> unit

where the second argument is a continuation to pass the result to.

The thread type is used during evaluation for storing the current
frame and display for local variables, the input/output ports and
the current dynamic extent.  It does not represent a thread in the
concurrent sense, but rather the evaluation state, and is copied and
changed rather than modified in place.  The initial thread to be
passed to the evaluator can be created using
Ocs_top.make_thread : unit -> thread.

Continuations and I/O
=====================

Any continuations captured are associated with the thread at the
time of capture, so if a continuation is used to escape a
with-input-from-file or with-output-to-file, the input/output port
is restored to those of the time of capture.

If a continuation is used to return to a with-input-from-file or
with-output-to-file, the port is once again set to the one
opened by the with-...-file call.  However, if the thunk has
already exited once, the port will be closed and no longer be
valid for I/O calls.

Numbers
=======

The full R5RS numeric tower is implemented, with the following
internal representations:

Exact numbers are
  - 31- or 63-bit integers (OCaml int)
  - Big_int objects from the Num library when unboxed integers are
    too small
  - Ratio objects from the Num library for rationals

Inexact numbers are
  - 64-bit IEEE floats for reals (OCaml float)
  - Pairs of 64-bit IEEE floats for complex numbers (OCaml Complex.t)

Since inexact numbers are represented internally as binary floating
point, conversions to exact numbers are most precise for fractions of
powers of two

```scheme
  (inexact->exact 2.125) ==> 17/8
```

compared to

```scheme
  (inexact->exact 0.3) ==> 5404319552844595/18014398509481984
```

And in fact many rationals will not satisfy

```scheme
  (= (inexact->exact (exact->inexact r)) r)
```

However

```scheme
  (rationalize (inexact->exact 0.3) (expt 2 -54)) ==> 3/10
```

Embedded
========

```ocaml
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
  print_endline "load hello.scm";
  Ocs_prim.load_file env thread "hello.scm";
  print_endline "load fun.scm";
  Ocs_prim.load_file env thread "fun.scm";
  print_endline "run dynamic-code";
  Ocs_eval.eval thread handler code;
  print_endline "Test done succesfull"
let _ =
  print_endline "Run test...";
  test ()
```

