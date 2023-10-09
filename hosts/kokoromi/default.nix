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

  # See hosts/shared.nix.
  system.stateVersion = "23.05"; # Did you read the comment?
}
