(* ========================================================================= *)
(* OBJECT STORE                                                              *)
(* Copyright (c) 2011 Joe Leslie-Hurd, distributed under the MIT license     *)
(* ========================================================================= *)

signature ObjectStore =
sig

(* ------------------------------------------------------------------------- *)
(* A type of object stores.                                                  *)
(* ------------------------------------------------------------------------- *)

type store

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

val new : {filter : ObjectData.data -> bool} -> store

val emptyDictionary : store

val emptyTermBuilder : store

(* ------------------------------------------------------------------------- *)
(* Adding objects.                                                           *)
(* ------------------------------------------------------------------------- *)

val add : store -> Object.object -> store

val addList : store -> Object.object list -> store

(* ------------------------------------------------------------------------- *)
(* Looking up objects.                                                       *)
(* ------------------------------------------------------------------------- *)

val peek : store -> ObjectData.data -> Object.object option

val get : store -> ObjectData.data -> Object.object

(* ------------------------------------------------------------------------- *)
(* Using the store to construct objects.                                     *)
(* ------------------------------------------------------------------------- *)

val build : ObjectData.data -> store -> Object.object * store

(* ------------------------------------------------------------------------- *)
(* Iterating over objects in the store.                                      *)
(* ------------------------------------------------------------------------- *)

val fold : (Object.object * 's -> 's) -> 's -> store -> 's

(* ------------------------------------------------------------------------- *)
(* Pretty-printing.                                                          *)
(* ------------------------------------------------------------------------- *)

val pp : store Print.pp

end
