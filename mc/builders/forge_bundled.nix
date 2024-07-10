{ pkgs, packInfo, forgeInfo, mcVersion, javaVersion, filesToRemove }:
  let
    mkDerivation = pkgs.stdenv.mkDerivation;

    packFullname = "${packInfo.name} v${packInfo.version}";

    temurinHeadless = pkgs."temurin-jre-bin-${javaVersion}".override { gtkSupport = false; };

    packFile = pkgs.fetchurl {
      url = packInfo.packFile.url;
      hash = packInfo.packFile.hash;
    };

    mcMinorVersion = pkgs.lib.strings.toInt (builtins.elemAt (builtins.match "[[:digit:]]+\\.([[:digit:]]+)\\.[[:digit:]]+" mcVersion) 0);
    isOldMc = builtins.lessThan mcMinorVersion 16;

    installerFileName = "forge-${mcVersion}-${forgeInfo.version}-installer.jar";
    forgeInstaller = pkgs.fetchurl {
      url = "http://files.minecraftforge.net/maven/net/minecraftforge/forge/${mcVersion}-${forgeInfo.version}/forge-${mcVersion}-${forgeInfo.version}-installer.jar";
      hash = forgeInfo.installerHash;
    };

    # Install the forge server
    installCmd = if isOldMc then
      ''
        mkdir -p $out/deps
        mv forge-${mcVersion}-${forgeInfo.version}.jar $out/deps
        mv minecraft_server.${mcVersion}.jar $out/deps
        mv libraries $out/deps
      ''
    else
      ''
        mkdir -p $out/deps
        mv libraries $out/deps
      '';
    serverDeps = if forgeInfo.includesInstaller
      then mkDerivation (finalAttrs:
        {
          name = "${packFullname} server runtime dependencies";
          nativeBuildInputs = [ pkgs.unzip temurinHeadless ];

          src = packFile;
          sourceRoot = "./server";
          unpackCmd = "unzip -d ${finalAttrs.sourceRoot} $curSrc '${installerFileName}'";

          buildPhase = ''
            java -jar '${installerFileName}' --installServer
          '';

          installPhase = installCmd;

          outputHashAlgo = "sha256";
          outputHashMode = "recursive";
          outputHash = forgeInfo.depsHash;
        })
      else mkDerivation (finalAttrs:
        {
          name = "${packFullname} server runtime dependencies";
          nativeBuildInputs = [ temurinHeadless ];

          dontUnpack = true;
          dontPatch = true;
          dontConfigure = true;
          dontFixup = true;

          buildPhase = ''
            java -jar ${forgeInstaller} --installServer
          '';

          installPhase = installCmd;

          outputHashAlgo = "sha256";
          outputHashMode = "recursive";
          outputHash = forgeInfo.depsHash;
        }
      );

    fileRemoveList = pkgs.lib.lists.forEach filesToRemove (f: pkgs.lib.strings.concatStrings (pkgs.lib.strings.intersperse " " [ "rm" "-f" f ]));
    fileRemoveStr = pkgs.lib.strings.concatStrings (pkgs.lib.strings.intersperse "\n" fileRemoveList);
    # Copy the server deps and remove unnecessary files
    server = mkDerivation (finalAttrs:
      {
        name = "${packFullname} server";
        nativeBuildInputs = [ pkgs.unzip pkgs.rsync ];

        src = packFile;
        sourceRoot = "./server";

        dontConfigure = true;
        dontPatch = true;
        dontFixup = true;

        # sourceRoot refers to the directory where files should be unpacked to,
        # and curSrc is a variable referring to the src files used as sources
        # for the derivation, because there is no $src variable
        unpackCmd = "unzip -d ${finalAttrs.sourceRoot} $curSrc";


        buildPhase = ''
          ${fileRemoveStr}
          echo "eula=true" > eula.txt
          cp ${forgeInfo.userJvmArgsPath} user_jvm_args.txt
        '';

        installPhase = ''
          mkdir -p $out/data
          rsync -rvtP ./ $out/data
          rsync -rvtP ${serverDeps}/deps/ $out/data
        '';

        meta = {
          description = "${packFullname} server";
          homepage = packInfo.url;
          license = pkgs.lib.licenses.gpl3;
        };
      }
    );
    javaCmd = if isOldMc then
      "${temurinHeadless}/bin/java $(${pkgs.coreutils}/bin/tr '\n' ' ' < user_jvm_args.txt) -jar 'forge-${mcVersion}-${forgeInfo.version}.jar' nogui"
      else
      "${temurinHeadless}/bin/java @user_jvm_args.txt @libraries/net/minecraftforge/forge/${mcVersion}-${forgeInfo.version}/unix_args.txt nogui"
      ;
    start_sh = pkgs.writeShellScriptBin "start.sh" ''
      # The chmod is because some mods always write out changes to the files
      # when the server is ran
      ${pkgs.rsync}/bin/rsync -rvtPLu --chmod=F644 /data/ /server
      cd /server
      ${javaCmd}
    '';
    # Apparently minecraft uses /tmp to render the server icon (?)
    tmpdir = pkgs.runCommandLocal "mktmp" {} ''
      mkdir -p $out/tmp
    '';
  in
  pkgs.dockerTools.buildLayeredImage {
    name = packInfo.imageName;
    tag = packInfo.version;

    contents = [ tmpdir start_sh server ];

    # Nix by default has all folders have 555, but that's not right for /tmp
    extraCommands = ''
      chmod a+rwx ./tmp
      chmod o+t ./tmp
    '';

    config = {
      Volumes = { "/server" = {}; };
      ExposedPorts = { "25565/tcp" = {}; "25564/tcp" = {}; };
      Cmd = [ "/bin/start.sh" ];
    };
  }
