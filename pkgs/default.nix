{ pkgs, pibox-framebuffer, pibox-os, pkgsPinned }:

rec {
  bcm2835 = pkgs.callPackage ./bcm2835.nix {
    inherit pibox-os;
  };

  firmware = pkgs.callPackage ./firmware.nix {
    inherit (pkgsPinned) deviceTree;
  };

  piboxFramebuffer = pkgs.callPackage ./framebuffer.nix {
    inherit pibox-framebuffer;
  };

  pwmFan = pkgs.callPackage ./pwm-fan {
    inherit bcm2835 pibox-os;
  };
}
