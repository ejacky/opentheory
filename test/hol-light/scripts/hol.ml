(* ========================================================================= *)
(*                               HOL LIGHT                                   *)
(*                                                                           *)
(*              Modern OCaml version of the HOL theorem prover               *)
(*                                                                           *)
(*                            John Harrison                                  *)
(*                                                                           *)
(*            (c) Copyright, University of Cambridge 1998                    *)
(*              (c) Copyright, John Harrison 1998-2007                       *)
(* ========================================================================= *)

let hol_version = "2.20++";;

let hol_dir = ref
  (try Sys.getenv "HOLLIGHT_DIR" with Not_found -> Sys.getcwd());;

(* ------------------------------------------------------------------------- *)
(* Should eventually change to "ref(Filename.temp_dir_name)".                *)
(* However that's not available in 3.08, which is still the default          *)
(* in Cygwin, and I don't want to force people to upgrade Ocaml.             *)
(* ------------------------------------------------------------------------- *)

let temp_path = ref "/tmp";;

(* ------------------------------------------------------------------------- *)
(* Load in parsing extensions.                                               *)
(* For Ocaml < 3.10, use the built-in camlp4                                 *)
(* and for Ocaml >= 3.10, use camlp5 instead.                                *)
(* ------------------------------------------------------------------------- *)

if let v = String.sub Sys.ocaml_version 0 4 in
   v = "3.10" or v = "3.11"
then (Topdirs.dir_directory "+camlp5";
      Topdirs.dir_load Format.std_formatter "camlp5o.cma")
else (Topdirs.dir_load Format.std_formatter "camlp4o.cma");;

Topdirs.dir_load Format.std_formatter (Filename.concat (!hol_dir) "pa_j.cmo");;

(* ------------------------------------------------------------------------- *)
(* Load files from system and/or user-settable directories.                  *)
(* ------------------------------------------------------------------------- *)

let use_file s =
  if Toploop.use_file Format.std_formatter s then ()
  else (Format.print_string("Error in included file "^s);
        Format.print_newline());;

let load_path = ref ["."; !hol_dir];;

let loaded_files = ref [];;

let file_on_path p s =
  if not (Filename.is_relative s) then s else
  let d = List.find (fun d -> Sys.file_exists(Filename.concat d s)) p in
  Filename.concat (if d = "." then Sys.getcwd() else d) s;;

let load_on_path p s =
  let s' = file_on_path p s in
  let d = Digest.file s' in
  (use_file s'; loaded_files := (s',d)::(!loaded_files));;

let loads s = load_on_path [!hol_dir] s;;

let loadt s = load_on_path (!load_path) s;;

let needs s =
  let s' = file_on_path (!load_path) s in
  let d = Digest.file s' in
  if try List.assoc s' (!loaded_files) = d with Not_found -> false
  then Format.print_string("File \""^s^"\" already loaded\n") else loadt s;;

(* ------------------------------------------------------------------------- *)
(* Various tweaks to OCaml and general library functions.                    *)
(* ------------------------------------------------------------------------- *)

loads "sys.ml";;        (* Set up proper parsing and load bignums            *)
loads "lib.ml";;        (* Various useful general library functions          *)

(* ------------------------------------------------------------------------- *)
(* The logical core.                                                         *)
(* ------------------------------------------------------------------------- *)

#use "fusion.ml";;

(* ------------------------------------------------------------------------- *)
(* OpenTheory proof logging.                                                 *)
(* ------------------------------------------------------------------------- *)

loads "logging.ml";;

(* ------------------------------------------------------------------------- *)
(* OpenTheory loads function to initialize the log files.                    *)
(* ------------------------------------------------------------------------- *)

let loads =
  fun s ->
    logfile (String.sub s 0 (String.rindex s '.') ^ ".art");
    loads s;;

(* ------------------------------------------------------------------------- *)
(* Some extra support stuff needed outside the core.                         *)
(* ------------------------------------------------------------------------- *)

loads "basics.ml";;     (* Additional syntax operations and other utilities  *)
loads "nets.ml";;       (* Term nets for fast matchability-based lookup      *)

(* ------------------------------------------------------------------------- *)
(* The interface.                                                            *)
(* ------------------------------------------------------------------------- *)

loads "preterm.ml";;    (* Preterms and their interconversion with terms     *)
loads "parser.ml";;     (* Lexer and parser                                  *)
loads "printer.ml";;    (* Crude prettyprinter                               *)

(* ------------------------------------------------------------------------- *)
(* Higher level deductive system.                                            *)
(* ------------------------------------------------------------------------- *)

loads "equal.ml";;      (* Basic equality reasoning and conversionals        *)
loads "bool.ml";;       (* Boolean theory and basic derived rules            *)
loads "drule.ml";;      (* Additional derived rules                          *)
loads "tactics.ml";;    (* Tactics, tacticals and goal stack                 *)
loads "itab.ml";;       (* Toy prover for intuitionistic logic               *)
loads "simp.ml";;       (* Basic rewriting and simplification tools.         *)
loads "theorems.ml";;   (* Additional theorems (mainly for quantifiers) etc. *)
loads "ind-defs.ml";;   (* Derived rules for inductive definitions           *)
loads "class.ml";;      (* Classical reasoning: Choice and Extensionality    *)
loads "trivia.ml";;     (* Some very basic theories, e.g. type ":1"          *)
loads "canon.ml";;      (* Tools for putting terms in canonical forms        *)
loads "meson.ml";;      (* First order automation: MESON (model elimination) *)
loads "quot.ml";;       (* Derived rules for defining quotient types         *)
loads "recursion.ml";;  (* Tools for primitive recursion on inductive types  *)

(* This overrides new_definition, so we put it before the logging functions *)
loads "pair.ml";;       (* Theory of pairs                                   *)

(* ------------------------------------------------------------------------- *)
(* OpenTheory proof logging for the higher level deductive system.           *)
(* ------------------------------------------------------------------------- *)

loads "deduction-logging.ml";;

(* ------------------------------------------------------------------------- *)
(* Mathematical theories and additional proof tools.                         *)
(* ------------------------------------------------------------------------- *)

loads "num.ml";;        (* Axiom of Infinity, definition of natural numbers  *)
loads "arith.ml";;      (* Natural number arithmetic                         *)
loads "wf.ml";;         (* Theory of wellfounded relations                   *)
loads "calc_num.ml";;   (* Calculation with natural numbers                  *)
loads "normalizer.ml";; (* Polynomial normalizer for rings and semirings     *)
loads "grobner.ml";;    (* Groebner basis procedure for most semirings.      *)
loads "ind-types.ml";;  (* Tools for defining inductive types                *)
loads "list.ml";;       (* Theory of lists                                   *)
loads "realax.ml";;     (* Definition of real numbers                        *)
loads "calc_int.ml";;   (* Calculation with integer-valued reals             *)
loads "realarith.ml";;  (* Universal linear real decision procedure          *)
loads "real.ml";;       (* Derived properties of reals                       *)
loads "calc_rat.ml";;   (* Calculation with rational-valued reals            *)
loads "int.ml";;        (* Definition of integers                            *)
loads "sets.ml";;       (* Basic set theory.                                 *)
loads "iter.ml";;       (* Iterated operations                               *)
loads "cart.ml";;       (* Finite Cartesian products                         *)
loads "define.ml";;     (* Support for general recursive definitions         *)

(* ------------------------------------------------------------------------- *)
(* The help system.                                                          *)
(* ------------------------------------------------------------------------- *)

loads "help.ml";;       (* Online help using the entries in Help directory   *)
loads "database.ml";;   (* List of name-theorem pairs for search system      *)

(* ------------------------------------------------------------------------- *)
(* OpenTheory order example.                                                 *)
(* ------------------------------------------------------------------------- *)

loads "example-ord-1.ml";;
loads "example-ord-2.ml";;

(* ------------------------------------------------------------------------- *)
(* OpenTheory positive number example.                                       *)
(* ------------------------------------------------------------------------- *)

loads "example-pos-1.ml";;