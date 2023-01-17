{ config, pkgs, lib, ... }:

let
  inherit (lib)
    escapeShellArg
    mkDefault
    mkEnableOption
    mkOption
    types;

  cfg = config.services.piboxFramebuffer;
in
{
  options.services.piboxFramebuffer = {
    enable = mkEnableOption "pibox framebuffer service";

    diskMountPrefix = mkOption {
      type = types.str;
      default = "/";
      description = "The disk prefix to use when showing usage stats";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.pibox.framebuffer;
      defaultText = "pkgs.pibox.framebuffer";
      description = "Package providing the framebuffer binary";
    };
  };

  config = lib.mkIf cfg.enable {
    piboxKernelParams.iomemRelaxed.enable = mkDefault true;

    systemd.services.piboxFramebuffer = {
      description = "The PiBox's display server. Lightweight Go binary to draw images to the framebuffer";
      wantedBy = [ "multi-user.target" ];

      script = ''
        export DISK_MOUNT_PREFIX="${escapeShellArg cfg.diskMountPrefix}"
        export LISTEN_SOCKET="$RUNTIME_DIRECTORY/framebuffer.sock";
        exec ${cfg.package}/bin/pibox-framebuffer
      '';

      serviceConfig = {
        Type = "simple";
        User = "root";

        AmbientCapabilities = "CAP_CHMOD CAP_SYS_RAWIO";
        CapabilityBoundingSet = "CAP_CHMOD CAP_SYS_RAWIO";
        IPAddressDeny = "any";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        Restart = "on-failure";
        RestrictAddressFamilies = "AF_NETLINK AF_UNIX";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RuntimeDirectoryMode = "0755";
        RuntimeDirectory = "pibox";
        SystemCallArchitectures = "native";
        SystemCallFilter = "~@clock @debug @module @mount @reboot @swap @privileged @resources @cpu-emulation @obsolete";
        UMask = "0177";
        WorkingDirectory = "${cfg.package}";
      };
    };
  };
}
