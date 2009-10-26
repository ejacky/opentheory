(* ========================================================================= *)
(* REQUIRED THEORY PACKAGES                                                  *)
(* Copyright (c) 2009 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

structure PackageRequire :> PackageRequire =
struct

open Useful;

(* ------------------------------------------------------------------------- *)
(* Constants.                                                                *)
(* ------------------------------------------------------------------------- *)

val closeBlockString = "}"
and interpretKeywordString = "interpret"
and openBlockString = "{"
and packageKeywordString = "package"
and requireKeywordString = "require"
and separatorString = ":";

(* ------------------------------------------------------------------------- *)
(* A type of required theory packages.                                       *)
(* ------------------------------------------------------------------------- *)

type name = string;

datatype require =
    Require of
      {name : name,
       requires : name list,
       interpretation : Interpretation.interpretation,
       package : PackageName.name};

(* ------------------------------------------------------------------------- *)
(* Require block constraints.                                                *)
(* ------------------------------------------------------------------------- *)

datatype constraint =
    RequireConstraint of name
  | InterpretConstraint of Interpretation.rewrite
  | PackageConstraint of PackageName.name;

fun destRequireConstraint c =
    case c of
      RequireConstraint r => SOME r
    | _ => NONE;

fun destInterpretConstraint c =
    case c of
      InterpretConstraint r => SOME r
    | _ => NONE;

fun destPackageConstraint c =
    case c of
      PackageConstraint p => SOME p
    | _ => NONE;

fun mkRequire (name,cs) =
    let
      val requires = List.mapPartial destRequireConstraint cs

      val rws = List.mapPartial destInterpretConstraint cs

      val interpretation = Interpretation.fromRewriteList rws

      val package =
          case List.mapPartial destPackageConstraint cs of
            [] => raise Error "no package specified in require block"
          | [p] => p
          | _ :: _ :: _ =>
            raise Error "multiple packages specified in require block"
    in
      Require
        {name = name,
         requires = requires,
         interpretation = interpretation,
         package = package}
    end;

fun destRequire req =
    let
      val Require {name,requires,interpretation,package} = req

      val reqs = map RequireConstraint requires

      val rws = Interpretation.toRewriteList interpretation

      val ints = map InterpretConstraint rws

      val cs = reqs @ ints @ [PackageConstraint package]
    in
      (name,cs)
    end;

(* ------------------------------------------------------------------------- *)
(* Pretty printing.                                                          *)
(* ------------------------------------------------------------------------- *)

val ppCloseBlock = Print.addString closeBlockString
and ppInterpretKeyword = Print.addString interpretKeywordString
and ppOpenBlock = Print.addString openBlockString
and ppPackageKeyword = Print.addString packageKeywordString
and ppRequireKeyword = Print.addString requireKeywordString
and ppSeparator = Print.addString separatorString;

fun ppBlock ppX x =
    Print.blockProgram Print.Consistent 0
      [Print.blockProgram Print.Consistent 2
         [ppOpenBlock,
          Print.addBreak 1,
          ppX x],
       Print.addBreak 1,
       ppCloseBlock];

val ppName = Print.ppString;

local
  fun ppNameValue ppN ppV =
      Print.program
        [ppN,
         ppSeparator,
         Print.addString " ",
         ppV];
in
  fun ppConstraint c =
      case c of
        RequireConstraint r =>
        ppNameValue ppRequireKeyword (ppName r)
      | InterpretConstraint r =>
        ppNameValue ppInterpretKeyword (Interpretation.ppRewrite r)
      | PackageConstraint p =>
        ppNameValue ppPackageKeyword (PackageName.pp p);
end;

fun ppConstraintList cs =
    Print.blockProgram Print.Consistent 0
      (map (fn c => Print.sequence (ppConstraint c) Print.addNewline) cs);

fun pp req =
    let
      val (name,cs) = destRequire req
    in
      Print.blockProgram Print.Consistent 0
        [ppRequireKeyword,
         Print.addString " ",
         ppName name,
         Print.addString " ",
         ppBlock ppConstraintList cs]
    end;

val ppList =
    let
      fun ppReq req =
          Print.program [Print.addNewline, pp req, Print.addNewline]
    in
      Print.blockProgram Print.Consistent 0 o map ppReq
    end;

(* ------------------------------------------------------------------------- *)
(* Parsing.                                                                  *)
(* ------------------------------------------------------------------------- *)

local
  infixr 9 >>++
  infixr 8 ++
  infixr 7 >>
  infixr 6 ||

  open Parse;

  val closeBlockParser = exactString closeBlockString
  and interpretKeywordParser = exactString interpretKeywordString
  and openBlockParser = exactString openBlockString
  and packageKeywordParser = exactString packageKeywordString
  and requireKeywordParser = exactString requireKeywordString
  and separatorParser = exactString separatorString;

  val nameParser =
      let
        fun isInitialChar c = Char.isLower c

        fun isSubsequentChar c = Char.isAlphaNum c
      in
        (some isInitialChar ++ many (some isSubsequentChar)) >>
        (fn (c,cs) => implode (c :: cs))
      end;

  val requireConstraintParser =
      (requireKeywordParser ++ manySpace ++
       separatorParser ++ manySpace ++
       nameParser) >>
      (fn ((),((),((),((),r)))) => RequireConstraint r);

  val interpretConstraintParser =
      (interpretKeywordParser ++ manySpace ++
       separatorParser ++ manySpace ++
       Interpretation.parserRewrite) >>
      (fn ((),((),((),((),r)))) => InterpretConstraint r);

  val packageConstraintParser =
      (packageKeywordParser ++ manySpace ++
       separatorParser ++ manySpace ++
       PackageName.parser) >>
      (fn ((),((),((),((),p)))) => PackageConstraint p);

  val constraintParser =
      requireConstraintParser ||
      interpretConstraintParser ||
      packageConstraintParser;

  val constraintSpaceParser = constraintParser ++ manySpace >> fst;

  val requireParser =
      (requireKeywordParser ++ atLeastOneSpace ++
       nameParser ++ manySpace ++
       openBlockParser ++ manySpace ++
       many constraintSpaceParser ++
       closeBlockParser) >>
      (fn ((),((),(n,((),((),((),(cs,()))))))) => mkRequire (n,cs));

  val requireSpaceParser = requireParser ++ manySpace >> fst;
in
  val parserName = nameParser;

  val parser = manySpace ++ requireSpaceParser >> snd;

  val parserList = manySpace ++ many requireSpaceParser >> snd;
end;

end