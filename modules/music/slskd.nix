{ config, pkgs, lib, ... }:

{
  services.slskd = {
    enable = true;
    environmentFile = "/home/xosc/secrets/slskd.env";
    domain = null;
    
    settings = {
      web.port = 5030;
      
      shares = {
        directories = ["/data/music"];
        filters = [
          "\.ini$"
        ];
      };

      soulseek.description = "hi! slskd user";
      soulseek.listen_port = 50300;

      global.upload.slots = 5;
      global.upload.speed_limit = 4000;

      directories.incomplete = "/data/slskd/incomplete";
      directories.downloads = "/data/slskd/downloads";

      integration.scripts.write_tags = {
        on = [ "DownloadDirectoryComplete" ];
        run = {
          command = ./run_wrtag.sh;
        };
      };
    };

    openFirewall = true;
  };

  systemd.services.slskd = {
    serviceConfig = {
      Group = lib.mkForce "media";
      UMask = 002;
    };
  };

  networking.firewall.allowedTCPPorts = [
    config.services.slskd.settings.web.port
    config.services.slskd.settings.soulseek.listen_port
  ];

  users.users.slskd = {
    extraGroups = [ "media" ];
  };
}
