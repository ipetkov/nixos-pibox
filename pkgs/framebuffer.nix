{ buildGoModule
, pibox-framebuffer
, lib
}:

buildGoModule {
  name = "pibox-framebuffer";
  version = "v21";

  src = pibox-framebuffer;
  vendorSha256 = "sha256-+626pgKu9fj7W2wauq5kveEoHoBRTwgir9Z7HzkXZNs=";

  meta = with lib; {
    description = "The PiBox's display server. Lightweight Go binary to draw images to the framebuffer";
    homepage = "https://github.com/kubesail/pibox-framebuffer";
    license = [ ];
  };
}
