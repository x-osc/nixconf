{ config, lib, pkgs, ... }:

{
  services.navidrome = {
    enable = true;

    settings = {
      Port = 4533;
      MusicFolder = "/data/music";
      DataFolder = "/var/lib/navidrome";
      EnableInsightsCollector = true;
      Address = "0.0.0.0";
    };

    openFirewall = true;
  };

  # networking.firewall.allowedTCPPorts = [
  #   config.services.navidrome.settings.Port
  # ];

  users.users.navidrome = {
    extraGroups = [ "media" ];
  };
}
