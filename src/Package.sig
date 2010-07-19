(* ========================================================================= *)
(* HIGHER ORDER LOGIC THEORY PACKAGE SYNTAX                                  *)
(* Copyright (c) 2009 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

signature Package =
sig

(* ------------------------------------------------------------------------- *)
(* Types of theory package syntax.                                           *)
(* ------------------------------------------------------------------------- *)

type package

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

datatype package' =
    Package' of
      {tags : Tag.tag list,
       theories : PackageTheory.theory list}

val mk : package' -> package

val dest : package -> package'

val tags : package -> Tag.tag list

val theories : package -> PackageTheory.theory list

(* ------------------------------------------------------------------------- *)
(* Package name.                                                             *)
(* ------------------------------------------------------------------------- *)

val base : package -> PackageBase.base

val version : package -> PackageVersion.version

val name : package -> PackageName.name

(* ------------------------------------------------------------------------- *)
(* Article dependencies.                                                     *)
(* ------------------------------------------------------------------------- *)

val articles : package -> {filename : string} list

(* ------------------------------------------------------------------------- *)
(* Package dependencies.                                                     *)
(* ------------------------------------------------------------------------- *)

val packages : package -> PackageName.name list

(* ------------------------------------------------------------------------- *)
(* Extra file dependencies.                                                  *)
(* ------------------------------------------------------------------------- *)

val extraFiles : package -> (string * {filename : string}) list

(* ------------------------------------------------------------------------- *)
(* Pretty printing.                                                          *)
(* ------------------------------------------------------------------------- *)

val pp : package Print.pp

(* ------------------------------------------------------------------------- *)
(* Parsing.                                                                  *)
(* ------------------------------------------------------------------------- *)

val parser : (char,package) Parse.parser

(* ------------------------------------------------------------------------- *)
(* Input/Output.                                                             *)
(* ------------------------------------------------------------------------- *)

val fromTextFile : {filename : string} -> package

val toTextFile : {package : package, filename : string} -> unit

end
