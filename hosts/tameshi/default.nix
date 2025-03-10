{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # We want to delete all files in /tmp during boot.
  boot.tmp.cleanOnBoot = true;

  # We enable the BBR TCP congestion control algorithm.
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # We want NTFS support.
  boot.supportedFilesystems.ntfs = true;

  # We use NetworkManager for networking.
  networking.networkmanager.enable = true;

  # We use the Italian time zone.
  time.timeZone = "Europe/Rome";

  # We enable audio with PipeWire and RealtimeKit for real-time audio.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # We enable Bluetooth and tweak it to make it more responsive.
  hardware.bluetooth = {
    enable = true;
    settings.General = {
      DiscoverableTimeout = 0;
      FastConnectable = true;
      JustWorksRepairing = "confirm";
    };
  };

  # We enable the local print service with wireless availability.
  services.printing = {
    enable = true;
    drivers = [ pkgs.epson-escpr2 ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # TODO: Remove.
  virtualisation.vmVariant = {
    boot.loader.timeout = 0;
    virtualisation = {
      cores = 2;
      memorySize = 4096;
      resolution = {
        x = 1920;
        y = 1080;
      };
      sharedDirectories = {
        share = {
          source = "/home/simone/tmp";
          target = "/mnt/shared";
        };
      };
    };
  };

  environment.systemPackages = [
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.uutils-coreutils-noprefix
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
