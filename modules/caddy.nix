{ pkgs, config, ... }:
{
  services.caddy = {
    enable = true;

    virtualHosts.":80".extraConfig = ''
      reverse_proxy 127.0.0.1:4533
    '';

    virtualHosts.":8080".extraConfig = ''
      reverse_proxy 127.0.0.1:5030
    '';
  };
}

