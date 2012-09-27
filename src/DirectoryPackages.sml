(* ========================================================================= *)
(* INSTALLED PACKAGE DIRECTORY                                               *)
(* Copyright (c) 2010 Joe Hurd, distributed under the MIT license            *)
(* ========================================================================= *)

structure DirectoryPackages :> DirectoryPackages =
struct

open Useful;

(* ------------------------------------------------------------------------- *)
(* A pure type of installed packages.                                        *)
(* ------------------------------------------------------------------------- *)

datatype purePackages =
    PurePackages of
      {pkgs : PackageInfo.info PackageNameVersionMap.map,
       latest : PackageNameVersion.nameVersion PackageNameMap.map};

val emptyPurePackages =
    let
      val pkgs = PackageNameVersionMap.new ()
      and latest = PackageNameMap.new ()
    in
      PurePackages
        {pkgs = pkgs,
         latest = latest}
    end;

fun sizePurePackages (PurePackages {pkgs,...}) =
    PackageNameVersionMap.size pkgs;

fun peekPurePackages (PurePackages {pkgs,...}) namever =
    PackageNameVersionMap.peek pkgs namever;

fun memberPurePackages namever (PurePackages {pkgs,...}) =
    PackageNameVersionMap.inDomain namever pkgs;

fun toNameVersionSetPurePackages (PurePackages {pkgs,...}) =
    PackageNameVersionSet.domain pkgs;

fun latestNameVersionPurePackages (PurePackages {latest,...}) =
    PackageNameMap.peek latest;

fun appPurePackages f =
    let
      fun f' (_,info) = f info
    in
      fn PurePackages {pkgs,...} => PackageNameVersionMap.app f' pkgs
    end;

fun foldlPurePackages f =
    let
      fun f' (_,info,acc) = f (info,acc)
    in
      fn acc => fn PurePackages {pkgs,...} =>
         PackageNameVersionMap.foldl f' acc pkgs
    end;

fun addPurePackages (PurePackages {pkgs,latest}) info =
    let
      val namever = PackageInfo.nameVersion info

      val name = PackageNameVersion.name namever

      val pkgs = PackageNameVersionMap.insert pkgs (namever,info)

      val later =
          case PackageNameMap.peek latest name of
            NONE => true
          | SOME nv =>
            let
              val ver = PackageNameVersion.version namever
              and v = PackageNameVersion.version nv
            in
              case PackageVersion.compare (ver,v) of
                LESS => false
              | EQUAL => false
              | GREATER => true
            end

      val latest =
          if later then PackageNameMap.insert latest (name,namever)
          else latest
    in
      PurePackages
        {pkgs = pkgs,
         latest = latest}
    end;

fun deletePurePackages (PurePackages {pkgs,latest}) namever =
    let
      val name = PackageNameVersion.name namever

      val pkgs = PackageNameVersionMap.delete pkgs namever

      val obsolete =
          case PackageNameMap.peek latest name of
            NONE => raise Bug "DirectoryPackages.deletePurePackages"
          | SOME nv => not (PackageNameVersion.equal nv namever)

      val latest =
          if obsolete then latest
          else
            case PackageNameVersionMap.latestNameVersion pkgs name of
              NONE => PackageNameMap.delete latest name
            | SOME (nv,_) => PackageNameMap.insert latest (name,nv)
    in
      PurePackages
        {pkgs = pkgs,
         latest = latest}
    end;

fun removePurePackages pkgs namever =
    if memberPurePackages namever pkgs then deletePurePackages pkgs namever
    else pkgs;

fun packageDependencyPurePackages pkgs dep namever =
    if PackageDependency.member namever dep then NONE
    else
      let
        val latest = latestNameVersionPurePackages pkgs

        val info =
            case peekPurePackages pkgs namever of
              SOME i => i
            | NONE => raise Bug "DirectoryPackages.addDependencyPurePackages"
      in
        SOME (PackageDependency.addInfo latest dep info)
      end;

