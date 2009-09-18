(* ========================================================================= *)
(* READING OBJECTS FROM COMMANDS                                             *)
(* Copyright (c) 2004-2009 Joe Hurd, distributed under the GNU GPL version 2 *)
(* ========================================================================= *)

structure ObjectRead :> ObjectRead =
struct

open Useful Syntax Rule;

(* ------------------------------------------------------------------------- *)
(* Simulating other theorem provers.                                         *)
(* ------------------------------------------------------------------------- *)

val simulations = HolLight.simulations;

fun simulate interpretation stack seq =
    case ObjectStack.topCall stack of
      SOME obj =>
      let
        val (f,a) = ObjectProv.destCall obj
      in
        case NameMap.peek simulations f of
          NONE => NONE
        | SOME sim =>
          let
            val a = ObjectProv.object a

            val r = sim interpretation seq a

            val ths = Object.thms r
          in
            case first (total (alpha seq)) ths of
              SOME th => SOME th
            | NONE =>
              let
                val ppOb = Print.ppOp2 " =" Print.ppString Object.pp

                val ppSeq = Print.ppOp2 " =" Print.ppString ppSequent

                val () = warn ("simulation failed: " ^ Name.toString f ^
                               "\n" ^ Print.toString ppOb ("input",a) ^
                               "\n" ^ Print.toString ppOb ("output",r) ^
                               "\n" ^ Print.toString ppSeq ("target",seq))
              in
                NONE
              end
          end
      end
    | _ => NONE;

(* ------------------------------------------------------------------------- *)
(* A type of states for reading objects from commands.                       *)
(* ------------------------------------------------------------------------- *)

datatype state =
    State of
      {stack : ObjectStack.stack,
       dict : ObjectDict.dict,
       saved : ObjectThms.thms};

fun initial saved =
    State
      {stack = ObjectStack.empty,
       dict = ObjectDict.empty,
       saved = saved};

fun stack (State {stack = x, ...}) = x;

fun dict (State {dict = x, ...}) = x;

fun saved (State {saved = x, ...}) = x;

(* ------------------------------------------------------------------------- *)
(* Executing commands.                                                       *)
(* ------------------------------------------------------------------------- *)

fun execute {savable,known,interpretation} cmd state =
    let
      val State {stack,dict,saved} = state
    in
      case cmd of
      (* Numbers *)

        Command.Num i =>
        let
          val ob = Object.Onum i
          and prov = ObjectProv.Pnull
          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      (* Names *)

      | Command.Name n =>
        let
          val ob = Object.Oname n
          and prov = ObjectProv.Pnull
          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      (* Errors *)

      | Command.Error =>
        let
          val ob = Object.Oerror
          and prov = ObjectProv.Pnull
          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      (* Lists *)

      | Command.Nil =>
        let
          val ob = Object.onil
          and prov = ObjectProv.Pnull
          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      | Command.Cons =>
        let
          val (stack,objH,objT) = ObjectStack.pop2 stack

          val obH = ObjectProv.object objH
          and obT = ObjectProv.object objT

          val ob = Object.mkOcons (obH,obT)

          and prov =
              if ObjectProv.containsThms objH orelse
                 ObjectProv.containsThms objT then
                ObjectProv.Pcons (objH,objT)
              else
                ObjectProv.Pnull

          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      (* Types *)

      | Command.TypeVar =>
        let
          val (stack,objN) = ObjectStack.pop1 stack

          val obN = ObjectProv.object objN

          val ob = Object.mkOtypeVar obN
          and prov = ObjectProv.Pnull
          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      | Command.TypeOp =>
        let
          val (stack,objN,objL) = ObjectStack.pop2 stack

          val obN = ObjectProv.object objN
          and obL = ObjectProv.object objL

          val obN = Object.interpretType interpretation obN

          val ob = Object.mkOtypeOp (obN,obL)
          and prov = ObjectProv.Pnull
          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      (* Terms *)

      | Command.Var =>
        let
          val (stack,objN,objT) = ObjectStack.pop2 stack

          val obN = ObjectProv.object objN
          and obT = ObjectProv.object objT

          val ob = Object.mkOtermVar (obN,obT)
          and prov = ObjectProv.Pnull
          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      | Command.Const =>
        let
          val (stack,objN,objT) = ObjectStack.pop2 stack

          val obN = ObjectProv.object objN
          and obT = ObjectProv.object objT

          val obN = Object.interpretConst interpretation obN

          val ob = Object.mkOtermConst (obN,obT)
          and prov = ObjectProv.Pnull
          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      | Command.Comb =>
        let
          val (stack,objF,objA) = ObjectStack.pop2 stack

          val obF = ObjectProv.object objF
          and obA = ObjectProv.object objA

          val ob = Object.mkOtermComb (obF,obA)
          and prov = ObjectProv.Pnull
          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      | Command.Abs =>
        let
          val (stack,objV,objB) = ObjectStack.pop2 stack

          val obV = ObjectProv.object objV
          and obB = ObjectProv.object objB

          val ob = Object.mkOtermAbs (obV,obB)
          and prov = ObjectProv.Pnull
          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      (* Theorems *)

      | Command.Thm =>
        let
          val (stack,objH,objC) = ObjectStack.pop2 stack

          val obH = ObjectProv.object objH
          and obC = ObjectProv.object objC

          val seq =
              {hyp = TermAlphaSet.fromList (Object.destOterms obH),
               concl = Object.destOterm obC}

          val (th,inf) =
              case ObjectThms.search known seq of
                SOME (th,objS) => (th, ObjectProv.Isaved objS)
              | NONE =>
                case ObjectThms.search saved seq of
                  SOME (th,objS) => (th, ObjectProv.Isaved objS)
                | NONE =>
                  case simulate interpretation stack seq of
                    SOME th => (th,ObjectProv.Isimulated)
                  | NONE =>
                    case ObjectStack.search stack seq of
                      SOME (th,objS) => (th, ObjectProv.Istack objS)
                    | NONE =>
                      let
                        val th = Thm.axiom seq
