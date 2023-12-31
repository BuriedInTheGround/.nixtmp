{ config, pkgs, ... }:

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

  # We use NetworkManager for networking.
  networking.networkmanager.enable = true;

  # We use the Italian time zone.
  time.timeZone = "Europe/Rome";

  # We disable ALSA sound as it seems to cause conflicts with PipeWire.
  sound.enable = false;

  # We enable audio with PipeWire and RealtimeKit for real-time audio.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # We enable natural scrolling for the touchpad.
  services.xserver.libinput.touchpad.naturalScrolling = true;

  # We use power management to extend battery life.
  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";
  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
    };
  };

  # We want to prevent accidental shutdowns.
  services.logind.powerKey = "ignore";

  # We enable temperature management to prevent the CPU from overheating.
  # This can also help with battery life.
  services.thermald = {
    enable = true;
    package = pkgs.thermald.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        (pkgs.fetchurl {
          url = "https://patch-diff.githubusercontent.com/raw/intel/thermal_daemon/pull/422.patch";
          hash = "sha256-GQFMgVA+cLEQ/zsjq9Zj8ifk+6k2aHSLqx9BAyxMG/c=";
        })
      ];
    });
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
