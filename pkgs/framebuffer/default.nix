{ buildGoModule
, pibox-framebuffer
, lib
, vendorHash ? "sha256-3WIp/+dagzk4h6DPIe0tveTMtPqmTl6nXNhq6s2r7Ss="
}:

buildGoModule {
  name = "pibox-framebuffer";
  version = "v21";

  src = pibox-framebuffer;
  inherit vendorHash;

  patches = [
    ./0001-no-panic-missing-font.patch
    ./0002-enable-stats.patch
  ];

  postInstall = ''
    ln -s $out/bin/{cmd,pibox-framebuffer}
  '';

  meta = with lib; {
    description = "The PiBox's display server. Lightweight Go binary to draw images to the framebuffer";
    homepage = "https://github.com/kubesail/pibox-framebuffer";
    license = [ ];
  };
}
