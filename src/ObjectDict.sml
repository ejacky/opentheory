(* ========================================================================= *)
(* OBJECT DICTIONARIES                                                       *)
(* Copyright (c) 2004 Joe Leslie-Hurd, distributed under the MIT license     *)
(* ========================================================================= *)

structure ObjectDict :> ObjectDict =
struct

open Useful;

(* ------------------------------------------------------------------------- *)
(* A type of object dictionaries.                                            *)
(* ------------------------------------------------------------------------- *)

type key = int;

datatype dict = Dict of Object.object IntMap.map;

val empty = Dict (IntMap.new ());

fun size (Dict m) = IntMap.size m;

fun define (Dict dict) (key,obj) = Dict (IntMap.insert dict (key,obj));

fun refer (Dict dict) key =
    case IntMap.peek dict key of
      SOME obj => obj
    | NONE =>
      raise Error ("ObjectDict.refer: no entry for key " ^ Int.toString key);

fun remove (Dict dict) key =
    case IntMap.peek dict key of
      SOME obj => (Dict (IntMap.delete dict key), obj)
    | NONE =>
      raise Error ("ObjectDict.remove: no entry for key " ^ Int.toString key);

(* ------------------------------------------------------------------------- *)
(* Pretty printing.                                                          *)
(* ------------------------------------------------------------------------- *)

fun pp dict =
    let
      val n = size dict
    in
      Print.ppBracket "[" "]" Print.ppInt n
    end;

end
