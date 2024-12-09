{
  pkgs,
  imageBuilder,
}:
imageBuilder {
  inherit pkgs;
  packInfo = {
    name = "Divine Journey 2";
    imageName = "divine_journey_2";
    version = "2.21.1";
    packFile = {
      url = "https://mediafilez.forgecdn.net/files/5859/203/Divine_Journey_2.21.1_Server_Pack.zip";
      hash = "sha256-vTbu2nxJBWOLf0ZORGNcvWMUtgg+gPmVdr0MJEXPg6s=";
    };
  };
  filesToRemove = [
    "forge-1.12.2-14.23.5.2860-installer.jar"
    "forge-installer.jar.log"
    "launch.sh"
    "launch.bat"
    "autolaunch.sh"
    "autolaunch.bat"
    "launch_config.ini"
    "modlist.html"
  ];
  forgeInfo = {
    version = "14.23.5.2860";
    includesInstaller = false;
    installerHash = "sha256-6nwzupXjmTqY0OnjgWjAdZ7DI6GGdacdk44fP3Dm6Oc=";
    depsHash = "sha256-ihUceMcL0mRrenNpzhD3EAvw0XYnw0CskKBgXqnmTdI=";
    userJvmArgsPath = ./user_jvm_args.txt;
  };
  mcVersion = "1.12.2";
  javaVersion = "8";
}
