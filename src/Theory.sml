(* ========================================================================= *)
(* HIGHER ORDER LOGIC THEORIES                                               *)
(* Copyright (c) 2009 Joe Leslie-Hurd, distributed under the MIT license     *)
(* ========================================================================= *)

structure Theory :> Theory =
struct

open Useful;

(* ------------------------------------------------------------------------- *)
(* A type of theories.                                                       *)
(* ------------------------------------------------------------------------- *)

type id = int;

datatype theory =
    Theory of
      {id : id,
       theory : theory'}

and theory' =
    Theory' of
      {imports : theory list,
       node : node,
       interpretation : Interpretation.interpretation,
       article : Article.article}

and node =
    Article of
      {filename : string}
  | Package of
      {package : PackageNameVersion.nameVersion,
       checksum : Checksum.checksum option,
       nested : nested}
  | Union

and nested = Nested of (PackageTheory.name * theory) list;

(* ------------------------------------------------------------------------- *)
(* Theory IDs.                                                             *)
(* ------------------------------------------------------------------------- *)

val newId : unit -> id =
    let
      val counter = ref 0
    in
      fn () =>
         let
           val ref count = counter
           val () = counter := count + 1
         in
           count
         end
    end;

fun id (Theory {id = x, ...}) = x;

fun equalId i thy = i = id thy;

fun compare (Theory {id = i1, ...}, Theory {id = i2, ...}) =
    Int.compare (i1,i2);

fun equal thy1 thy2 = (id thy1) = (id thy2);

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

fun mk thy' =
    let
(*OpenTheoryDebug
      val Theory' {node,article,...} = thy'

      val () =
          case node of
            Article _ => ()
          | _ =>
            if Inference.null (Article.inference article) then ()
            else raise Bug "Theory.mk: non-article with non-null inferences"
*)

      val id = newId ()
    in
      Theory
        {id = id,
         theory = thy'}
    end;

fun dest (Theory {theory = x, ...}) = x;

fun imports thy =
    let
      val Theory' {imports = x, ...} = dest thy
    in
      x
    end;

fun node thy =
    let
      val Theory' {node = x, ...} = dest thy
    in
      x
    end;

fun interpretation thy =
    let
      val Theory' {interpretation = x, ...} = dest thy
    in
      x
    end;

fun article thy =
    let
      val Theory' {article = x, ...} = dest thy
    in
      x
    end;

(* ------------------------------------------------------------------------- *)
(* Article theories.                                                         *)
(* ------------------------------------------------------------------------- *)

fun isArticleNode node =
    case node of
      Article _ => true
    | _ => false;

fun isArticle thy = isArticleNode (node thy);

(* ------------------------------------------------------------------------- *)
(* Package theories.                                                         *)
(* ------------------------------------------------------------------------- *)

fun destPackageNode node =
    case node of
      Package {package = nv, ...} => SOME nv
    | _ => NONE;

fun destPackage thy = destPackageNode (node thy);

fun isPackage thy = Option.isSome (destPackage thy);

(* ------------------------------------------------------------------------- *)
(* Union theories.                                                           *)
(* ------------------------------------------------------------------------- *)

fun isUnionNode node =
    case node of
      Union => true
    | _ => false;

fun isUnion thy = isUnionNode (node thy);

(* ------------------------------------------------------------------------- *)
(* Nested theories.                                                          *)
(* ------------------------------------------------------------------------- *)

val existsArticleNested =
    let
      fun isArt (_ : PackageTheory.name, thy) = isArticle thy
    in
      fn Nested thys => List.exists isArt thys
    end;

fun peekNested name (Nested thys) =
    case List.filter (PackageName.equal name o fst) thys of
      [] => NONE
    | [(_,thy)] => SOME thy
    | _ :: _ :: _ =>
      let
        val err =
            "Theory.peekNested: multiple " ^
            PackageName.toString name ^ " theories"
      in
        raise Error err
      end;

val mainNested =
    let
      fun isMain (name, _ : theory) = PackageTheory.isMainName name
    in
      fn Nested thys =>
         case List.filter isMain thys of
           [] => raise Error "Theory.mainNested: no main nested theory"
         | [(_,thy)] => thy
         | _ :: _ :: _ =>
           raise Error "Theory.mainNested: multiple main nested theories"
    end;

(* ------------------------------------------------------------------------- *)
(* Primitive theory packages cannot be replaced with their contents.         *)
(* ------------------------------------------------------------------------- *)

fun isPrimitiveNode node =
    case node of
      Article _ => true
    | Package {nested,...} => existsArticleNested nested
    | Union => false;

fun isPrimitive thy = isPrimitiveNode (node thy);

(* ------------------------------------------------------------------------- *)
(* Theory summaries.                                                         *)
(* ------------------------------------------------------------------------- *)

fun summary thy =
    let
      val art = article thy

      val ths = Article.thms art
    in
      Summary.fromThms ths
    end;

(* ------------------------------------------------------------------------- *)
(* Pretty printing.                                                          *)
(* ------------------------------------------------------------------------- *)

val ppId = Print.ppBracket "<" ">" Print.ppInt;

fun pp thy =
    Print.consistentBlock 0
      [Print.ppString "Theory",
       ppId (id thy)];

end

structure TheoryOrdered =
struct type t = Theory.theory val compare = Theory.compare end

structure TheoryMap =
struct

local
  structure S = KeyMap (TheoryOrdered);
in
  open S;
end;

fun pp ppX =
    let
      val ppTX = Print.ppOp2 " =>" Theory.pp ppX
    in
      fn m =>
         Print.consistentBlock 0
           [Print.ppString "TheoryMap",
            Print.ppList ppTX (toList m)]
    end;

end

structure TheorySet =
struct

local
  structure S = ElementSet (TheoryMap);
in
  open S;
end;

val inference =
    let
      fun add (thy,acc) =
          Inference.union acc (Article.inference (Theory.article thy))
    in
      foldl add Inference.empty
    end;

val article =
    let
      fun add (thy,acc) = Article.union acc (Theory.article thy)
    in
      foldl add Article.empty
    end;

fun summary set = Article.summary (article set);

end
