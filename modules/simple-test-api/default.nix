{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.simple-test-api;
in {
  options = {
    services.simple-test-api = {
      enable = mkEnableOption ''
        simple api for test-environment
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.simple-test-api = {
      description = "api daemon user";
      isSystemUser = true;
      group = "simple-test-api";
    };

    users.groups.simple-test-api = {};

    systemd.services.simple-test-api = {
      description = "simple test api";

      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = "simple-test-api";
        Group = "simple-test-api";
        Restart = "always";
        ExecStart = "${lib.getBin pkgs.simple-test-api}/bin/simple-test-api -a 127.0.0.1:8080";
      };
    };
  };
}
