(* ========================================================================= *)
(* PACKAGE DIRECTORY OPERATION ERRORS                                        *)
(* Copyright (c) 2010 Joe Hurd, distributed under the GNU GPL version 2      *)
(* ========================================================================= *)

structure DirectoryError :> DirectoryError =
struct

open Useful;

(* ------------------------------------------------------------------------- *)
(* A type of directory operation errors.                                     *)
(* ------------------------------------------------------------------------- *)

datatype error =
    AncestorNotOnRepo of
      PackageNameVersion.nameVersion * DirectoryRepo.repo
  | AncestorWrongChecksumOnRepo of
      PackageNameVersion.nameVersion * DirectoryRepo.repo
  | AlreadyInstalled of
      PackageNameVersion.nameVersion
  | AlreadyOnRepo of
      PackageNameVersion.nameVersion * DirectoryRepo.repo
  | AlreadyStaged of
      PackageNameVersion.nameVersion
  | FilenameClash of
      {srcs : {name : string, filename : string option} list,
       dest : {filename : string}}
  | InstalledDescendent of
      PackageNameVersion.nameVersion
  | NotInstalled of
      PackageNameVersion.nameVersion
  | NotOnRepo of
      PackageNameVersion.nameVersion * DirectoryRepo.repo
  | NotStaged of
      PackageNameVersion.nameVersion
  | TagError of
      PackageTag.name * string
  | UninstalledParent of
      PackageNameVersion.nameVersion
  | WrongChecksumOnRepo of
      PackageNameVersion.nameVersion * DirectoryRepo.repo;

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

fun destAlreadyInstalled err =
    case err of
      AlreadyInstalled nv => SOME nv
    | _ => NONE;

fun isAlreadyInstalled err =
    Option.isSome (destAlreadyInstalled err);

fun removeAlreadyInstalled errs =
    let
      val (xs,errs) = List.partition isAlreadyInstalled errs

      val removed = not (List.null xs)
    in
      (removed,errs)
    end;

fun destAlreadyStaged err =
    case err of
      AlreadyStaged nv => SOME nv
    | _ => NONE;

fun isAlreadyStaged err =
    Option.isSome (destAlreadyStaged err);

fun removeAlreadyStaged errs =
    let
      val (xs,errs) = List.partition isAlreadyStaged errs

      val removed = not (List.null xs)
    in
      (removed,errs)
    end;

fun destInstalledDescendent err =
    case err of
      InstalledDescendent nv => SOME nv
    | _ => NONE;

fun isInstalledDescendent err =
    Option.isSome (destInstalledDescendent err);

val removeInstalledDescendent =
    let
      fun remove (err,(nvs,errs)) =
          case destInstalledDescendent err of
            SOME nv => (nv :: nvs, errs)
          | NONE => (nvs, err :: errs)
    in
      List.foldr remove ([],[])
    end;

fun destUninstalledParent err =
    case err of
      UninstalledParent nv => SOME nv
    | _ => NONE;

fun isUninstalledParent err =
    Option.isSome (destUninstalledParent err);

val removeUninstalledParent =
    let
      fun remove (err,(nvs,errs)) =
          case destUninstalledParent err of
            SOME nv => (nv :: nvs, errs)
          | NONE => (nvs, err :: errs)
    in
      List.foldr remove ([],[])
    end;

(* ------------------------------------------------------------------------- *)
(* Fatal errors.                                                             *)
(* ------------------------------------------------------------------------- *)

fun isFatal err =
    case err of
      AncestorNotOnRepo _ => true
    | AncestorWrongChecksumOnRepo _ => true
    | AlreadyInstalled _ => true
    | AlreadyOnRepo _ => true
    | AlreadyStaged _ => true
    | FilenameClash _ => true
    | InstalledDescendent _ => true
    | NotInstalled _ => true
    | NotOnRepo _ => true
    | NotStaged _ => true
    | TagError _ => true
    | UninstalledParent _ => true
    | WrongChecksumOnRepo _ => true

val existsFatal = List.exists isFatal;

(* ------------------------------------------------------------------------- *)
(* Pretty-printing.                                                          *)
(* ------------------------------------------------------------------------- *)

fun toString err =
    (if isFatal err then "Error" else "Warning") ^ ": " ^
    (case err of
       AncestorNotOnRepo (namever,repo) =>
       "depends on package " ^ PackageNameVersion.toString namever ^
       " missing on " ^ DirectoryRepo.toString repo
     | AncestorWrongChecksumOnRepo (namever,repo) =>
       "depends on package " ^ PackageNameVersion.toString namever ^
       " which has different checksum on " ^ DirectoryRepo.toString repo
     | AlreadyInstalled namever =>
       "package " ^ PackageNameVersion.toString namever ^
       " is already installed"
     | AlreadyOnRepo (namever,repo) =>
       "package " ^ PackageNameVersion.toString namever ^
       " already exists on " ^ DirectoryRepo.toString repo
     | AlreadyStaged namever =>
       "package " ^ PackageNameVersion.toString namever ^
       " is already staged for installation"
     | FilenameClash {srcs,dest} =>
       let
         fun toStringSrc {name,filename} =
             name ^
             (case filename of
                SOME sf => ": " ^ PackageTheory.toStringFilename {filename = sf}
              | NONE => "")
       in
         "filename clash in package directory:\n" ^
         "Package file " ^ PackageTheory.toStringFilename dest ^ "\n" ^
         " is target for " ^ join "\n  and also for " (List.map toStringSrc srcs)
       end
     | InstalledDescendent namever =>
       "in use by installed package: " ^ PackageNameVersion.toString namever
     | NotInstalled namever =>
       "package " ^ PackageNameVersion.toString namever ^
       " is not installed"
     | NotOnRepo (namever,repo) =>
       "package " ^ PackageNameVersion.toString namever ^
       " is not on " ^ DirectoryRepo.toString repo
     | NotStaged namever =>
       "package " ^ PackageNameVersion.toString namever ^
       " is not staged for installation"
     | TagError (tag,msg) =>
       "package " ^ PackageName.toString tag ^ " information " ^ msg
     | UninstalledParent namever =>
       "depends on uninstalled package: " ^ PackageNameVersion.toString namever
     | WrongChecksumOnRepo (namever,repo) =>
       "package " ^ PackageNameVersion.toString namever ^
       " has different checksum on " ^ DirectoryRepo.toString repo);

fun toStringList errs = join "\n" (List.map toString errs);

end
