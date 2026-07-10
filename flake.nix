{
  description = "NixOS support for pibox hardware";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    pibox-framebuffer = {
      url = "github:kubesail/pibox-framebuffer";
      flake = false;
    };

    pibox-os = {
      url = "github:kubesail/pibox-os";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      pibox-framebuffer,
      pibox-os,
      ...
    }:
    let
      packagesFor =
        pkgs:
        import ./pkgs {
          inherit pkgs pibox-framebuffer pibox-os;
        };

      eachSystem =
        systems: f:
        let
          # Merge together the outputs for all systems.
          op =
            attrs: system:
            let
              ret = f system;
              op =
                attrs: key:
                attrs
                // {
                  ${key} = (attrs.${key} or { }) // {
                    ${system} = ret.${key};
                  };
                };
            in
            builtins.foldl' op attrs (builtins.attrNames ret);
        in
        builtins.foldl' op { } systems;

      eachDefaultSystem = eachSystem [
        "x86_64-linux"
        "aarch64-linux"
      ];
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
    }
    // eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        inherit (pkgs) lib;
      in
      {
        formatter = pkgs.nixfmt-tree;
        devShells = {
          default = pkgs.mkShell {
            nativeBuildInputs = [
              pkgs.deadnix
            ];
          };
          zizmor = pkgs.mkShell {
            packages = [
              pkgs.zizmor
            ];
          };
        };
      }
      // lib.optionalAttrs (system == "aarch64-linux") rec {
        packages = packagesFor pkgs;
        checks = packages;
      }
    );
}
