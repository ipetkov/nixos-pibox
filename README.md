# nixos-pibox

NixOS modules for supporting the hardware present on the [PiBox].

## Getting started

1. Import the repo as a flake input
2. Import the default NixOS module in your configuration
3. Add the default overlay to nixpkgs

Example flake.nix:
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-pibox = {
      url = "github:ipetkov/nixos-pibox";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-pibox, ... }: {
    nixosConfigurations.myPiboxHost = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        nixos-pibox.nixosModules.default
        # Import other modules here as necessary

        ({ ... }: {
          nixpkgs.overlays = [
            nixos-pibox.overlays.default
            # Add other overlays here
          ];

          # Enable the PWM fan and display stats service
          services.piboxPwmFan.enable = true;
          services.framebuffer.enable = true;
        })
      ];
    };
  };
}
```

## Firmware

You can install the necessary firmware to boot and the device tree blobs to
recognize the peripherals by building the `.#firmware` package and then copying
the results to the device's `/boot` partition:

```sh
nix build .#packages.aaarch64-linux.firmware
# e.g. mount the CM4's /boot partition under /mnt/boot first
cp result/* /mnt/boot
```

### Display Notes

As of February 2024 the framebuffer service has been rewritten to interface with
the Pibox display via SPI (and not the previous fbtft driver). This requires
updating the firmware files on the Pibox's `/boot` partition:

```sh
# Note that this will overwrite /boot/config.txt, so back up any changes there!
cp -r $(nix build .#packages.aarch64-linux.firmware) /boot
```

This only needs to be done once.

## Hardware support

### PWM Fan

The PiBox case comes with a fan for keeping the compute module cool. This module
packages (roughly) the same systemd service as in the [PiBox-OS] distribution
for running the fan.

Note that this implementation uses memory-mapped I/O to control the fan via the
Broadcom 2711 chip's hardware support for PWM signals. Unfortunately this does
require setting the `iomem=relaxed` kernel parameter which relaxes checks of
the regions that user-space programs may try to memory-map.

If you have ideas on improving this please start a discussion!

#### Supported options:

* `services.piboxPwmFan.enable`: enable or disable the service
  - default value: false
* `service.piboxPwmFan.package`: the package to run as part of the service
  - default value; `pkgs.pibox.pwmFan`
* `services.piboxFrameBuffer.enable`: enable or disable the display service
  - default value: false
* `service.piboxFrameBuffer.package`: the package to run as part of the service
  - default value; `pkgs.pibox.framebuffer`


[PiBox]: https://pibox.io/
[PiBox-OS]: https://github.com/kubesail/pibox-os
