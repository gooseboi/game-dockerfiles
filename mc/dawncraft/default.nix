{ pkgs, dawncraft_zip }:
  let
    mkDerivation = pkgs.stdenv.mkDerivation;

    pack_name = "Dawncraft";
    pack_version = "2.0.11_f";
    pack_fullname = "${pack_name} v${pack_version}";

    temurinHeadless = pkgs.temurin-jre-bin-17.override { gtkSupport = false; };

    forge_version = "40.2.17";
    mc_version = "1.18.2";
    forge_installer = pkgs.fetchurl {
      url = "http://files.minecraftforge.net/maven/net/minecraftforge/forge/${mc_version}-${forge_version}/forge-${mc_version}-${forge_version}-installer.jar";
      hash = "sha256-iZH0fuuuR03vUCwGYO5oldLSUksaWrUBKh9tJsBww90=";
    };

    # Install the forge server
    server_deps = mkDerivation (finalAttrs:
      {
        name = "${pack_fullname} server runtime dependencies";
        nativeBuildInputs = [ temurinHeadless ];

        dontUnpack = true;
        dontPatch = true;
        dontConfigure = true;
        dontFixup = true;

        buildPhase = ''
          java -jar ${forge_installer} --installServer
        '';

        installPhase = ''
          mkdir -p $out/deps
          mv libraries $out/deps
        '';

        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-+3RLB8zVdpnP6HIzuBU5E2MdKyLHFnW0NM0CsBwc9lQ=";
      }
    );

    # Copy the server deps and remove unnecessary files
    server = mkDerivation (finalAttrs:
      {
        name = "${pack_fullname} server";
        nativeBuildInputs = [ pkgs.unzip pkgs.rsync ];

        src = dawncraft_zip;
        sourceRoot = "./server";

        dontConfigure = true;
        dontPatch = true;
        dontFixup = true;

        # sourceRoot refers to the directory where files should be unpacked to,
        # and curSrc is a variable referring to the src files used as sources
        # for the derivation, because there is no $src variable
        unpackCmd = "unzip -d ${finalAttrs.sourceRoot} $curSrc";

        buildPhase = ''
          rm -f startserver.sh startserver.bat VeryMakeShiftHowTo.txt
          echo "eula=true" > eula.txt
          cp ${./user_jvm_args.txt} user_jvm_args.txt
        '';

        installPhase = ''
          mkdir -p $out/data
          rsync -rvtP ./ $out/data
          rsync -rvtP ${server_deps}/deps/ $out/data
        '';

        meta = {
          description = "${pack_fullname} server";
          homepage = "https://www.curseforge.com/minecraft/modpacks/create-arcane-engineering";
          license = pkgs.lib.licenses.gpl3;
        };
      }
    );
    start_sh = pkgs.writeShellScriptBin "start.sh" ''
      # The chmod is because some mods always write out changes to the files
      # when the server is ran
      ${pkgs.rsync}/bin/rsync -rvtPLu --chmod=F644 /data/ /server
      cd /server
      ${temurinHeadless}/bin/java @user_jvm_args.txt @libraries/net/minecraftforge/forge/${mc_version}-${forge_version}/unix_args.txt -jar "forge-${mc_version}-${forge_version}" nogui
    '';
    # Apparently minecraft uses /tmp to render the server icon (?)
    tmpdir = pkgs.runCommandLocal "mktmp" {} ''
      mkdir -p $out/tmp
    '';
  in
  pkgs.dockerTools.buildLayeredImage {
    name = "dawncraft";
    tag = pack_version;

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
