{
  pkgs,
  serverUrl,
  serverSha256,
  javaVersion,
  mcVersion,
  userJvmArgsPath,
  isNow ? false,
}: let
  mkDerivation = pkgs.stdenv.mkDerivation;

  temurinHeadless = pkgs."temurin-jre-bin-${javaVersion}".override {gtkSupport = false;};

  serverFile = pkgs.fetchurl {
    url = serverUrl;
    sha256 = serverSha256;
  };
  serverFname = "minecraft_server.${mcVersion}.jar";

  mcMinorVersion = pkgs.lib.strings.toInt (builtins.elemAt (builtins.match "[[:digit:]]+\\.([[:digit:]]+)(\\.[[:digit:]]+)?" mcVersion) 0);
  isOldMc = builtins.lessThan mcMinorVersion 16;

  # Copy the server deps and remove unnecessary files
  server = mkDerivation {
    pname = "mc-server";
    version = mcVersion;

    src = serverFile;
    nativeBuildInputs = [pkgs.rsync];

    dontUnpack = true;
    dontConfigure = true;
    dontPatch = true;
    dontFixup = true;

    buildPhase = ''
      echo "eula=true" > eula.txt
      cp ${userJvmArgsPath} user_jvm_args.txt
      cp $src ${serverFname}
    '';

    installPhase = ''
      mkdir -p $out/data
      rsync -rvtP ./ $out/data
    '';

    meta = {
      description = "Minecraft ${mcVersion} vanilla server";
      homepage = "https://minecraft.net";
      # Like, this isn't right, but we ball
      license = pkgs.lib.licenses.gpl3;
    };
  };
  javaCmd =
    if isOldMc
    then "${temurinHeadless}/bin/java $(${pkgs.coreutils}/bin/tr '\n' ' ' < user_jvm_args.txt) -jar '${serverFname}' nogui"
    else "${temurinHeadless}/bin/java @user_jvm_args.txt -jar '${serverFname}' nogui";
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
    name = "vanilla_mc";
    tag = mcVersion;

    created =
      if isNow
      then "now"
      else "1970-01-01T00:00:01Z";

    contents = [tmpdir start_sh server];

    # Nix by default has all folders have 555, but that's not right for /tmp
    extraCommands = ''
      chmod a+rwx ./tmp
      chmod o+t ./tmp
    '';

    config = {
      Volumes = {"/server" = {};};
      ExposedPorts = {
        "25565/tcp" = {};
        "25564/tcp" = {};
      };
      Cmd = ["/bin/start.sh"];
    };
  }
