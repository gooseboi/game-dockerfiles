{
  pkgs,
  imageBuilder,
  isNow ? false,
}: let
  spark = pkgs.fetchurl {
    url = "https://mediafilez.forgecdn.net/files/4738/952/spark-1.10.53-forge.jar";
    hash = "sha256-66J1upuwy1tUKRPDE4xu7/anUomCZtY9El0YXyasme0=";
  };
  simplebackups = pkgs.fetchurl {
    url = "https://edge.forgecdn.net/files/5369/377/SimpleBackups-1.20.1-3.1.6.jar";
    hash = "sha256-6iNsCGlNyDrA2w+X917GZP3zYUh3tgh5xvDP3H3y8oI=";
  };
in
  imageBuilder {
    inherit pkgs isNow;
    packInfo = {
      name = "Better MC - BMC4";
      imageName = "bmc4";
      version = "v28_patch";
      packFile = {
        url = "https://mediafilez.forgecdn.net/files/5418/541/BMC4_FORGE_1.20.1_Server_Pack_v28.zip";
        hash = "sha256-uL9z7NZWUFD50HB5pqo1Z3EqiXYvoQvgTEWkUtviPxk=";
      };
    };
    filesToRemove = [
      "READ_ME.txt"
      "start.ps1"
      "start.sh"
      "variables.txt"
    ];
    forgeInfo = {
      version = "47.3.1";
      includesInstaller = false;
      installerHash = "sha256-sqj58FDW8eKTXHE387KwnShrwl6hysNJ3ONDY1Gcbnk=";
      depsHash = "sha256-mDWhPRqdYtSP4+ZyYjkZT3jMtjE6FHL5ZZPlQ4sgm44= ";
      userJvmArgsPath = ./user_jvm_args.txt;
    };
    mcVersion = "1.20.1";
    javaVersion = "17";
    fixup = ''
      rm mods/neruina-forge-2.0.0-beta.10+1.20.1.jar
      cp ${spark} mods/spark-1.10.53-forge.jar
      cp ${simplebackups} mods/SimpleBackups-1.20.1-3.1.6.jar
      cp ${./backpacked.server.toml} config/backpacked.server.toml
      cp ${./simplebackups-common.toml} config/simplebackups-common.toml
    '';
  }
