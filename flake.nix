{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    sevtech_ages_zip = {
      url = "file+https://mediafilez.forgecdn.net/files/3570/46/SevTech_Ages_Server_3.2.3.zip";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, sevtech_ages_zip }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        packages = {
          sevtech_ages = import ./mc/sevtech_ages { inherit pkgs sevtech_ages_zip; };
        };
      }
    );
  }
