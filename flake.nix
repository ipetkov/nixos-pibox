{
  description = "NixOS support for pibox hardware";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";

    pibox-framebuffer = {
      url = "github:kubesail/pibox-framebuffer";
      flake = false;
    };

    pibox-os = {
      url = "github:kubesail/pibox-os";
      flake = false;
    };
  };

  outputs = { nixpkgs, flake-utils, pibox-framebuffer, pibox-os, ... }:
    let
      packagesFor = pkgs: import ./pkgs {
        inherit pkgs pibox-framebuffer pibox-os;
      };
    in
    {
      overlays.default = final: _prev: {
        pibox = packagesFor final;
      };

      nixosModules.default = { ... }: {
        imports = [
          ./nixosModules/framebuffer.nix
          ./nixosModules/kernel-params.nix
          ./nixosModules/pwm-fan.nix
        ];
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        inherit (pkgs) lib;
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.deadnix
          ];
        };
      } // lib.optionalAttrs (system == "aarch64-linux") rec {
        packages = packagesFor pkgs;
        checks = packages;
      }
    );
}
