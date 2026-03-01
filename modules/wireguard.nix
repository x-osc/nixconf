{ config, pkgs, lib, ... }:

{
  config = {
    # boot.kernel.sysctl = {
    #   "net.ipv4.ip_forward" = 1;
    #   "net.ipv6.conf.all.forwarding" = 1;
    # };
    
    networking.useNetworkd = true;

    networking.nat = {
      enable = true;
      externalInterface = "eno1";
      internalInterfaces = [ "wg0" ];
    };

    systemd.network = {
      enable = true;

      networks."50-wg0" = {
        matchConfig.Name = "wg0";
        
        networkConfig = {
          IPv4Forwarding = true;
        };

        address = [
          "fd31:bf08:57cb::7/64"
          "192.168.26.7/24"
        ];
      };

      netdevs."50-wg0" = {
        netdevConfig = {
          Kind = "wireguard";
          Name = "wg0";
        };

        wireguardConfig = {
          ListenPort = 51820;

          # ensure file is readable by `systemd-network` user
          PrivateKeyFile = "/etc/wireguard/wg0.key";

          # To automatically create routes for everything in AllowedIPs,
          # add RouteTable=main
          RouteTable = "main";

          # FirewallMark marks all packets send and received by wg0 
          # with the number 42, which can be used to define policy rules on these packets. 
          FirewallMark = 42;
        };
        wireguardPeers = [
          {
            # laptop wg conf
            PublicKey = "rARCHL0HiXneUt9Je5gI8yD7/3taSf7ECYw4yYGk0wM=";
            AllowedIPs = [
              "192.168.26.8/32"
            ];

            # RouteTable can also be set in wireguardPeers
            # RouteTable in wireguardConfig will then be ignored.
            # RouteTable = 1000;
          }
        ];
      };
    };
  };
}

