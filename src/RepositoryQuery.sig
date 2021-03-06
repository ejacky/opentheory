(* ========================================================================= *)
(* QUERYING PACKAGE REPOSITORIES                                             *)
(* Copyright (c) 2012 Joe Leslie-Hurd, distributed under the MIT license     *)
(* ========================================================================= *)

signature RepositoryQuery =
sig

(* ------------------------------------------------------------------------- *)
(* A type of package query.                                                  *)
(* ------------------------------------------------------------------------- *)

datatype set =
    Name of PackageName.name
  | NameVersion of PackageNameVersion.nameVersion
  | All
  | None

datatype predicate =
    Empty
  | Mine
  | Closed
  | Acyclic
  | UpToDate
  | OnRepo
  | EarlierThanRepo
  | LaterThanRepo
  | IdenticalOnRepo
  | ConsistentWithRepo
  | ExportHaskell
  | Not of predicate
  | And of predicate * predicate
  | Or of predicate * predicate

datatype function =
    Identity
  | Constant of set
  | Filter of predicate
  | Requires
  | RequiredBy
  | Includes
  | IncludedBy
  | Subtheories
  | SubtheoryOf
  | Versions
  | Latest
  | Deprecated
  | Obsolete
  | Upgradable
  | Uploadable
  | Union of function * function
  | Intersect of function * function
  | Difference of function * function
  | ReflexiveTransitive of function
  | Transitive of function
  | Optional of function
  | Compose of function * function

(* ------------------------------------------------------------------------- *)
(* Does the function ignore its input?                                       *)
(* ------------------------------------------------------------------------- *)

val ignoresRemote : predicate -> bool

val ignoresInput : function -> bool

(* ------------------------------------------------------------------------- *)
(* Evaluating queries.                                                       *)
(* ------------------------------------------------------------------------- *)

val evaluateSet :
    Repository.repository -> set -> PackageNameVersionSet.set

val evaluatePredicate :
    Repository.repository -> RepositoryRemote.remote list -> predicate ->
    PackageNameVersion.nameVersion -> bool

val evaluateFunction :
    Repository.repository -> RepositoryRemote.remote list -> function ->
    PackageNameVersionSet.set -> PackageNameVersionSet.set

val evaluate :
    Repository.repository -> RepositoryRemote.remote list -> function ->
    PackageNameVersionSet.set

(* ------------------------------------------------------------------------- *)
(* Pretty printing.                                                          *)
(* ------------------------------------------------------------------------- *)

val ppSet : set Print.pp

val ppPredicate : predicate Print.pp

val pp : function Print.pp

val toString : function -> string

(* ------------------------------------------------------------------------- *)
(* Parsing.                                                                  *)
(* ------------------------------------------------------------------------- *)

val parserSet : (char,set) Parse.parser

val parserPredicate : (char,predicate) Parse.parser

val parser : (char,function) Parse.parser

val fromString : string -> function

end
