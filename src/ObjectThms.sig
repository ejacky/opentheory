(* ========================================================================= *)
(* SYMBOLS CONTAINED IN A SET OF THEOREM OBJECTS                             *)
(* Copyright (c) 2004 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

signature ObjectThms =
sig

(* ------------------------------------------------------------------------- *)
(* A type of object set theorems.                                            *)
(* ------------------------------------------------------------------------- *)

type thms

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

val new : {savable : bool} -> thms

val thms : thms -> Thms.thms

(* ------------------------------------------------------------------------- *)
(* Looking up symbols and theorems.                                          *)
(* ------------------------------------------------------------------------- *)

val peekThm : thms -> Sequent.sequent -> ObjectProv.object option

val peekTypeOp : thms -> Name.name -> ObjectProv.object option

val peekConst : thms -> Name.name -> ObjectProv.object option

val peekSpecificTypeOp : thms -> TypeOp.typeOp -> ObjectProv.object option

val peekSpecificConst : thms -> Const.const -> ObjectProv.object option

(* ------------------------------------------------------------------------- *)
(* Merging.                                                                  *)
(* ------------------------------------------------------------------------- *)

val union : thms -> thms -> thms

val unionList : thms list -> thms

(* ------------------------------------------------------------------------- *)
(* Converting between export sets of theorem objects.                        *)
(* ------------------------------------------------------------------------- *)

val fromExport : ObjectExport.export -> thms

val toExport : thms -> ObjectExport.export

end
