(* ========================================================================= *)
(* UNWANTED OPENTHEORY OBJECTS                                               *)
(* Copyright (c) 2011 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

structure ObjectUnwanted :> ObjectUnwanted =
struct

open Useful;

(* ------------------------------------------------------------------------- *)
(* The Unwanted namespace.                                                   *)
(* ------------------------------------------------------------------------- *)

val namespace = Namespace.fromList ["Unwanted"];

(* ------------------------------------------------------------------------- *)
(* Unwanted.id constants.                                                    *)
(* ------------------------------------------------------------------------- *)

val idName = Name.mk (namespace,"id");

val unwantedIdConst = Const.mkUndef idName;

local
  val sav = {savable = true};

  val xNameObj = ObjectProv.mkName (Name.mkGlobal "x");

  val alphaNameObj = ObjectProv.mkName (Name.mkGlobal "A");

  val alphaTypeObj = ObjectProv.mkVarType alphaNameObj;

  val xVarObj = ObjectProv.mkVar sav xNameObj alphaTypeObj;

  val xTermObj = ObjectProv.mkVarTerm sav xVarObj;
in
  val idTermObject = ObjectProv.mkAbsTerm sav xVarObj xTermObj;
end;

val (idConstObject,idDefObject) =
    ObjectProv.mkDefineConst {savable = true} idName idTermObject;

(***
(* ------------------------------------------------------------------------- *)
(* Unwanted constants.                                                       *)
(* ------------------------------------------------------------------------- *)

fun destUnwantedIdConst c =
    let
      val n = Const.name c

(*OpenTheoryTrace4
      val () = Print.trace Name.pp "ObjectRewrite.destUnwantedIdConst.n" n
*)
    in
      if Name.equal n Name.unwantedIdConst then ()
      else raise Error "ObjectRewrite.destUnwantedIdConst"
    end;

fun destUnwantedIdTerm tm =
    let
      val (c,ty) = Term.destConst tm

      val () = destUnwantedIdConst c
    in
      ty
    end;

fun destUnwantedIdRefl th =
    destUnwantedIdTerm (Term.destRefl (Thm.concl th));

fun destUnwantedIdTermObject ob =
    destUnwantedIdTerm (Object.destTerm ob);

fun destUnwantedIdReflObject ob =
    destUnwantedIdRefl (Object.destThm ob);

fun destUnwantedIdTermObjectProv obj =
    destUnwantedIdTermObject (ObjectProv.object obj);

fun destUnwantedIdReflObjectProv obj =
    destUnwantedIdReflObject (ObjectProv.object obj);

fun unwantedId obj =
    let
      val ObjectProv.Object' {object = ob, provenance = prov} =
          ObjectProv.dest obj

(*OpenTheoryTrace4
      val () = Print.trace Object.pp "ObjectRewrite.unwantedId.ob" ob

      val () = Print.trace ObjectProv.ppProvenance
                 "ObjectRewrite.unwantedId.prov" prov
*)
    in
      case prov of
        ObjectProv.Default =>
        let
          val (f,a) = Object.destAppTerm ob

          val _ = destUnwantedIdTerm f

          val obj' =
              ObjectProv.Object'
                {object = Object.Term a,
                 provenance = ObjectProv.Default}
        in
          ObjectProv.mk obj'
        end
      | ObjectProv.Special
          {command = Command.AppTerm,
           arguments = [objF,objA],
           generated = [_],
           result = 0} =>
        let
          val _ = destUnwantedIdTermObjectProv objF
        in
          objA
        end
      | ObjectProv.Special
          {command = Command.AppThm,
           arguments = [objF,objA],
           generated = [_],
           result = 0} =>
        let
          val _ = destUnwantedIdReflObjectProv objF
        in
          objA
        end
      | ObjectProv.Special _ => raise Error "ObjectRewrite.unwantedId"
    end;
***)

(* ------------------------------------------------------------------------- *)
(* Eliminating Unwanted objects.                                             *)
(* ------------------------------------------------------------------------- *)

datatype eliminate =
    Eliminate of
      {defaultMap : (bool * ObjectProv.object) ObjectMap.map,
       specialMap : ObjectProv.object option IntMap.map,
       savable : bool};

fun new {savable} =
    let
      val defaultMap =
          ObjectMap.fromList
            [(Object.Const unwantedIdConst,(false,idConstObject))]

      and specialMap = IntMap.new ()
    in
      Eliminate
        {defaultMap = defaultMap,
         specialMap = specialMap,
         savable = savable}
    end;

local
  fun eliminateTop obj elim = (NONE,elim);

  fun eliminateOb' ob elim =
      let
        val Eliminate {defaultMap,specialMap,savable} = elim
      in
        case ObjectMap.peek defaultMap ob of
          SOME obj' => (obj',elim)
        | NONE =>
          let
            val (cmd,obs) = Object.command ob

            val (objs',elim) = maps eliminateOb' obs elim

            val unchanged = List.all fst objs'
            and objs = List.map snd objs'

            val obj =
                let
                  val xs = ObjectProv.mkCommand {savable = savable} cmd objs

                  val () =
                      case xs of
                        [_] => ()
                      | _ => raise Bug "ObjectUnwanted.eliminateOb'"
                in
                  hd xs
                end

            val (obj',elim) =
                let
                  val (obj',elim) = eliminateTop obj elim

                  val obj' =
                      case obj' of
                        SOME obj => (false,obj)
                      | NONE => (unchanged,obj)
                in
                  (obj',elim)
                end

            val defaultMap = ObjectMap.insert defaultMap (ob,obj')

            val elim =
                Eliminate
                  {defaultMap = defaultMap,
                   specialMap = specialMap,
                   savable = savable}
          in
            (obj',elim)
          end
      end;

  fun eliminateOb ob elim =
      let
        val ((unchanged,obj),elim) = eliminateOb' ob elim

        val obj' = if unchanged then NONE else SOME obj

(*OpenTheoryTrace4
*)
        val () =
            let
              val ppElim =
                  Print.ppOp2 " ->" Object.pp
                    (Print.ppOption ObjectProv.pp)
            in
              Print.trace ppElim "ObjectUnwanted.eliminateOb"
                (ob,obj')
            end

      in
        (obj',elim)
      end;

  fun eliminateObj obj elim =
      let
        val ObjectProv.Object' {object = ob, provenance = prov} = obj
      in
        if ObjectProv.isDefaultProvenance prov then eliminateOb ob elim
        else (NONE,elim)
      end;

  fun preDescent obj elim =
      let
        val Eliminate {specialMap,...} = elim

        val i = ObjectProv.id obj
      in
        case IntMap.peek specialMap i of
          NONE => {descend = true, result = (NONE,elim)}
        | SOME obj' => {descend = false, result = (obj',elim)}
      end;

  fun postDescent obj0 obj1' elim =
      let
        val i = ObjectProv.id obj0

        val unchanged = true

        val (unchanged,obj1) =
            case obj1' of
              NONE => (unchanged,obj0)
            | SOME obj => (false,obj)

        val (obj2',elim) = eliminateObj (ObjectProv.dest obj1) elim

        val (unchanged,obj2) =
            case obj2' of
              NONE => (unchanged,obj1)
            | SOME obj => (false,obj)

        val obj2' = if unchanged then NONE else SOME obj2

        val Eliminate {defaultMap,specialMap,savable} = elim

        val specialMap = IntMap.insert specialMap (i,obj2')

        val elim =
            Eliminate
              {defaultMap = defaultMap,
               specialMap = specialMap,
               savable = savable}
      in
        (obj2',elim)
      end;
in
  fun sharingEliminate obj elim =
      let
        val Eliminate {savable,...} = elim
      in
        ObjectProv.maps
          {preDescent = preDescent,
           postDescent = postDescent,
           savable = savable} obj elim
      end;
end;

fun eliminate elim obj =
    let
      val (obj',_) = sharingEliminate obj elim
    in
      obj'
    end;

end
