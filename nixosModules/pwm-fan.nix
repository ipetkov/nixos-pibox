{ config, pkgs, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkOption
    types;

  cfg = config.services.piboxPwmFan;
in
{
  options.services.piboxPwmFan = {
    enable = mkEnableOption "pibox PWM fan service";

    package = mkOption {
      type = types.package;
      default = pkgs.pibox.pwmFan;
      defaultText = "pkgs.pibox.pwmFan";
      description = "Package providing the pwmFan binary";
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      kernelParams = [
        "iomem=relaxed"
      ];
    };

    systemd.services.piboxPwmFan = {
      description = "Hardware PWM control for Raspberry Pi 4 Case Fan";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/pibox-pwm-fan";
        User = "root";

        AmbientCapabilities = "CAP_SYS_RAWIO";
        CapabilityBoundingSet = "CAP_SYS_RAWIO";
        IPAddressDeny = "any";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateNetwork = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "full";
        Restart = "on-failure";
        RestrictAddressFamilies = "none";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = "~@clock @debug @module @mount @reboot @swap @privileged @resources @cpu-emulation @obsolete";
        UMask = "0177";
        WorkingDirectory = "${cfg.package}";
      };
    };
  };
}
