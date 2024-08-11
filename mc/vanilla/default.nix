{ pkgs, isNow ? false }:
  let
    lib = pkgs.lib;
    versions = lib.importJSON ./versions.json;
    builder = import ./builder.nix;
    escapeVersion = builtins.replaceStrings [ "." ] [ "_" ];

    packages = lib.mapAttrs'
    (version: value: {
      name = "vanilla${escapeVersion version}";
      value = builder {
        inherit pkgs isNow;
        userJvmArgsPath = ./. + "/user_jvm_args_${value.javaVersion}.txt";
        serverUrl = value.url;
        serverSha256 = value.sha256;
        mcVersion = version;
        inherit (value) javaVersion;
      };
    })
    versions;
  in
  packages
