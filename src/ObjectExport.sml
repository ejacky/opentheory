(* ========================================================================= *)
(* EXPORT SETS OF THEOREM OBJECTS                                            *)
(* Copyright (c) 2010 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

structure ObjectExport :> ObjectExport =
struct

open Useful;

(* ------------------------------------------------------------------------- *)
(* A type of export sets of theorem objects.                                 *)
(* ------------------------------------------------------------------------- *)

datatype export =
    Export of
      {thms : ObjectThmSet.set,
       savable : bool};

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

fun new {savable} =
    let
      val size = 0
      and thms = ObjectThmSet.empty
    in
      Export
        {thms = thms,
         savable = savable}
    end;

val empty = new {savable = true};

fun savable (Export {savable = x, ...}) = x;

fun toSet (Export {thms = x, ...}) = x;

fun null exp = ObjectThmSet.null (toSet exp);

fun size exp = ObjectThmSet.size (toSet exp);

fun add exp th =
    let
      val Export {thms,savable} = exp

      val thms = ObjectThmSet.add thms th
    in
      Export
        {thms = thms,
         savable = savable}
    end;

fun foldl f b exp = ObjectThmSet.foldl f b (toSet exp);

fun foldr f b exp = ObjectThmSet.foldr f b (toSet exp);

fun toList exp = ObjectThmSet.toList (toSet exp);

(* ------------------------------------------------------------------------- *)
(* Merging.                                                                  *)
(* ------------------------------------------------------------------------- *)

fun union exp1 exp2 =
    let
      val Export {thms = ths1, savable = sav1} = exp1
      and Export {thms = ths2, savable = sav2} = exp2

      val sav = sav1 andalso sav2

      val ths = ObjectThmSet.union ths1 ths2
    in
      Export
        {thms = ths,
         savable = sav}
    end;

local
  fun uncurriedUnion (thms1,thms2) = union thms1 thms2;
in
  fun unionList thmsl =
      case thmsl of
        [] => empty
      | thms :: thmsl => List.foldl uncurriedUnion thms thmsl;
end;

(* ------------------------------------------------------------------------- *)
(* Mapping over exported theorem objects.                                    *)
(* ------------------------------------------------------------------------- *)

local
  fun addThm f (th,(unchanged,ths,acc)) =
      let
        val (th',acc) = f th acc

        val (unchanged,th) =
            case th' of
              NONE => (unchanged,th)
            | SOME x => (false,x)

        val ths = ObjectThmSet.add ths th
      in
        (unchanged,ths,acc)
      end;
in
  fun maps f exp acc =
      let
        val Export {thms,savable} = exp

        val (thms',acc) = ObjectThmSet.maps f thms acc

        val exp' =
            case thms' of
              NONE => NONE
            | SOME thms => SOME (Export {thms = thms, savable = savable})
      in
        (exp',acc)
      end;
end;

(* ------------------------------------------------------------------------- *)
(* Symbols.                                                                  *)
(* ------------------------------------------------------------------------- *)

local
  fun addThm (th,sym) =
      let
        val ObjectThm.Thm {proof = _, hyp, concl} = th

        val sym = ObjectSymbol.addObject sym hyp

        val sym = ObjectSymbol.addObject sym concl
      in
        sym
      end;
in
  val symbol = foldl addThm ObjectSymbol.empty;
end;

(* ------------------------------------------------------------------------- *)
(* Eliminate unwanted subterms.                                              *)
(* ------------------------------------------------------------------------- *)

fun eliminateUnwanted exp =
    let
      val () =
          if savable exp then ()
          else raise Bug "ObjectExport.eliminateUnwanted: unsavable"

      val elim = ObjectUnwanted.empty

      val (exp',_) = maps ObjectThm.sharingEliminateUnwanted exp elim
    in
      exp'
    end;

(* ------------------------------------------------------------------------- *)
(* Compression.                                                              *)
(* ------------------------------------------------------------------------- *)

local
  datatype state =
      State of
        {cache : Object.object IntMap.map};

  val initialState =
      let
        val cache = IntMap.new ()
      in
        State
          {cache = cache}
      end;

  fun peekState (State {cache,...}) = IntMap.peek cache;

  fun insertState acc i_obj =
      let
        val State {cache} = acc

        val cache = IntMap.insert cache i_obj
      in
        State
          {cache = cache}
      end;

  fun ppState acc =
      let
        val State {cache} = acc
      in
        Print.consistentBlock 0
          [Print.ppString "State {",
           Print.ppBreak (Print.Break {size = 0, extraIndent = 2}),
           Print.inconsistentBlock 2
             [Print.ppString "cache =",
              Print.break,
              Print.ppPrettyInt (IntMap.size cache)],
           Print.breaks 0,
           Print.ppString "}"]
      end;

  val mkStore =
      let
        fun add (th,store) = ObjectThm.addStore store th;
      in
        foldl add ObjectStore.emptyDictionary
      end;

  fun preDescent store objI acc =
      let
        val i = Object.id objI

        val objI' = peekState acc i
      in
        case objI' of
          SOME objR =>
          let
            val objR' = if Object.equalId i objR then NONE else objI'
          in
            {descend = false, result = (objR',acc)}
          end
        | NONE =>
          let
            val (objJ,_) = ObjectStore.build (Object.data objI) store

            val j = Object.id objJ
          in
            if j = i then {descend = true, result = (NONE,acc)}
            else
              let
                val objR' = peekState acc j
              in
                case objR' of
                  NONE =>
                  let
                    val acc = insertState acc (i,objJ)
                  in
                    {descend = true, result = (SOME objJ, acc)}
                  end
                | SOME objR =>
                  let
                    val acc = insertState acc (i,objR)
                  in
                    {descend = false, result = (objR',acc)}
                  end
              end
          end
      end;

  fun postDescent objI objR' (acc : state) =
      let
        val i = Object.id objI
      in
        case objR' of
          NONE =>
          let
            val acc = insertState acc (i,objI)
          in
            (objR',acc)
          end
        | SOME objR =>
          let
            val acc =
                case peekState acc i of
                  NONE => acc
                | SOME objJ => insertState acc (Object.id objJ, objR)

            val acc = insertState acc (i,objR)
          in
            (objR',acc)
          end
      end;

  fun compressObj store =
      Object.maps
        {preDescent = preDescent store,
         postDescent = postDescent,
         savable = true};

  fun compressThm store = ObjectThm.maps (compressObj store);
in
  fun compress exp =
      let
        val store = mkStore exp

        val acc = initialState

        val (exp',acc) = maps (compressThm store) exp acc

(*OpenTheoryTrace4
        val () = Print.trace ObjectStore.pp
                   "ObjectExport.compress: refs" store

        val () = Print.trace ppState
                   "ObjectExport.compress: final state" acc
*)
      in
        exp'
      end;
end;

(* ------------------------------------------------------------------------- *)
(* Pretty printing.                                                          *)
(* ------------------------------------------------------------------------- *)

val pp = Print.ppMap size (Print.ppBracket "export{" "}" Print.ppInt);

end
