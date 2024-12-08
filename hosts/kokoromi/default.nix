{ lib, pkgs, ... }:

{
  imports = [
    ./disko-config.nix
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
  services.libinput.touchpad.naturalScrolling = true;

  # We use power management to extend battery life.
  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;

      # Helps maintain long-term battery health when plugged in continuously.
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # We want to prevent accidental shutdowns.
  services.logind.powerKey = "ignore";

  # We need to fallback to unencrypted requests for eduroam to work.
  services.resolved.dnsovertls = lib.mkForce "opportunistic";

  # We enable temperature management to prevent the CPU from overheating.
  # This can also help with battery life.
  services.thermald.enable = true;

  environment.systemPackages = [ pkgs.brightnessctl ];

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
  system.stateVersion = "24.05"; # Did you read the comment?
}