fun completeDependencyPurePackages pkgs dep =
    if PackageDependency.size dep = sizePurePackages pkgs then NONE
    else
      let
        val latest = latestNameVersionPurePackages pkgs

        fun add (info,dep) = PackageDependency.addInfo latest dep info
      in
        SOME (foldlPurePackages add dep pkgs)
      end;

fun nameVersionsPurePackages pkgs name =
    PackageNameVersionSet.filter
      (PackageNameVersion.equalName name)
      (toNameVersionSetPurePackages pkgs);

fun fromDirectoryPurePackages sys =
    let
      fun add ({filename},pkgs) =
          let
            val namever =
                PackageNameVersion.fromString (OS.Path.file filename)

            val info =
                PackageInfo.mk
                  {system = sys,
                   nameVersion = namever,
                   directory = filename}
          in
            addPurePackages pkgs info
          end
    in
      fn dir => List.foldl add emptyPurePackages (readDirectory dir)
    end;

(* ------------------------------------------------------------------------- *)
(* A type of installed packages.                                             *)
(* ------------------------------------------------------------------------- *)

datatype packages =
    Packages of
      {system : DirectorySystem.system,
       directory : string,
       packages : purePackages option ref,
       dependency : PackageDependency.dependency ref,
       checksums : DirectoryChecksums.checksums};

(* ------------------------------------------------------------------------- *)
(* Constructors and destructors.                                             *)
(* ------------------------------------------------------------------------- *)

fun mk {system = sys, rootDirectory = rootDir} =
    let
      val {directory} =
          DirectoryPath.mkPackagesDirectory {rootDirectory = rootDir}

      val packages = ref NONE

      val dependency = ref PackageDependency.empty

      val checksums =
          let
            val {filename} =
                DirectoryPath.mkInstalledFilename {rootDirectory = rootDir}
          in
            DirectoryChecksums.mk
              {system = sys,
               filename = filename,
               updateFrom = NONE}
          end
    in
      Packages
        {system = sys,
         directory = directory,
         packages = packages,
         dependency = dependency,
         checksums = checksums}
    end;

fun directory (Packages {directory = x, ...}) = {directory = x};

fun packages pkgs =
    let
      val Packages {system = sys, directory = dir, packages = rox, ...} = pkgs

      val ref ox = rox
    in
      case ox of
        SOME x => x
      | NONE =>
        let
          val x = fromDirectoryPurePackages sys {directory = dir}

          val () = rox := SOME x
        in
          x
        end
    end;

fun packageDependency pkgs namever =
    let
      val Packages {dependency as ref dep, ...} = pkgs
    in
      case packageDependencyPurePackages (packages pkgs) dep namever of
        NONE => dep
      | SOME dep =>
        let
          val () = dependency := dep
        in
          dep
        end
    end;

fun completeDependency pkgs =
    let
      val Packages {dependency as ref dep, ...} = pkgs
    in
      case completeDependencyPurePackages (packages pkgs) dep of
        NONE => dep
      | SOME dep =>
        let
          val () = dependency := dep
        in
          dep
        end
    end;

fun checksums (Packages {checksums = x, ...}) = x;

fun size pkgs = sizePurePackages (packages pkgs);

(* ------------------------------------------------------------------------- *)
(* Looking up installed packages.                                            *)
(* ------------------------------------------------------------------------- *)

fun peek pkgs namever = peekPurePackages (packages pkgs) namever;

fun get pkgs namever =
    case peek pkgs namever of
      SOME info => info
    | NONE => raise Error "DirectoryPackages.get";

fun member namever pkgs = memberPurePackages namever (packages pkgs);

fun checksum pkgs namever = DirectoryChecksums.peek (checksums pkgs) namever;

(* ------------------------------------------------------------------------- *)
(* Installed package versions.                                               *)
(* ------------------------------------------------------------------------- *)

