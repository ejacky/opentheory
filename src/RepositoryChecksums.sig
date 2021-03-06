(* ========================================================================= *)
(* REPOSITORY PACKAGE CHECKSUMS                                              *)
(* Copyright (c) 2010 Joe Leslie-Hurd, distributed under the MIT license     *)
(* ========================================================================= *)

signature RepositoryChecksums =
sig

(* ------------------------------------------------------------------------- *)
(* Checksums filenames.                                                      *)
(* ------------------------------------------------------------------------- *)

val mkFilename : PackageName.name -> {filename : string}

val destFilename : {filename : string} -> PackageName.name option

val isFilename : {filename : string} -> bool

(* ------------------------------------------------------------------------- *)
(* Creating a new package checksums file.                                    *)
(* ------------------------------------------------------------------------- *)

val create : {filename : string} -> unit

(* ------------------------------------------------------------------------- *)
(* A type of repository package checkums.                                    *)
(* ------------------------------------------------------------------------- *)

type checksums

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

val mk :
    {system : RepositorySystem.system,
     filename : string,
     updateFrom : {url : string} option} -> checksums

val filename : checksums -> {filename : string}

(* ------------------------------------------------------------------------- *)
(* Looking up packages.                                                      *)
(* ------------------------------------------------------------------------- *)

val peek :
    checksums -> PackageNameVersion.nameVersion -> Checksum.checksum option

val member : PackageNameVersion.nameVersion -> checksums -> bool

(* ------------------------------------------------------------------------- *)
(* Package versions.                                                         *)
(* ------------------------------------------------------------------------- *)

val previousNameVersion :
    checksums -> PackageNameVersion.nameVersion ->
    (PackageNameVersion.nameVersion * Checksum.checksum) option

val latestNameVersion :
    checksums -> PackageName.name ->
    (PackageNameVersion.nameVersion * Checksum.checksum) option

(* ------------------------------------------------------------------------- *)
(* Adding a new package.                                                     *)
(* ------------------------------------------------------------------------- *)

val add :
    checksums -> PackageNameVersion.nameVersion -> Checksum.checksum -> unit

(* ------------------------------------------------------------------------- *)
(* Deleting a package.                                                       *)
(* ------------------------------------------------------------------------- *)

val delete : checksums -> PackageNameVersion.nameVersion -> unit

(* ------------------------------------------------------------------------- *)
(* Updating the package checksums from a remote repository.                  *)
(* ------------------------------------------------------------------------- *)

val update : checksums -> {url : string} -> unit

end
