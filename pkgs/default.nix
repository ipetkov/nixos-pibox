{ pkgs, pibox-os }:

rec {
  default = pwmFan;

  bcm2835 = pkgs.callPackage ./bcm2835.nix {
    inherit pibox-os;
  };

  pwmFan = pkgs.callPackage ./pwm-fan {
    inherit bcm2835 pibox-os;
  };
}
