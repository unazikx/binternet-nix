{
  self,
  ...
}:
{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.services.binternet;
in

{
  options = {
    services.binternet = {
      enable = lib.mkEnableOption "Binternet";

      package = lib.mkOption {
        type = lib.types.package;
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.binternet;
        description = "Package to use for binternet";
      };

      openFirewall = lib.mkEnableOption "Whether to open the firewall for the port in {option}`services.binternet.port`.";

      port = lib.mkOption {
        type = lib.types.int;
        description = "Port to bind webserver.";
        default = 3000;
        example = 8080;
      };

      host = lib.mkOption {
        type = lib.types.str;
        description = "Host to bind webserver.";
        default = "127.0.0.1";
        example = "0.0.0.0";
      };

      extraArgs = lib.mkOption {
        type = with lib.types; listOf str;
        description = "Extra arguments passed to `binternet`. (php flags)";
        default = [ ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.binternet = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.concatStringsSep " " (
          [
            (lib.getExe pkgs.php84) # https://github.com/Ahwxorg/Binternet/blob/c3a3ce76bf12b8dfabebaa14f33e46181ac199d3/Dockerfile#L3
            "-S ${cfg.host}:${toString cfg.port}"
            "-t ${cfg.package}"
          ]
          ++ cfg.extraArgs
        );
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall (
      lib.genAttrs [
        "allowedTCPPorts"
      ] (_: [ cfg.port ])
    );
  };
}
