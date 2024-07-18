{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        forgeImageBuilder = import ./mc/builders/forge_bundled.nix;
        forgeBundledImage = fname: import fname { inherit pkgs; imageBuilder = forgeImageBuilder; };
      in {
        packages = {
          # Modpacks
          sevtechAges = forgeBundledImage ./mc/sevtech_ages;
          createArcaneEngineering = forgeBundledImage ./mc/create_arcane_engineering;
          dawncraft = forgeBundledImage ./mc/dawncraft;
          bmc4 = forgeBundledImage ./mc/bettermc_4;
        };
      }
    );
  }
