{ pkgs, create_arcane_engineering_zip }:
  let
    mkDerivation = pkgs.stdenv.mkDerivation;

    version = "1.9.3";
    name = "Create: Arcane Engineering";
    temurinHeadless = pkgs.temurin-jre-bin-17.override { gtkSupport = false; };

    forge_version = "40.2.9";
    mc_version = "1.18.2";
    forge_installer = pkgs.fetchurl {
      url = "http://files.minecraftforge.net/maven/net/minecraftforge/forge/${mc_version}-${forge_version}/forge-${mc_version}-${forge_version}-installer.jar";
      hash = "sha256-UUPQjoHir9F18SF+JkUJKoMMfv4s7gJcLsBaCZTEXl4=";
    };

    # Install the forge server
    server_deps = mkDerivation (finalAttrs:
      {
        name = "${name} server runtime dependencies";
        nativeBuildInputs = [ temurinHeadless ];

        dontUnpack = true;

        buildPhase = ''
          java -jar ${forge_installer} --installServer
        '';

        installPhase = ''
          mkdir -p $out/deps
          mv libraries $out/deps
        '';

        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-mhntynxrxeLvzc2wzee6DTDfKfJMX/kS9zeugHH6Fso=";
      }
    );

    # Copy the server deps and remove unnecessary files
    create_arcane_engineering_server = mkDerivation (finalAttrs:
      {
        name = "${name} Server";
        nativeBuildInputs = [ pkgs.unzip pkgs.rsync ];

        src = create_arcane_engineering_zip;
        sourceRoot = "./server";

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
          description = "${name} v${version} server";
          homepage = "https://www.curseforge.com/minecraft/modpacks/create-arcane-engineering";
          # It isn't actually GPL3, but I don't care
          license = pkgs.lib.licenses.gpl3;
        };
      }
    );
    start_sh = pkgs.writeShellScriptBin "start.sh" ''
      # The chmod is because some mods always write out changes to the files
      # when the server is ran
      ${pkgs.rsync}/bin/rsync -rvtPLu --chmod=F644 /data/ /server
      cd /server
      ${temurinHeadless}/bin/java @user_jvm_args.txt @libraries/net/minecraftforge/forge/${mc_version}-${forge_version}/unix_args.txt -jar "forge-1.18.2-${forge_version}" nogui
    '';
    # Apparently minecraft uses /tmp to render the server icon (?)
    tmpdir = pkgs.runCommandLocal "mktmp" {} ''
      mkdir -p $out/tmp
    '';
  in
  pkgs.dockerTools.buildLayeredImage {
    name = "create_arcane_engineering";
    tag = "1.9.3";

    contents = [ tmpdir start_sh create_arcane_engineering_server ];

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
