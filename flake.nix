{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};

        forgeImageBuilder = import ./mc/builders/forge_bundled.nix;
        forgeBundledImage = fname:
          import fname {
            inherit pkgs;
            imageBuilder = forgeImageBuilder;
          };

        vanillaImages = import ./mc/vanilla {inherit pkgs;};
        terrariaImages = import ./terraria {inherit pkgs;};
      in {
        packages =
          {
            # Modpacks
            sevtechAges = forgeBundledImage ./mc/modded/sevtech_ages;
            createArcaneEngineering = forgeBundledImage ./mc/modded/create_arcane_engineering;
            dawncraft = forgeBundledImage ./mc/modded/dawncraft;
            bmc4 = forgeBundledImage ./mc/modded/bettermc_4;
            bmc4Patch = forgeBundledImage ./mc/modded/bettermc_4_patch;
            divineJourney2 = forgeBundledImage ./mc/modded/divine_journey_2;
          }
          // vanillaImages
          // terrariaImages;
      }
    );
}