fun nameVersions pkgs name =
    nameVersionsPurePackages (packages pkgs) name;

fun latestNameVersion pkgs name =
    latestNameVersionPurePackages (packages pkgs) name;

fun isLatestNameVersion pkgs namever =
    let
      val PackageNameVersion.NameVersion' {name,version} =
          PackageNameVersion.dest namever
    in
      case latestNameVersion pkgs name of
        NONE => false
      | SOME nv => PackageNameVersion.equalVersion version nv
    end;

local
  fun complaint name =
      "package " ^ PackageName.toString name ^ " is not installed";
in
  fun getLatestNameVersion pkgs name =
      case latestNameVersion pkgs name of
        SOME namever => namever
      | NONE => raise Error (complaint name);

  fun warnLatestNameVersion pkgs name =
      let
        val namevero = latestNameVersion pkgs name

        val () =
            if Option.isSome namevero then ()
            else warn (complaint name)
      in
        namevero
      end;
end;

local
  fun consOption x xso =
      case xso of
        NONE => NONE
      | SOME xs => SOME (x :: xs);

  fun addLatest pkgs (name,nvs) =
      case warnLatestNameVersion pkgs name of
        SOME nv => consOption nv nvs
      | NONE => NONE;
in
  fun warnLatestNameVersionList pkgs names =
      case List.foldl (addLatest pkgs) (SOME []) names of
        NONE => NONE
      | SOME namevers => SOME (List.rev namevers);
end;

fun previousNameVersion pkgs namever =
    let
(*OpenTheoryDebug
      val () =
          if member namever pkgs then ()
          else
            let
              val bug =
                  "DirectoryPackages.previousNameVersion: unknown package"
            in
              raise Bug bug
            end
*)
      val chks = checksums pkgs
    in
      case DirectoryChecksums.previousNameVersion chks namever of
        SOME (nv,_) => SOME nv
      | NONE => NONE
    end;

(* ------------------------------------------------------------------------- *)
(* Package authors.                                                          *)
(* ------------------------------------------------------------------------- *)

local
  fun authorInSet pkgs auths namever =
      let
(*OpenTheoryDebug
        val () =
            if member namever pkgs then ()
            else raise Bug "DirectoryPackages.knownAuthor: unknown package"
*)
        val info = get pkgs namever

        val auth = PackageInfo.author info
      in
        PackageAuthorSet.member auth auths
      end;
in
  fun knownAuthor pkgs auths =
      if PackageAuthorSet.null auths then K false
      else authorInSet pkgs auths;
end;

(* ------------------------------------------------------------------------- *)
(* Package theory.                                                           *)
(* ------------------------------------------------------------------------- *)

fun emptyTheory pkgs namever =
    let
(*OpenTheoryDebug
      val () =
          if member namever pkgs then ()
          else raise Bug "DirectoryPackages.emptyTheory: unknown package"
*)
      val info = get pkgs namever
    in
      PackageInfo.emptyTheory info
    end;

(* ------------------------------------------------------------------------- *)
(* Package requirements.                                                     *)
(* ------------------------------------------------------------------------- *)

fun requiresInstalled pkgs namever =
    let
      val dep = packageDependency pkgs namever
    in
      PackageDependency.requiresInstalled dep namever
    end;

fun requiredBy pkgs namever =
    let
      val dep = completeDependency pkgs
    in
      PackageDependency.requiredBy dep namever
    end;

fun isRequired pkgs namever =
    let
      val dep = completeDependency pkgs
    in
      PackageDependency.isRequired dep namever
    end;

(* This function silently ignores required packages that are not installed *)

fun requires pkgs namever =
    let
      val dep = packageDependency pkgs namever
    in
      PackageDependency.requires dep namever
    end;

(* These functions emit warnings if required packages are not installed *)

val requiresNameVersions = warnLatestNameVersionList;

