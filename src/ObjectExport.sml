(* ========================================================================= *)
(* EXPORTED THEOREM OBJECTS                                                  *)
(* Copyright (c) 2010 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

structure ObjectExport :> ObjectExport =
struct

open Useful;

(* ------------------------------------------------------------------------- *)
(* A type of exported theorem objects.                                       *)
(* ------------------------------------------------------------------------- *)

datatype export = Export of Thm.thm ObjectProvMap.map;

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

val empty = Export (ObjectProvMap.new ());

fun null (Export m) = ObjectProvMap.null m;

fun size (Export m) = ObjectProvMap.size m;

fun insert (Export m) obj_th = Export (ObjectProvMap.insert m obj_th);

fun foldl f a (Export m) = ObjectProvMap.foldl f a m;

fun foldr f a (Export m) = ObjectProvMap.foldr f a m;

fun toMap (Export m) = m;

fun toList (Export m) = ObjectProvMap.toList m;

(* ------------------------------------------------------------------------- *)
(* Compression.                                                              *)
(* ------------------------------------------------------------------------- *)

type refs = ObjectProv.object ObjectMap.map;

val emptyRefs : refs = ObjectMap.new ();

fun improveRefs refs obj : refs =
    let
      val ob = ObjectProv.object obj

      val imp =
          case ObjectMap.peek refs ob of
            NONE => true
          | SOME obj' => ObjectProv.id obj < ObjectProv.id obj'
    in
      if imp then ObjectMap.insert refs (ob,obj) else refs
    end;

local
  type state = IntSet.set * refs;

  val initial : state = (IntSet.empty,emptyRefs);

  fun preDescent obj (acc : state) =
      let
        val (seen,refs) = acc

        val i = ObjectProv.id obj
      in
        if IntSet.member i seen then {descend = false, result = acc}
        else {descend = true, result = (IntSet.add seen i, refs)}
      end;

  fun postDescent obj (acc : state) =
      let
        val (seen,refs) = acc

        val refs = improveRefs refs obj
      in
        (seen,refs)
      end;

  fun advance (obj,_,acc) =
      ObjectProv.foldl
        {preDescent = preDescent,
         postDescent = postDescent} acc obj;
in
  fun toRefs (Export m) =
      let
        val (_,refs) = ObjectProvMap.foldl advance initial m
      in
        refs
      end;
end;

local
  type state = ObjectProv.object IntMap.map;

  val initial : state = IntMap.new ();

  fun preDescent refs objI (acc : state) =
      let
        val i = ObjectProv.id objI

        val objI' = IntMap.peek acc i
      in
        case objI' of
          SOME objR =>
          let
            val objR' = if ObjectProv.equalId i objR then NONE else objI'
          in
            {descend = false, result = (objR',acc)}
          end
        | NONE =>
          let
            val obI = ObjectProv.object objI

            val objJ' = ObjectMap.peek refs obI

            val objJ =
                case objJ' of
                  NONE => raise Bug "ObjectExport.compressRefs.preDescent"
                | SOME obj => obj

            val j = ObjectProv.id objJ
          in
            if j = i then {descend = true, result = (NONE,acc)}
            else
              let
                val objR' = IntMap.peek acc j
              in
                case objR' of
                  NONE =>
                  let
                    val acc = IntMap.insert acc (i,objJ)
                  in
                    {descend = true, result = (objJ',acc)}
                  end
                | SOME objR =>
                  let
                    val acc = IntMap.insert acc (i,objR)
                  in
                    {descend = false, result = (objR',acc)}
                  end
              end
          end
      end;

  fun postDescent objI objR' (acc : state) =
      let
        val i = ObjectProv.id objI
      in
        case objR' of
          NONE =>
          let
            val acc = IntMap.insert acc (i,objI)
          in
            (objR',acc)
          end
        | SOME objR =>
          let
            val acc =
                case IntMap.peek acc i of
                  NONE => acc
                | SOME objJ => IntMap.insert acc (ObjectProv.id objJ, objR)

            val acc = IntMap.insert acc (i,objR)
          in
            (objR',acc)
          end
      end;

  fun advance refs (obj,th,(acc,exp)) =
      let
        val (obj',acc) =
            ObjectProv.maps
              {preDescent = preDescent refs,
               postDescent = postDescent,
               savable = true} obj acc

        val obj = Option.getOpt (obj',obj)

        val exp = insert exp (obj,th)
      in
        (acc,exp)
      end;
in
  fun compressRefs refs exp =
      let
        val (_,exp) = foldl (advance refs) (initial,empty) exp
      in
        exp
      end;
end;

fun compress exp =
    let
      val refs = toRefs exp
    in
      compressRefs refs exp
    end;

(* ------------------------------------------------------------------------- *)
(* Pretty printing.                                                          *)
(* ------------------------------------------------------------------------- *)

val pp = Print.ppMap size (Print.ppBracket "export{" "}" Print.ppInt);

end
