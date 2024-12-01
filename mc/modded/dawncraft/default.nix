{
  pkgs,
  imageBuilder,
}:
imageBuilder {
  inherit pkgs;
  packInfo = {
    name = "DawnCraft - Echoes of Legends";
    imageName = "dawncraft";
    version = "2.0.11_f";
    packFile = {
      url = "https://mediafilez.forgecdn.net/files/5503/606/DawnCraft%202.0.11_f%20Serverpack.zip";
      hash = "sha256-bDGLIiTwADt7kcfccrAZpILYZ9/EYTQBB8xmZKVDshA=";
    };
  };
  filesToRemove = [
    "startserver.sh"
    "startserver.bat"
    "VeryMakeShiftHowTo.txt"
  ];
  forgeInfo = {
    version = "40.2.17";
    includesInstaller = false;
    installerHash = "sha256-iZH0fuuuR03vUCwGYO5oldLSUksaWrUBKh9tJsBww90=";
    depsHash = "sha256-+3RLB8zVdpnP6HIzuBU5E2MdKyLHFnW0NM0CsBwc9lQ=";
    userJvmArgsPath = ./user_jvm_args.txt;
  };
  mcVersion = "1.18.2";
  javaVersion = "17";
}
