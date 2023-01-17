{
  description = "NixOS support for pibox hardware";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    nixpkgsDeviceOverlays.url = "github:NixOS/nixpkgs/bfd1c45e54bd9823b083c10537cf677462fc2c28";

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

  outputs = inputs@{ self, nixpkgs, flake-utils, pibox-framebuffer, pibox-os, ... }:
    let
      packagesFor = pkgs: import ./pkgs {
        inherit pkgs pibox-framebuffer pibox-os;
        # Remove once https://github.com/NixOS/nixpkgs/pull/205595 lands
        pkgsPinned = import inputs.nixpkgsDeviceOverlays {
          inherit (pkgs.hostPlatform) system;
        };
      };
    in
    {
      overlays.default = final: prev: {
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
      in
      {
        formatter = pkgs.nixpkgs-fmt;
      }) // flake-utils.lib.eachSystem [ "aarch64-linux" ] (system:
      {
        packages = packagesFor (import nixpkgs {
          inherit system;
        });
        checks = self.packages.${system};
      }
    );
}
