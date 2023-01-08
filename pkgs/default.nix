{ pkgs, pibox-os }:

rec {
  bcm2835 = pkgs.callPackage ./bcm2835.nix {
    inherit pibox-os;
  };

  firmware = pkgs.callPackage ./firmware.nix { };

  pwmFan = pkgs.callPackage ./pwm-fan {
    inherit bcm2835 pibox-os;
  };
}
