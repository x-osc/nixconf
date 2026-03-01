{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wrtag
    rsgain
    jq
  ];

  environment.sessionVariables = {
    WRTAG_CONFIG_PATH = ./wrtag.conf;
  };

  # users.groups.wrtag = {};
  # users.users.wrtag = {
  #   isSystemUser = true;
  #   group = "wrtag";
  #   extraGroups = [ "media" ];
  # };

  systemd.services.wrtagweb = {
    description = "wrtag web interface";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    environment = {
      XDG_CONFIG_HOME = "/";
      WRTAG_CONFIG_PATH = ./wrtag.conf;
    };

    path = with pkgs; [
      wrtag
      rsgain
    ];

    serviceConfig = {
      ExecStart = "${pkgs.wrtag}/bin/wrtagweb";
      Restart = "always";

      User = "xosc";
      Group = "media";
    };
  };

  networking.firewall.allowedTCPPorts = [ 7373 ];
}
