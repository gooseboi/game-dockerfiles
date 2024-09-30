{ pkgs, isNow ? false }:
  let
    lib = pkgs.lib;
    versions = lib.importJSON ./versions.json;
    builder = import ./builder.nix;
    escapeVersion = builtins.replaceStrings [ "." ] [ "" ];

    packages = lib.mapAttrs'
    (version: value: {
      name = "terraria${escapeVersion version}";
      value = builder {
        inherit pkgs isNow version;
        serverUrl = value.url;
        serverSha256 = value.sha256;
      };
    })
    versions;
  in
  packages
