{ pkgs, serverUrl, serverSha256, version, isNow ? false }:
  let
    mkDerivation = pkgs.stdenv.mkDerivation;

    serverZip = pkgs.fetchurl {
      url = serverUrl;
      sha256 = serverSha256;
    };
    server = mkDerivation (finalAttrs: {
      pname = "terraria-server";
      inherit version;

      nativeBuildInputs = [ pkgs.unzip ];

      dontConfigure = true;
      dontPatch = true;
      dontFixup = true;

      src = serverZip;
      sourceRoot = "./server";
      unpackCmd = ''
        unzip -d ${finalAttrs.sourceRoot} $src '1449/Linux/*'
        mv ${finalAttrs.sourceRoot}/1449/Linux/* ${finalAttrs.sourceRoot}
        rm -rf ${finalAttrs.sourceRoot}/1449
      '';

      buildPhase = ''
        rm System* Mono* monoconfig mscorlib.dll
        rm open-folder
        rm TerrariaServer TerrariaServer.bin.x86_64
      '';

      installPhase = ''
        mkdir -p $out
        mv ./* $out
      '';
    });
  in
  pkgs.dockerTools.buildLayeredImage {
    name = "terraria";
    tag = version;

    contents = [ pkgs.mono server ];

    created = if isNow then "now" else "1970-01-01T00:00:01Z";
  }