fun requiresPackages dir names =
    case requiresNameVersions dir names of
      NONE => NONE
    | SOME nameverl => SOME (List.map (get dir) nameverl);

fun requiresTheorems dir names =
    case requiresPackages dir names of
      NONE => NONE
    | SOME infol => SOME (List.map PackageInfo.theorems infol);

(* ------------------------------------------------------------------------- *)
(* Included packages.                                                        *)
(* ------------------------------------------------------------------------- *)

fun includes pkgs namever =
    let
      val dep = packageDependency pkgs namever
    in
      PackageDependency.includes dep namever
    end;

fun includedBy pkgs namever =
    let
      val dep = completeDependency pkgs
    in
      PackageDependency.includedBy dep namever
    end;

fun isIncluded pkgs namever =
    let
      val dep = completeDependency pkgs
    in
      PackageDependency.isIncluded dep namever
    end;

fun includesRTC pkgs namevers =
    PackageNameVersionSet.close (includes pkgs) namevers;

fun includedByRTC pkgs namevers =
    PackageNameVersionSet.close (includedBy pkgs) namevers;

(* ------------------------------------------------------------------------- *)
(* Subtheory packages.                                                       *)
(* ------------------------------------------------------------------------- *)

fun subtheoriesInstalled pkgs namever =
    let
      val dep = packageDependency pkgs namever
    in
      PackageDependency.subtheoriesInstalled dep namever
    end;

fun subtheoryOf pkgs namever =
    let
      val dep = completeDependency pkgs
    in
      PackageDependency.subtheoryOf dep namever
    end;

fun isSubtheory pkgs namever =
    let
      val dep = completeDependency pkgs
    in
      PackageDependency.isSubtheory dep namever
    end;

fun subtheoryOfRTC pkgs namevers =
    PackageNameVersionSet.close (subtheoryOf pkgs) namevers;

(* These functions silently ignore subtheory packages that are not installed *)

fun subtheories pkgs namever =
    let
      val dep = packageDependency pkgs namever
    in
      PackageDependency.subtheories dep namever
    end;

fun subtheoriesRTC pkgs namevers =
    PackageNameVersionSet.close (subtheories pkgs) namevers;

(* ------------------------------------------------------------------------- *)
(* Installed package sets.                                                   *)
(* ------------------------------------------------------------------------- *)

fun all pkgs = toNameVersionSetPurePackages (packages pkgs);

local
  fun addSubs pkgs (namever,subs) =
      if PackageNameVersionSet.member namever subs then subs
      else
        let
          val namevers = subtheories pkgs namever
        in
          PackageNameVersionSet.closedAdd (subtheories pkgs) subs namevers
        end;

  fun addSubsSet pkgs =
      PackageNameVersionSet.foldl (addSubs pkgs);

  fun addSubsNameSet pkgs names =
      let
        fun notMember namever =
            not (PackageNameSet.member (PackageNameVersion.name namever) names)

        fun addSubsName (namever,subs) =
            if notMember namever then subs
            else addSubs pkgs (namever,subs)
      in
        if PackageNameSet.null names then K
        else PackageNameVersionSet.foldl addSubsName
      end;

  fun nonEmpty pkgs namever = not (emptyTheory pkgs namever);
in
  fun latest pkgs =
    let
      val namevers = all pkgs

      val lats = PackageNameVersionSet.latestVersions namevers

      val subs = PackageNameVersionSet.empty

      val subs = addSubsSet pkgs subs lats

      val lats = PackageNameVersionSet.difference lats subs

      val sups = PackageNameVersionSet.name lats

      val sups = PackageNameSet.strictPrefixes sups

(*OpenTheoryTrace4
      val () = Print.trace PackageNameSet.pp "DirectoryPackages.sups" sups
*)

      val subs = addSubsNameSet pkgs sups subs namevers

      val lats = PackageNameVersionSet.difference lats subs
    in
      PackageNameVersionSet.filter (nonEmpty pkgs) lats
    end;
