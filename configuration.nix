# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/wireguard.nix
      ./modules/music/slskd.nix
      ./modules/music/wrtag.nix
      # /home/xosc/mcserber/mcserber.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "serber1"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "UTC";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    # useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "bc2fead2";

  fileSystems = {
    "/".options = [ "compress=zstd" "relatime" ];
    "/home".options = [ "compress=zstd" "relatime" ];
    "/etc".options = [ "compress=zstd" "relatime" ];
    "/nix".options = [ "compress=zstd" "noatime" ];
    "/var/log".options = [ "compress=zstd" "relatime" ];
  };

  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "monthly";
  
  fileSystems."/data" =
    { device = "lake";
      fsType = "zfs";
    };

  fileSystems."/data/music" =
    { device = "lake/music";
      fsType = "zfs";
    };

  fileSystems."/data/slskd" =
    { device = "lake/slskd";
      fsType = "zfs";
    };

  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  users.groups.media = {};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.xosc = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "media" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
    '';
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    htop
    nano
    vim 
    helix
    git
    gh
    nmap
    nettools
    iputils
    unzip
    wget
    tree

    wireguard-tools
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # virtualisation.docker = {
  #   enable = true;
  #   storageDriver = "btrfs";
  # };

  # systemd.services.myapp = {
  #   description = "My Docker App";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "docker.service" ];
  
  #   serviceConfig = {
  #     ExecStart = ''
  #       ${pkgs.docker}/bin/docker compose up -d \
  #         --file /home/xosc/mcserber/compose.yml \
  #         --project-name mcserber \
  #    '';
  #     ExecStop = ''
  #       ${pkgs.docker}/bin/docker compose -p mcserber down
  #     '';
  #   };
  # };
  
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 443 ];
    settings = {
      PermitRootLogin = "no";
      AllowUsers = ["xosc"];
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "20m";
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 25565 8080 80 443 ];
  networking.firewall.allowedUDPPorts = [ 25565 8080 80 443 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

