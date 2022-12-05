{ bcm2835
, pibox-os
, lib
, libcap
, stdenv
}:

stdenv.mkDerivation {
  name = "pwm-fan";
  version = "0.1";

  src = pibox-os;
  sourceRoot = "source/pwm-fan";

  patches = [
    ./0001-remove-file-writes.patch
  ];

  buildInputs = [
    bcm2835
    libcap
  ];

  preBuild = ''
    makeFlagsArray+=(LIBS="-lbcm2835 -lcap")
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv pi_fan_hwpwm $out/bin
    ln -s $out/bin/{pi_fan_hwpwm,pibox-pwm-fan}
  '';

  meta = with lib; {
    description = "This is a fork of https://gist.github.com/alwynallan/1c13096c4cd675f38405702e89e0c536 for use with the KubeSail PiBox";
    homepage = "https://github.com/kubesail/pibox-os";
    license = [ ];
  };
}
