{
  pkgs,
  imageBuilder,
}:
imageBuilder {
  inherit pkgs;
  packInfo = {
    name = "DawnCraft - Echoes of Legends";
    imageName = "dawncraft";
    version = "2.0.15";
    packFile = {
      url = "https://mediafilez.forgecdn.net/files/6312/852/DawnCraft%202.0.15%20Serverpack.zip";
      hash = "sha256-QQ3IH21LEpxf+XP0lKJBjzZ+Go53O1soE9B8Ir0cdY0=";
    };
  };
  filesToRemove = [
    "README.txt"
    "start.ps1"
    "start.sh"
    "variables.txt"
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