end;

(*OpenTheoryDebug
val latest = fn pkgs =>
    let
      val result = latest pkgs

      val result' =
          let
            val namevers = all pkgs

            val lats = PackageNameVersionSet.latestVersions namevers

            val subs = PackageNameVersionSet.lift (subtheories pkgs) namevers

            val lats = PackageNameVersionSet.difference lats subs
          in
            PackageNameVersionSet.filter (not o emptyTheory pkgs) lats
          end

      val () =
          if PackageNameVersionSet.equal result result' then ()
          else
            let
              fun ppSet n s =
                  Print.inconsistentBlock 4
                    [Print.ppString n,
                     Print.ppString ":",
                     Print.space,
                     PackageNameVersionSet.pp s]

              val bug =
                  "DirectoryPackages.latest: wrong result:\n" ^
                  "  " ^ Print.toString (ppSet "reference") result' ^ "\n" ^
                  "  " ^ Print.toString (ppSet "optimized") result ^ "\n"
            in
              raise Bug bug
            end
    in
      result
    end;
*)

(* ------------------------------------------------------------------------- *)
(* Arranging packages in dependency order.                                   *)
(* ------------------------------------------------------------------------- *)

fun dependencies pkgs namever =
    let
      val reqs = requires pkgs namever
      and incs = includes pkgs namever
    in
      PackageNameVersionSet.union reqs incs
    end;

fun dependenciesSet pkgs =
    PackageNameVersionSet.lift (dependencies pkgs);

