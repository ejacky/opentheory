(* ========================================================================= *)
(* THEOREMS CONTAINED IN A SET OF OBJECTS                                    *)
(* Copyright (c) 2004 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

structure ObjectThms :> ObjectThms =
struct

open Useful;

(* ------------------------------------------------------------------------- *)
(* A type of object set theorems.                                            *)
(* ------------------------------------------------------------------------- *)

datatype thms =
    Thms of
      {objs : ObjectProvSet.set,
       seqs : (Thm.thm * ObjectProv.object) SequentMap.map,
       symbol : Symbol.symbol,
       seen : IntSet.set};

val empty =
    let
      val objs = ObjectProvSet.empty
      val seqs = SequentMap.new ()
      val symbol = Symbol.empty
      val seen = IntSet.empty
    in
      Thms
        {objs = objs,
         seqs = seqs,
         symbol = symbol,
         seen = seen}
    end;

fun size (Thms {objs,seqs,...}) =
    {objs = ObjectProvSet.size objs,
     thms = SequentMap.size seqs};

fun objects (Thms {objs,...}) = objs;

fun symbol (Thms {symbol = x, ...}) = x;

(* ------------------------------------------------------------------------- *)
(* Adding objects.                                                           *)
(* ------------------------------------------------------------------------- *)

local
  fun adds objA seqs sym seen objs =
      case objs of
        [] => (seqs,sym,seen)
      | obj :: objs =>
        let
          val id = ObjectProv.id obj
        in
          if IntSet.member id seen then adds objA seqs sym seen objs
          else
            let
              val seen = IntSet.add seen id
            in
              case ObjectProv.provenance obj of
                ObjectProv.Pnull => adds objA seqs sym seen objs
              | ObjectProv.Pcall _ => adds objA seqs sym seen objs
              | ObjectProv.Pcons (objH,objT) =>
                adds objA seqs sym seen (objH :: objT :: objs)
              | ObjectProv.Pref objR =>
                adds objA seqs sym seen (objR :: objs)
              | ObjectProv.Pthm _ =>
                let
                  val th =
                      case ObjectProv.object obj of
                        Object.Othm th => th
                      | _ => raise Bug "ObjectThms.add: bad thm"

                  val seq = Thm.sequent th

                  val (seqs,sym) =
                      if SequentMap.inDomain seq seqs then (seqs,sym)
                      else
                        (SequentMap.insert seqs (seq,(th,objA)),
                         Symbol.addSequent sym seq)
                in
                  adds objA seqs sym seen objs
                end
            end
        end;
in
  fun add thms obj =
      let
        val Thms {objs,seqs,symbol,seen} = thms

        val objs = ObjectProvSet.add objs obj
        and (seqs,symbol,seen) = adds obj seqs symbol seen [obj]
      in
        Thms
          {objs = objs,
           seqs = seqs,
           symbol = symbol,
           seen = seen}
      end;
end;

fun singleton obj = add empty obj;

local
  fun add1 (obj,thms) = add thms obj;
in
  fun addList thms objs = List.foldl add1 thms objs;

  fun addSet thms objs = ObjectProvSet.foldl add1 thms objs;
end;

fun union ths1 ths2 =
    let
      val Thms
            {objs = objs1,
             seqs = seqs1,
             symbol = sym1,
             seen = seen1} = ths1
      and Thms
            {objs = objs2,
             seqs = seqs2,
             symbol = sym2,
             seen = seen2} = ths2

      val objs = ObjectProvSet.union objs1 objs2

      val seqs = SequentMap.union (SOME o fst) seqs1 seqs2

      val sym = Symbol.union sym1 sym2

      val seen = IntSet.union seen1 seen2
    in
      Thms
        {objs = objs,
         seqs = seqs,
         symbol = sym,
         seen = seen}
    end;

(* ------------------------------------------------------------------------- *)
(* Searching for theorems.                                                   *)
(* ------------------------------------------------------------------------- *)

fun search (Thms {seqs,...}) seq =
    case SequentMap.peek seqs seq of
      NONE => NONE
    | SOME (th,obj) =>
      let
        val th = Rule.alpha seq th
      in
        SOME (th,obj)
      end;

local
  fun add (_,(th,_),set) = ThmSet.add set th;
in
  fun toThmSet (Thms {seqs,...}) =
      SequentMap.foldl add ThmSet.empty seqs;
end;

(* ------------------------------------------------------------------------- *)
(* Building objects using object set theorems.                               *)
(* ------------------------------------------------------------------------- *)

fun buildObject {savable} thms =
    let
      fun mkObj ob prov =
          ObjectProv.mk
            {object = ob,
             provenance = prov}

      fun mkNullObj ob = mkObj ob ObjectProv.Pnull

      fun mkConsObj ob objH objT =
          let
            val isTh =
                ObjectProv.containsThms objH orelse
                ObjectProv.containsThms objT

            val prov =
                if isTh then ObjectProv.Pcons (objH,objT)
                else ObjectProv.Pnull
          in
            mkObj ob prov
          end

      fun mkThmObj ob th =
          let
            val objS =
                case search thms (Thm.sequent th) of
                  SOME (_,objS) => objS
                | NONE =>
                  raise Error ("couldn't find theorem:\n" ^ Thm.toString th)

            val inf = if savable then ObjectProv.Ialpha objS
                      else ObjectProv.Iaxiom

            val prov = ObjectProv.Pthm inf
          in
            mkObj ob prov
          end

      fun build ob =
          case ob of
            Object.Olist (obH :: obT) =>
            let
              val objH = build obH

              val objT = build (Object.Olist obT)
            in
              mkConsObj ob objH objT
            end
          | Object.Othm th => mkThmObj ob th
          | Object.Ocall _ => raise Error "cannot build an Ocall object"
          | _ => mkNullObj ob
    in
      build
    end
(*OpenTheoryDebug
      handle Error err =>
        raise Bug ("ObjectThms.buildObject: " ^ err);
*)

end
