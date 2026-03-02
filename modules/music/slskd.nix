{ config, pkgs, lib, ... }:

let
  wrtag-hook = pkgs.writeShellScript "run_wrtag" ''
    set -euo pipefail
    
    export PATH=${pkgs.jq}/bin:${pkgs.curl}/bin:$PATH
    exec > >(${pkgs.systemd}/bin/systemd-cat -t wrtag) 2>&1
    
    echo "run_wrtag.sh started"
    echo "SLSKD_SCRIPT_DATA: ''$SLSKD_SCRIPT_DATA"

    download_path=$(echo "''${SLSKD_SCRIPT_DATA}" | jq -r .localDirectoryName)
    echo "download path: ''$download_path"

    curl \
      --request POST \
      --data-urlencode "path=''${download_path}" \
      "http://:verycoolpassword@localhost:7373/op/move"
  '';
in {
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
        on = [
          "DownloadDirectoryComplete"
          # "DownloadFileComplete"
        ];
        run = {
          executable = "${pkgs.bash}/bin/bash";
          args = wrtag-hook;
        };
      };
    };

    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    jq
  ];

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
    shell = pkgs.bash;
  };
}
