flake: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.simple-test-api;
  user = "apiuser";
  group = "apigroup";
  inherit (flake.packages.${pkgs.stdenv.hostPlatform.system}) simple-test-api;
in {
  options = {
    services.simple-test-api = {
      enable = lib.mkEnableOption ''
        simple api for test-environment
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users."${user}" = {
      description = "api daemon user";
      isSystemUser = true;
      group = "${group}";
    };

    users.groups.${group} = {};

    systemd.services.simple-test-api = {
      description = "simple test api";

      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = "${user}";
        Group = "${group}";
        Restart = "always";
        ExecStart = "${lib.getBin simple-test-api}/bin/simple-test-api -a 127.0.0.1:8080";
      };
    };
  };
}
