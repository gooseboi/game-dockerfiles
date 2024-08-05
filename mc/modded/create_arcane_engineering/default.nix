{ pkgs, imageBuilder }:
    imageBuilder {
      inherit pkgs;
      packInfo = {
        name = "Create: Arcane Engineering";
        imageName = "create_arcane_engineering";
        version = "1.9.3";
        packFile = {
          url = "https://mediafilez.forgecdn.net/files/4852/56/CAEServer1.9.zip";
          hash = "sha256-0Fd2g/5yK7z46zKfV0gH6uKCBKcKoceYhIjUUdwgcIo=";
        };
      };
      filesToRemove = [ "startserver.sh"
                        "startserver.bat"
                        "VeryMakeShiftHowTo.txt"
                      ];
      forgeInfo = {
        version = "40.2.9";
        includesInstaller = false;
        installerHash = "sha256-UUPQjoHir9F18SF+JkUJKoMMfv4s7gJcLsBaCZTEXl4=";
        depsHash = "sha256-mhntynxrxeLvzc2wzee6DTDfKfJMX/kS9zeugHH6Fso=";
        userJvmArgsPath = ./user_jvm_args.txt;
      };
      mcVersion = "1.18.2";
      javaVersion = "17";
    }
