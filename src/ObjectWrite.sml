(* ========================================================================= *)
(* WRITING OBJECTS TO COMMANDS                                               *)
(* Copyright (c) 2004 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

structure ObjectWrite :> ObjectWrite =
struct

open Useful;

(* ------------------------------------------------------------------------- *)
(* Helper functions.                                                         *)
(* ------------------------------------------------------------------------- *)

fun revAppend [] s = s ()
  | revAppend (h :: t) s = revAppend t (K (Stream.Cons (h,s)));

fun revConcat strm =
    case strm of
      Stream.Nil => Stream.Nil
    | Stream.Cons (h,t) => revAppend h (revConcat o t);

(* ------------------------------------------------------------------------- *)
(* Minimal dictionaries.                                                     *)
(* ------------------------------------------------------------------------- *)

datatype minDict =
    MinDict of
      {nextKey : int,
       refs : int ObjectMap.map,
       keys : int ObjectMap.map};

fun nullMinDict (MinDict {keys,...}) = ObjectMap.null keys;

local
  fun storable ob =
      case ob of
        Object.Oerror => false
      | Object.Oint _ => false
      | Object.Oname _ => false
      | Object.Olist l => not (null l)
      | Object.Otype _ => true
      | Object.Oterm _ => true
      | Object.Othm _ => true
      | Object.Ocall _ => raise Bug "ObjectWrite.storable: Ocall";

  fun registerTop refs ob =
      let
        val p = ObjectMap.peek refs ob
        val known = Option.isSome p
        val k = Option.getOpt (p,0)
        val refs = ObjectMap.insert refs (ob, k + 1)
      in
        (known,refs)
      end;

  fun registerDeep refs [] = refs
    | registerDeep refs (ob :: obs) =
      if not (storable ob) then registerDeep refs obs
      else
        let
          val (known,refs) = registerTop refs ob
          val obs = if known then obs else snd (Object.toCommand ob) @ obs
        in
          registerDeep refs obs
        end;

  fun register (obj,refs) =
      let
        val ob = ObjectProv.object obj
      in
        case ObjectProv.provenance obj of
          ObjectProv.Pnull => registerDeep refs [ob]
        | ObjectProv.Pcall _ => refs
        | ObjectProv.Pcons _ =>
          let
            val (known,refs) = registerTop refs ob
(*OpenTheoryDebug
            val _ =
                not known orelse
                let
                  val () = Print.trace (ObjectProv.pp 1) "deja vu obj" obj
                  val k = ObjectMap.peek refs ob
                  val () = Print.trace (Print.ppOption Print.ppInt) "refs" k
                in
                  raise Error "register: Pcons deja vu"
                end
*)
          in
            refs
          end
        | ObjectProv.Pref _ =>
          let
            val (known,refs) = registerTop refs ob

(*OpenTheoryDebug
            val _ = known orelse
                    raise Error "register: unknown Pref"
*)
          in
            refs
          end
        | ObjectProv.Pthm inf =>
          let
            val refs =
                case inf of
                  ObjectProv.Ialpha iobj =>
                  let
                    val iob = ObjectProv.object iobj

                    val (known,refs) = registerTop refs iob
(*OpenTheoryDebug
                    val _ = known orelse
                            raise Error "register: unknown Ialpha ref"
*)

                    val refs = registerDeep refs [ob]

                    val (known,refs) = registerTop refs ob
(*OpenTheoryDebug
                    val _ = known orelse
                            raise Error "register: unknown Ialpha thm"
*)
                  in
                    refs
                  end
                | _ => registerDeep refs [ob]
          in
            refs
          end
      end;
in
  fun newMinDict objs =
      let
        val nextKey = 1
        val refs = ObjectMap.new ()
        val refs = ObjectProvSet.foldl register refs objs
        val refs = ObjectMap.filter (fn (_,n) => n >= 2) refs
        val keys = ObjectMap.new ()
      in
        MinDict
          {nextKey = nextKey,
           refs = refs,
           keys = keys}
      end
(*OpenTheoryDebug
      handle Error err =>
        raise Bug ("ObjectWrite.newMinDict: " ^ err);
*)
end;

local
  fun isKey (MinDict {keys,...}) ob = ObjectMap.inDomain ob keys;

  fun addKey dict cmds ob =
      let
        val MinDict {nextKey,refs,keys} = dict

(*OpenTheoryDebug
        val _ = not (ObjectMap.inDomain ob keys) orelse
                raise Error "addKey: deja vu ob"
*)
      in
        case ObjectMap.peek refs ob of
          NONE => (dict,cmds)
        | SOME n =>
          let
            val key = nextKey
            val nextKey = nextKey + 1
            val keys = ObjectMap.insert keys (ob,key)
            val refs = ObjectMap.insert refs (ob, n - 1)
            val dict =
                MinDict {nextKey = nextKey, refs = refs, keys = keys}
            val cmds = [Command.Def, Command.Num key] @ cmds
          in
            (dict,cmds)
          end
      end;

  fun useKey dict cmds ob =
      let
        val MinDict {nextKey,refs,keys} = dict
      in
        case ObjectMap.peek keys ob of
          NONE => raise Bug "Article.useKey"
        | SOME key =>
          let
            val cmds = Command.Num key :: cmds
          in
            case ObjectMap.peek refs ob of
              NONE => raise Bug "generate"
            | SOME n =>
              if n = 1 then
                let
                  val refs = ObjectMap.delete refs ob
                  val keys = ObjectMap.delete keys ob
                  val dict =
                      MinDict {nextKey = nextKey, refs = refs, keys = keys}
                  val cmds = Command.Remove :: cmds
                in
                  (dict,cmds)
                end
              else
                let
                  val refs = ObjectMap.insert refs (ob, n - 1)
                  val dict =
                      MinDict {nextKey = nextKey, refs = refs, keys = keys}
                  val cmds = Command.Ref :: cmds
                in
                  (dict,cmds)
                end
          end
      end;

  fun generateDeep (ob,(dict,cmds)) =
      if isKey dict ob then useKey dict cmds ob
      else
        let
          val (cmd,pars) = Object.toCommand ob
          val (dict,cmds) = foldl generateDeep (dict,cmds) pars
          val cmds = cmd :: cmds
        in
          addKey dict cmds ob
        end;
in
  fun generateMinDict stack dict cmds obj =
      let
        val ob = ObjectProv.object obj
      in
        case ObjectProv.provenance obj of
          ObjectProv.Pnull =>
          let
            val (dict,cmds) = generateDeep (ob,(dict,cmds))

            val stack = ObjectStack.push stack obj
          in
            (stack,dict,cmds)
          end
        | ObjectProv.Pcall objA =>
          let
            val n =
                case ob of
                  Object.Ocall n => n
                | _ => raise Error "Pcall: bad call"

            val cmds = Command.Call :: Command.Name n :: cmds

            val (stack,objA') = ObjectStack.pop1 stack

            val stack = ObjectStack.push stack obj

            val stack = ObjectStack.push stack objA

(*OpenTheoryDebug
            val _ = ObjectProv.id objA = ObjectProv.id objA' orelse
                    raise Error "Pcall: wrong call argument"
*)
          in
            (stack,dict,cmds)
          end
        | ObjectProv.Pcons (objH,objT) =>
          let
            val cmds = Command.Cons :: cmds

            val (dict,cmds) = addKey dict cmds ob

            val (stack,objH',objT') = ObjectStack.pop2 stack

(*OpenTheoryDebug
            val _ = ObjectProv.id objH = ObjectProv.id objH' orelse
                    raise Error "Pcons: wrong head value"

            val _ = ObjectProv.id objT = ObjectProv.id objT' orelse
                    raise Error "Pcons: wrong tail value"
*)

            val stack = ObjectStack.push stack obj
          in
            (stack,dict,cmds)
          end
        | ObjectProv.Pref _ =>
          let
            val (dict,cmds) = useKey dict cmds ob

            val stack = ObjectStack.push stack obj
          in
            (stack,dict,cmds)
          end
        | ObjectProv.Pthm inf =>
          let
            val (dict,cmds) =
                case inf of
                  ObjectProv.Ialpha iobj =>
                  let
                    val iob = ObjectProv.object iobj

                    val (dict,cmds) = useKey dict cmds iob

                    val (dict,cmds) = generateDeep (ob,(dict,cmds))

                    val cmds = Command.Pop :: Command.Pop :: cmds
                  in
                    useKey dict cmds ob
                  end
                | _ => generateDeep (ob,(dict,cmds))

            val stack = ObjectStack.push stack obj
          in
            (stack,dict,cmds)
          end
      end
(*OpenTheoryDebug
      handle Error err =>
        let
          val ppObject = ObjectProv.pp 1

          val ppStack = Print.ppMap ObjectStack.objects (Print.ppList ppObject)

          val () = Print.trace ppStack
                     "ObjectWrite.generateMinDict: stack" stack

          val () = Print.trace ppObject
                     "ObjectWrite.generateMinDict: obj" obj
      in
        raise Bug ("ObjectWrite.generateMinDict: " ^ err)
      end;
*)
end;

(* ------------------------------------------------------------------------- *)
(* Writing objects to a stream of commands.                                  *)
(* ------------------------------------------------------------------------- *)

fun toCommandStream saved =
    let
      val objs = ObjectProvSet.ancestors saved

      fun gen (greatestUse,obj) (stack,dict) =
          let
            val (stack,cmds) = ObjectStack.alignUses greatestUse stack

            val (stack,dict,cmds) =
                generateMinDict stack dict cmds obj

            val cmds =
                if not (ObjectProvSet.member obj saved) then cmds
                else Command.Save :: cmds
          in
            (cmds,(stack,dict))
          end

      fun finish (stack,dict) =
          let
(*OpenTheoryDebug
            val _ = nullMinDict dict orelse
                    raise Error "nonempty dict"
*)
            val (stack,cmds) =
                ObjectStack.alignUses {greatestUse = NONE} stack

(*OpenTheoryDebug
            val _ = ObjectStack.null stack orelse
                    raise Error "nonempty stack"
*)
          in
            if null cmds then Stream.Nil else Stream.singleton cmds
          end

      val stack = ObjectStack.empty
      val dict = newMinDict objs

      val (uses,objs) = ObjectProvSet.toGreatestUseList objs

(*OpenTheoryDebug
      val _ = ObjectProvSet.null uses orelse
              raise Error "start requires a use"
*)

      val strm = Stream.fromList objs
      val strm = Stream.maps gen finish (stack,dict) strm
    in
      revConcat strm
    end
(*OpenTheoryDebug
    handle Error err =>
      raise Bug ("ObjectWrite.toCommandStream: " ^ err);
*)

(* ------------------------------------------------------------------------- *)
(* Writing objects to text files.                                            *)
(* ------------------------------------------------------------------------- *)

fun toTextFile {filename} objs =
    let
(*OpenTheoryTrace3
      val () = Print.trace ObjectProvSet.pp
                 "ObjectWrite.toTextFile: uncompressed objs" objs
*)

      val objs = ObjectProvSet.compress objs

(*OpenTheoryTrace3
      val () = Print.trace ObjectProvSet.pp
                 "ObjectWrite.toTextFile: compressed objs" objs
*)

      val commands = toCommandStream objs

      val lines = Stream.map (fn c => Command.toString c ^ "\n") commands
    in
      Stream.toTextFile {filename = filename} lines
    end
(*OpenTheoryDebug
    handle Error err =>
      raise Bug ("ObjectWrite.toTextFile: " ^ err);
*)

end