local
  fun ppCycle pkgs =
      let
        fun verb nv1 nv2 =
            if PackageNameVersionSet.member nv2 (includes pkgs nv1) then
              "includes"
            else if PackageNameVersionSet.member nv2 (requires pkgs nv1) then
              "requires"
            else
              raise Bug "DirectoryPackages.installOrder.ppCycle.verb"

        fun ppL nvl =
            case nvl of
              [] => raise Bug "DirectoryPackages.installOrder.ppCycle.ppL"
            | nv :: nvl =>
              PackageNameVersion.pp nv ::
              (case nvl of
                 [] => []
               | nv' :: _ =>
                 Print.newline ::
                 Print.ppString (verb nv nv') ::
                 Print.space ::
                 ppL nvl)
      in
        fn nvl => Print.consistentBlock 2 (ppL nvl)
      end;
in
  fun includeOrder pkgs namevers =
      let
        val deps = dependencies pkgs

        fun proj (scc,acc) =
            let
              fun incs namever =
                  PackageNameVersionSet.intersect (includes pkgs namever) scc

              val scc = PackageNameVersionSet.intersect scc namevers

              fun add (namever,acc) =
                  if not (PackageNameVersionSet.member namever scc) then acc
                  else namever :: acc
            in
              case PackageNameVersionSet.postOrder incs scc of
                PackageNameVersionSet.Linear l => List.foldl add acc l
              | PackageNameVersionSet.Cycle l =>
                let
                  val bug =
                      "package inclusion cycle:\n  " ^
                      Print.toString (ppCycle pkgs) l
                in
                  raise Bug bug
                end
            end

        val sccs = PackageNameVersionSet.postOrderSCC deps namevers
      in
        List.rev (List.foldl proj [] sccs)
      end;

  fun dependencyOrder pkgs namevers =
      let
        val deps = dependencies pkgs

        fun proj scc =
            let
              val scc = PackageNameVersionSet.intersect scc namevers
            in
              case PackageNameVersionSet.size scc of
                0 => NONE
              | 1 => SOME (PackageNameVersionSet.pick scc)
              | _ =>
                case PackageNameVersionSet.postOrder deps scc of
                  PackageNameVersionSet.Linear _ =>
                  raise Bug "DirectoryPackages.dependencyOrder.proj"
                | PackageNameVersionSet.Cycle l =>
                  let
                    val err =
                        "package dependency cycle:\n  " ^
                        Print.toString (ppCycle pkgs) l
                  in
                    raise Error err
                  end
            end

        val sccs = PackageNameVersionSet.postOrderSCC deps namevers
      in
        List.mapPartial proj sccs
      end;
end;

fun includeOrdered pkgs =
    PackageNameVersionSet.postOrdered (includes pkgs);

fun dependencyOrdered pkgs =
    PackageNameVersionSet.postOrdered (dependencies pkgs);

(* ------------------------------------------------------------------------- *)
(* Package dependencies.                                                     *)
(* ------------------------------------------------------------------------- *)

local
  fun allInDomain nvs nvm =
      let
        fun inDom nv = PackageNameVersionMap.inDomain nv nvm
      in
        PackageNameVersionSet.all inDom nvs
      end;

  fun peekSet nvm nvs =
      if not (allInDomain nvs nvm) then NONE
      else
        let
          val nvs = PackageNameVersionSet.toList nvs

          val thys = List.map (PackageNameVersionMap.get nvm) nvs
        in
          SOME (TheorySet.fromList thys)
        end;

  fun mkSccs pkgs = PackageNameVersionSet.postOrderSCC (dependencies pkgs);

  fun expandClosed pkgs namevers =
      let
        fun process (scc,acc) =
            let
              val deps = dependenciesSet pkgs scc

              val acc' = PackageNameVersionSet.union acc scc

              val ok =
                  PackageNameVersionSet.subset deps acc' andalso
                  PackageNameVersionSet.all (requiresInstalled pkgs) scc
            in
              if ok then acc' else acc
            end

        val sccs = mkSccs pkgs namevers
      in
        List.foldl process PackageNameVersionSet.empty sccs
      end;

  fun expandAcyclic pkgs namevers =
      let
        fun process (nv,acc) =
            if PackageNameVersionSet.size nv <> 1 then acc
            else
              let
                val nv = PackageNameVersionSet.pick nv

                val deps = dependencies pkgs nv

                val ok = PackageNameVersionSet.subset deps acc
              in
                if ok then PackageNameVersionSet.add acc nv else acc
              end

        val sccs = mkSccs pkgs namevers
      in
        List.foldl process PackageNameVersionSet.empty sccs
      end;

  fun expandWellFounded pkgs namevers =
      let
        fun addTheory graph imps nv =
            let
              val finder = PackageFinder.mk (peek pkgs)

              val spec =
                  TheoryGraph.Specification
                    {imports = imps,
                     interpretation = Interpretation.natural,
                     nameVersion = nv}
            in
              total (TheoryGraph.importPackageName finder graph) spec
            end

        fun process (nv,(graph,thys)) =
            if not (allInDomain (includes pkgs nv) thys) then (graph,thys)
            else
              case peekSet thys (requires pkgs nv) of
                NONE => (graph,thys)
              | SOME imps =>
                case addTheory graph imps nv of
                  NONE => (graph,thys)
                | SOME (graph,thy) =>
                  let
                    val sum = Theory.summary thy

                    val Summary.Summary'
                        {requires = req,
                         provides = prov} = Summary.dest sum

                    val satisfied =
                        SequentSet.subset
                          (Sequents.sequents req)
                          SequentSet.standardAxioms
                  in
                    if not satisfied then (graph,thys)
                    else
                      let
                        val grounded =
                            let
                              val {undefined = inp, defined = _} =
                                  SymbolTable.partitionUndef
                                    (Sequents.symbol prov)
                            in
                              SymbolSet.subset
                                (SymbolTable.symbols inp)
                                SymbolSet.primitives
                            end
                      in
                        if not grounded then (graph,thys)
                        else
                          let
                            val thys =
                                PackageNameVersionMap.insert thys (nv,thy)
                          in
                            (graph,thys)
                          end
                      end
                  end

        val namevers = expandClosed pkgs namevers

        val namevers = expandAcyclic pkgs namevers

        val namevers = dependencyOrder pkgs namevers

        val graph = TheoryGraph.empty {savable = false}
        and thys = PackageNameVersionMap.new ()

        val (_,thys) = List.foldl process (graph,thys) namevers
      in
        PackageNameVersionSet.domain thys
      end;
in
  fun closedDependencies pkgs namevers =
      let
        val result = expandClosed pkgs namevers
      in
        PackageNameVersionSet.intersect namevers result
      end;

  fun acyclicDependencies pkgs namevers =
      let
        val result = expandAcyclic pkgs namevers
      in
        PackageNameVersionSet.intersect namevers result
      end;

  fun wellFoundedDependencies pkgs namevers =
      let
        val result = expandWellFounded pkgs namevers
      in
        PackageNameVersionSet.intersect namevers result
      end;
end;

(* ------------------------------------------------------------------------- *)
(* Adding a new package.                                                     *)
(* ------------------------------------------------------------------------- *)

fun add pkgs info chk =
    let
      val Packages
            {system = _,
             directory = _,
             packages = rop,
             dependency = _,
             checksums = chks} = pkgs

      val () =
          case !rop of
            NONE => ()
          | SOME p => rop := SOME (addPurePackages p info)

      val () =
          let
            val nv = PackageInfo.nameVersion info
          in
            DirectoryChecksums.add chks (nv,chk)
          end
    in
      ()
    end;

(* ------------------------------------------------------------------------- *)
(* Deleting a package.                                                       *)
(* ------------------------------------------------------------------------- *)

fun delete pkgs namever =
    let
      val Packages
            {system = _,
             directory = _,
             packages = rop,
             dependency = rd,
             checksums = chks} = pkgs

      val () =
          case !rop of
            NONE => ()
          | SOME p => rop := SOME (deletePurePackages p namever)

      val () = rd := PackageDependency.empty

      val () = DirectoryChecksums.delete chks namever
    in
      ()
    end;

(* ------------------------------------------------------------------------- *)
(* Comparing packages with repos.                                            *)
(* ------------------------------------------------------------------------- *)

local
  fun checkConsistency missing pkgs repo namever =
      case DirectoryRepo.peek repo namever of
        NONE => missing
      | SOME chk =>
        case checksum pkgs namever of
          SOME c => Checksum.equal c chk
        | NONE =>
          let
            val err =
                PackageNameVersion.toString namever ^
                " seems to be badly installed"
          in
            raise Error err
          end;
in
  val identicalOnRepo = checkConsistency false;

  fun consistentWithRepo pkgs repo namever =
      let
        val nvs = PackageNameVersionSet.singleton namever

        val incs = includesRTC pkgs nvs
      in
        PackageNameVersionSet.all (checkConsistency true pkgs repo) incs
      end
end;

fun earlierThanRepo pkgs repo namever =
    let
      val PackageNameVersion.NameVersion' {name,version} =
          PackageNameVersion.dest namever
    in
      case DirectoryRepo.latestNameVersion repo name of
        NONE => false
      | SOME (nv,_) =>
        case PackageVersion.compare (version, PackageNameVersion.version nv) of
          LESS => true
        | EQUAL => false
        | GREATER => false
    end;

fun laterThanRepo pkgs repo namever =
    let
      val PackageNameVersion.NameVersion' {name,version} =
          PackageNameVersion.dest namever
    in
      case DirectoryRepo.latestNameVersion repo name of
        NONE => false
      | SOME (nv,_) =>
        case PackageVersion.compare (version, PackageNameVersion.version nv) of
          LESS => false
        | EQUAL => false
        | GREATER => true
    end;

(* ------------------------------------------------------------------------- *)
(* Pretty-printing.                                                          *)
(* ------------------------------------------------------------------------- *)

val pp = Print.ppMap size (Print.ppBracket "{" "}" Print.ppInt);

val toString = Print.toString pp;

end
