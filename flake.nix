{
  description = "Hello rust flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    rust-overlay,
  }:
    {nixosModules.simple-test-api = import ./modules/simple-test-api/default.nix self;}
    // flake-utils.lib.eachDefaultSystem (system: let
      overlays = [(import rust-overlay)];
      pkgs = import nixpkgs {inherit system overlays;};
      rust = pkgs.rust-bin.stable.latest.default.override {
        extensions = ["rust-src"];
      };
      rustPlatform = pkgs.makeRustPlatform {
        rustc = rust;
        cargo = rust;
      };
    in {
      packages = rec {
        simple-test-api = rustPlatform.buildRustPackage rec {
          pname = "simple-test-api";
          version = "0.1.0";

          src = ./.;
          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          doCheck = true;

          env = {};
        };

        default = simple-test-api;
      };
      apps = rec {
        ip = flake-utils.lib.mkApp {
          drv = self.packages.${system}.simple-test-api;
          exePath = "/bin/simple-test-api";
        };
        default = ip;
      };
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [rust];
        shellHook = ''
          export CARGO_HOME=$(pwd)/cargo
        '';
      };
    });
}