(*OpenTheoryTrace1
                        val () = trace ("making new axiom in " ^
                                        ObjectStack.topCallToString stack ^
                                        ":\n" ^ thmToString th ^ "\n")
*)
                      in
                        (th,ObjectProv.Iaxiom)
                      end

          val ob = Object.Othm th
          and prov = ObjectProv.Pthm (if savable then inf else ObjectProv.Iaxiom)
          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      (* Function calls *)

      | Command.Call =>
        let
          val (stack,objA,objN) = ObjectStack.pop2 stack

          val obA = ObjectProv.object objA
          and obN = ObjectProv.object objN

          val _ = not (Object.isOcall obA) orelse
                  raise Error "cannot use an Ocall object as a call argument"

          val n = Object.destOname obN

          val n = Interpretation.interpretRule interpretation n

(*OpenTheoryTrace2
          val traceCall = null (ObjectStack.callStack stack)
(*OpenTheoryTrace3
          val traceCall = true
*)
          val () =
              if not traceCall then ()
              else
                trace
                  ("call: " ^ Name.toString n ^ "\n" ^ "  stack = [" ^
                   Int.toString (ObjectStack.size stack) ^ "], call stack = [" ^
                   Int.toString (length (ObjectStack.callStack stack)) ^ "]\n")

          val () = if not traceCall then ()
                   else Print.trace Object.pp "  input" obA
*)

          val ob = Object.Ocall n
          and prov = ObjectProv.Pcall objA
          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
          val stack = ObjectStack.push stack objA
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      | Command.Return =>
        let
          val (stack,objR,objN) = ObjectStack.pop2 stack

          val ObjectProv.Object {object = obR, provenance = provR, ...} = objR
          and obN = ObjectProv.object objN

          val _ = not (Object.isOcall obR) orelse
                  raise Error "cannot use an Ocall object as a return value"

          val n = Object.destOname obN
          val n = Interpretation.interpretRule interpretation n

          val (stack,n') = ObjectStack.popCall stack

          val _ = Name.equal n' n orelse
                  raise Error ("call " ^ Name.toString n' ^
                               " matched by return " ^ Name.toString n)
(*OpenTheoryTrace2
          val traceReturn = null (ObjectStack.callStack stack)
(*OpenTheoryTrace3
          val traceReturn = true
*)
          val () =
              if not traceReturn then ()
              else
                trace
                  ("return: " ^ Name.toString n ^ "\n" ^
                   "  stack = [" ^ Int.toString (ObjectStack.size stack) ^
                   "], call stack = [" ^
                   Int.toString (length (ObjectStack.callStack stack)) ^ "]\n")

          val () = if not traceReturn then ()
                   else Print.trace Object.pp "  return" obR
*)
          val ob = obR

          and prov =
              if not (ObjectProv.containsThms objR) then ObjectProv.Pnull
              else if savable then ObjectProv.Preturn objR
              else provR

          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      (* Dictionary *)

      | Command.Def =>
        let
          val (stack,objI) = ObjectStack.pop1 stack
          val obI = ObjectProv.object objI

          val objD = ObjectStack.peek stack 0
          val obD = ObjectProv.object objD

          val _ = not (Object.isOcall obD) orelse
                  raise Error "cannot def an Ocall object"

          val i = Object.destOnum obI

          val dict = ObjectDict.define dict (i,objD)
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      | Command.Ref =>
        let
          val (stack,objI) = ObjectStack.pop1 stack

          val obI = ObjectProv.object objI
          val i = Object.destOnum obI

          val objD = ObjectDict.refer dict i
          val obD = ObjectProv.object objD

          val ob = obD

          and prov =
              if not (ObjectProv.containsThms objD) then ObjectProv.Pnull
              else if savable then ObjectProv.Pref objD
              else ObjectProv.provenance objD

          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      | Command.Remove =>
        let
          val (stack,objI) = ObjectStack.pop1 stack

          val obI = ObjectProv.object objI
          val i = Object.destOnum obI

          val (dict,objD) = ObjectDict.remove dict i
          val obD = ObjectProv.object objD

          val ob = obD

          and prov =
              if not (ObjectProv.containsThms objD) then ObjectProv.Pnull
              else if savable then ObjectProv.Pref objD
              else ObjectProv.provenance objD

          and call = if savable then ObjectStack.topCall stack else NONE

          val obj =
              ObjectProv.mk
                {object = ob,
                 provenance = prov,
                 call = call}

          val stack = ObjectStack.push stack obj
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      (* General *)

      | Command.Pop =>
        let
          val stack = ObjectStack.pop stack 1
        in
          State {stack = stack, dict = dict, saved = saved}
        end

      | Command.Save =>
        let
          val objT = ObjectStack.peek stack 0

          val saved = ObjectThms.add saved objT
        in
          State {stack = stack, dict = dict, saved = saved}
        end
    end
    handle Error err =>
      let
(*OpenTheoryDebug
        val State {stack,...} = state

        val ppStack =
            Print.ppMap
              (map ObjectProv.object o ObjectStack.objects)
              (Print.ppList Object.pp)
        val () = Print.trace ppStack "ObjectRead.execute: stack" stack
*)
        val err = "ObjectRead.execute " ^ Command.toString cmd ^ ": " ^ err
      in
        raise Error err
      end;

fun executeStream data =
    let
      fun process (cmd,state) = execute data cmd state
    in
      fn strm => fn state => Stream.foldl process state strm
    end;

(* ------------------------------------------------------------------------- *)
(* Executing text files.                                                     *)
(* ------------------------------------------------------------------------- *)

local
  (* Comment lines *)

  fun isComment l =
      case List.find (not o Char.isSpace) l of
        NONE => true
      | SOME #"#" => true
      | _ => false;
in
  fun executeTextFile {savable,known,interpretation,filename} state =
      let
        (* Estimating parse error line numbers *)

        val lines = Stream.fromTextFile {filename = filename}

        val {chars,parseErrorLocation} = Parse.initialize {lines = lines}
      in
        (let
           (* The character stream *)

           val chars = Stream.filter (not o isComment) chars

           val chars = Parse.everything Parse.any chars

           (* The command stream *)

           val commands = Parse.everything Command.spacedParser chars

           val data =
               {savable = savable,
                known = known,
                interpretation = interpretation}
         in
           executeStream data commands state
         end
         handle Parse.NoParse => raise Error "parse error")
        handle Error err =>
          raise Error ("error in file \"" ^ filename ^ "\" " ^
                       parseErrorLocation () ^ "\n" ^ err)
      end;
end;

end