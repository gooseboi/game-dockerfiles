{ pkgs, imageBuilder, isNow ? false }:
    imageBuilder {
      inherit pkgs isNow;
      packInfo = {
        name = "Better MC - BMC4";
        imageName = "bmc4";
        version = "v28";
        packFile = {
          url = "https://mediafilez.forgecdn.net/files/5418/541/BMC4_FORGE_1.20.1_Server_Pack_v28.zip";
          hash = "sha256-uL9z7NZWUFD50HB5pqo1Z3EqiXYvoQvgTEWkUtviPxk=";
        };
      };
      filesToRemove = [ "READ_ME.txt"
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
    }
