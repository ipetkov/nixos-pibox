{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption;

  cfg = config.piboxKernelParams;
in
{
  options.piboxKernelParams.iomemRelaxed.enable = mkEnableOption "set iomem=relaxed kernel param";

  config = lib.mkIf cfg.iomemRelaxed.enable {
    boot.kernelParams = [
      "iomem=relaxed"
    ];
  };
}
