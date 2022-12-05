{
  description = "NixOS support for pibox hardware";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";

    pibox-os = {
      url = "github:kubesail/pibox-os";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, pibox-os, ... }:
    let
      packagesFor = pkgs: import ./pkgs {
        inherit pkgs pibox-os;
      };
    in
    {
      overlays.default = final: prev: {
        pibox = packagesFor final;
      };

      nixosModules.default = { ... }: {
        imports = [
          ./nixosModules/pwm-fan.nix
        ];
      };
    } // flake-utils.lib.eachSystem [ "aarch64-linux" ] (system:
      let
      in
      {
        packages = packagesFor (import nixpkgs {
          inherit system;
        });

        checks = self.packages.${system};
      }
    );
}
