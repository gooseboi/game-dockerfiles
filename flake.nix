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

        vanillaBuilder = import ./mc/builders/forge_bundled.nix;
      in {
        packages = {
          # Vanilla
          # vanilla_1_21 = vanillaBuilder

          # Modpacks
          sevtechAges = forgeBundledImage ./mc/modded/sevtech_ages;
          createArcaneEngineering = forgeBundledImage ./mc/modded/create_arcane_engineering;
          dawncraft = forgeBundledImage ./mc/modded/dawncraft;
          bmc4 = forgeBundledImage ./mc/modded/bettermc_4;
          bmc4Patch = forgeBundledImage ./mc/modded/bettermc_4_patch;
        };
      }
    );
  }
