{ pibox-os
, lib
, libcap
, stdenv
}:

stdenv.mkDerivation {
  name = "bcm2835";
  version = "1.68";

  src = "${pibox-os}/pwm-fan/bcm2835-1.68.tar.gz";

  makeFlags = "CFLAGS=-DBCM2835_HAVE_LIBCAP";

  buildInputs = [
    libcap
  ];

  meta = with lib; {
    description = "C library for Broadcom BCM 2835 as used in Raspberry Pi";
    homepage = "https://www.airspayce.com/mikem/bcm2835/index.html";
    license = with licenses; [ gpl3Only ];
  };
}
