{
  pkgs,
  imageBuilder,
}:
imageBuilder {
  inherit pkgs;
  packInfo = {
    name = "Sevtech: Ages";
    imageName = "sevtech_ages";
    version = "3.2.3";
    packFile = {
      url = "https://mediafilez.forgecdn.net/files/3570/46/SevTech_Ages_Server_3.2.3.zip";
      hash = "sha256-StrvXb/5/6sf1vdEB3JUXAsuaRsWPXRcnvZkwMATHpQ=";
    };
  };
  filesToRemove = [
    "forge-1.12.2-14.23.5.2860-installer.jar"
    "forge-installer.jar.log"
    "Install.sh"
    "ServerStart.sh"
    "settings.sh"
    "Install.bat"
    "ServerStart.bat"
    "settings.bat"
    "README.txt"
  ];
  forgeInfo = {
    version = "14.23.5.2860";
    includesInstaller = true;
    depsHash = "sha256-ihUceMcL0mRrenNpzhD3EAvw0XYnw0CskKBgXqnmTdI=";
    userJvmArgsPath = ./user_jvm_args.txt;
  };
  mcVersion = "1.12.2";
  javaVersion = "8";
}
