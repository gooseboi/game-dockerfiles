{ pkgs, sevtech_ages_zip }:
  let
    mkDerivation = pkgs.stdenv.mkDerivation;

    version = "3.2.3";
    temurinHeadless = pkgs.temurin-jre-bin-8.override { gtkSupport = false; };

    # Install the forge server
    server_deps = mkDerivation (finalAttrs:
      {
        name = "Sevtech Ages server runtime dependencies";
        nativeBuildInputs = [ pkgs.unzip temurinHeadless ];

        src = sevtech_ages_zip;
        sourceRoot = "./server";
        unpackCmd = "unzip -d ${finalAttrs.sourceRoot} $curSrc 'forge-1.12.2-14.23.5.2860-installer.jar'";

        buildPhase = ''
          java -jar 'forge-1.12.2-14.23.5.2860-installer.jar' --installServer
        '';

        installPhase = ''
          mkdir -p $out/deps
          mv forge-1.12.2-14.23.5.2860.jar minecraft_server.1.12.2.jar libraries $out/deps
        '';

        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = "sha256-ihUceMcL0mRrenNpzhD3EAvw0XYnw0CskKBgXqnmTdI=";
        }
    );

    # Copy the server deps and remove unnecessary files
    sevtech_ages_server = mkDerivation (finalAttrs:
      {
        name = "Sevtech Ages Server";
        nativeBuildInputs = [ pkgs.unzip pkgs.rsync ];

        src = sevtech_ages_zip;
        sourceRoot = "./server";

        # sourceRoot refers to the directory where files should be unpacked to,
        # and curSrc is a variable referring to the src files used as sources
        # for the derivation, because there is no $src variable
        unpackCmd = "unzip -d ${finalAttrs.sourceRoot} $curSrc";

        buildPhase = ''
          rm -f "forge-1.12.2-14.23.5.2860-installer.jar" forge-installer.jar.log Install.sh ServerStart.sh settings.sh Install.bat ServerStart.bat settings.bat README.txt
          echo "eula=true" > eula.txt
          cp ${./user_jvm_args.txt} user_jvm_args.txt
        '';

        installPhase = ''
          mkdir -p $out/data
          rsync -rvtP ./ $out/data
          rsync -rvtP ${server_deps}/deps/ $out/data
        '';

        meta = {
          description = "Sevtech Ages v${version} server";
          homepage = "https://www.curseforge.com/minecraft/modpacks/sevtech-ages";
          license = pkgs.lib.licenses.gpl3;
        };
      }
    );
    start_sh = pkgs.writeShellScriptBin "start.sh" ''
      # The chmod is because some mods always write out changes to the files
      # when the server is ran
      ${pkgs.rsync}/bin/rsync -rvtPLu --chmod=F644 /data/ /server
      cd /server
      ${temurinHeadless}/bin/java $(${pkgs.coreutils}/bin/tr '\n' ' ' < user_jvm_args.txt) -jar "forge-1.12.2-14.23.5.2860.jar" nogui
    '';
    # Apparently minecraft uses /tmp to render the server icon (?)
    tmpdir = pkgs.runCommandLocal "mktmp" {} ''
      mkdir -p $out/tmp
    '';
  in
  pkgs.dockerTools.buildLayeredImage {
    name = "sevtech_ages";
    tag = "3.2.3";

    contents = [ tmpdir start_sh sevtech_ages_server ];

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
