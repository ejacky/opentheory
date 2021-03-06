(* ========================================================================= *)
(* EXTRA PACKAGE FILES                                                       *)
(* Copyright (c) 2010 Joe Leslie-Hurd, distributed under the MIT license     *)
(* ========================================================================= *)

signature PackageExtra =
sig

(* ------------------------------------------------------------------------- *)
(* A type of extra package files.                                            *)
(* ------------------------------------------------------------------------- *)

type extra

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

datatype extra' =
    Extra of
      {name : PackageName.name,
       filename : string}

val mk : extra' -> extra

val dest : extra -> extra'

val name : extra -> PackageName.name

val filename : extra -> {filename : string}

(* ------------------------------------------------------------------------- *)
(* Remove the directory from the filename path.                              *)
(* ------------------------------------------------------------------------- *)

val normalize : extra -> extra

end
