{ ... }:

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

  # We enable temperature management to prevent the CPU from overheating.
  # This can also help with battery life.
  services.thermald.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
