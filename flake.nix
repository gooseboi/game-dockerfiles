{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        mcImageBuilder = import ./mc/builders/forge_bundled.nix;
      in {
        packages = {
          sevtechAges = import ./mc/sevtech_ages {
            inherit pkgs;
            imageBuilder = mcImageBuilder;
          };

          createArcaneEngineering = import ./mc/create_arcane_engineering {
            inherit pkgs;
            imageBuilder = mcImageBuilder;
          };

          dawncraft = import ./mc/dawncraft {
            inherit pkgs;
            imageBuilder = mcImageBuilder;
          };
        };
      }
    );
  }
