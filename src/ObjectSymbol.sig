(* ========================================================================= *)
(* SYMBOL OBJECTS                                                            *)
(* Copyright (c) 2011 Joe Leslie-Hurd, distributed under the MIT license     *)
(* ========================================================================= *)

signature ObjectSymbol =
sig

(* ------------------------------------------------------------------------- *)
(* A type of symbol objects.                                                 *)
(* ------------------------------------------------------------------------- *)

type symbol

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

val empty : symbol

(* ------------------------------------------------------------------------- *)
(* Looking up symbols.                                                       *)
(* ------------------------------------------------------------------------- *)

val peekTypeOp : symbol -> TypeOp.typeOp -> Object.object option

val peekConst : symbol -> Const.const -> Object.object option

val peekSymbol : symbol -> Symbol.symbol -> Object.object option

(* ------------------------------------------------------------------------- *)
(* Harvesting symbols from objects (and their provenances).                  *)
(* ------------------------------------------------------------------------- *)

val addObject : symbol -> Object.object -> symbol

(* ------------------------------------------------------------------------- *)
(* Iterating over symbol objects.                                            *)
(* ------------------------------------------------------------------------- *)

val fold : (Object.object * 's -> 's) -> 's -> symbol -> 's

end
