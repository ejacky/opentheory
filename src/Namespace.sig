(* ========================================================================= *)
(* OPENTHEORY NAMESPACES                                                     *)
(* Copyright (c) 2004 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

signature Namespace =
sig

(* ------------------------------------------------------------------------- *)
(* Namespace components.                                                     *)
(* ------------------------------------------------------------------------- *)

type component = string

(* A total ordering *)

val compareComponent : component * component -> order

(* Standard syntax *)

val iffSyntaxComponent : component
val lambdaSyntaxComponent : component

(* Standard latex syntax *)

val backslashLatexComponent : component
val botLatexComponent : component
val capLatexComponent : component
val circLatexComponent : component
val crossLatexComponent : component
val cupLatexComponent : component
val emptysetLatexComponent : component
val inLatexComponent : component
val lambdaLatexComponent : component
val lnotLatexComponent : component
val subsetLatexComponent : component
val subseteqLatexComponent : component
val topLatexComponent : component

(* Standard namespaces *)

val boolNamespaceComponent : component
val dataNamespaceComponent : component
val functionNamespaceComponent : component
val listNamespaceComponent : component
val naturalNamespaceComponent : component
val numberNamespaceComponent : component
val optionNamespaceComponent : component
val pairNamespaceComponent : component
val setNamespaceComponent : component

(* Standard type operators *)

val boolTypeOpComponent : component
val funTypeOpComponent : component
val indTypeOpComponent : component
val listTypeOpComponent : component
val naturalTypeOpComponent : component
val optionTypeOpComponent : component
val pairTypeOpComponent : component
val sumTypeOpComponent : component

(* Standard constants *)

val addConstComponent : component
val bit0ConstComponent : component
val bit1ConstComponent : component
val caseConstComponent : component
val composeConstComponent : component
val condConstComponent : component
val conjConstComponent : component
val consConstComponent : component
val differenceConstComponent : component
val disjConstComponent : component
val emptyConstComponent : component
val eqConstComponent : component
val existsConstComponent : component
val existsUniqueConstComponent : component
val falseConstComponent : component
val forallConstComponent : component
val fromNaturalConstComponent : component
val fromPredicateConstComponent : component
val geConstComponent : component
val gtConstComponent : component
val idConstComponent : component
val impConstComponent : component
val intersectConstComponent : component
val leConstComponent : component
val lengthConstComponent : component
val ltConstComponent : component
val memberConstComponent : component
val minimalConstComponent : component
val negConstComponent : component
val nilConstComponent : component
val noneConstComponent : component
val pairConstComponent : component
val properSubsetConstComponent : component
val selectConstComponent : component
val someConstComponent : component
val subsetConstComponent : component
val sucConstComponent : component
val trueConstComponent : component
val unionConstComponent : component
val zeroConstComponent : component

(* Parsing and pretty printing *)

val ppComponent : component Print.pp

val parserComponent : (char,component) Parse.parser

val toHtmlComponent : component -> Html.inline list

(* ------------------------------------------------------------------------- *)
(* A type of namespaces.                                                     *)
(* ------------------------------------------------------------------------- *)

type namespace

val append : namespace -> namespace -> namespace

val toList : namespace -> component list

val fromList : component list -> namespace

(* ------------------------------------------------------------------------- *)
(* The top-level namespace.                                                  *)
(* ------------------------------------------------------------------------- *)

val global : namespace

val isGlobal : namespace -> bool

(* ------------------------------------------------------------------------- *)
(* Nested namespaces (i.e., everything except the top-level).                *)
(* ------------------------------------------------------------------------- *)

val mkNested : namespace * component -> namespace

val destNested : namespace -> namespace * component

val isNested : namespace -> bool

(* ------------------------------------------------------------------------- *)
(* A total ordering.                                                         *)
(* ------------------------------------------------------------------------- *)

val compare : namespace * namespace -> order

val equal : namespace -> namespace -> bool

(* ------------------------------------------------------------------------- *)
(* Rewriting namespaces.                                                     *)
(* ------------------------------------------------------------------------- *)

val rewrite : namespace * namespace -> namespace -> namespace option

(* ------------------------------------------------------------------------- *)
(* The standard namespace.                                                   *)
(* ------------------------------------------------------------------------- *)

val bool : namespace

val function : namespace

val list : namespace

val natural : namespace

val option : namespace

val pair : namespace

val set : namespace

(* ------------------------------------------------------------------------- *)
(* Parsing and pretty printing.                                              *)
(* ------------------------------------------------------------------------- *)

val pp : namespace Print.pp

val toString : namespace -> string

val toHtml : namespace -> Html.inline list

(* The following can be used for serializing and unserializing *)

val ppQuoted : namespace Print.pp

val quotedToString : namespace -> string

val quotedParser : (char,namespace) Parse.parser

end
