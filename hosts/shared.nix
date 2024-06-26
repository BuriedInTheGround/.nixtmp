{ config, lib, pkgs, currentHost, currentUser, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # We enable redistributable firmware for better hardware compatibility.
  hardware.enableRedistributableFirmware = true;

  nix = {
    # We always want to use the latest version of Nix so that we have access to
    # the latest updates for the experimental features.
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';

    # Save disk space by letting Nix automatically detect files in the store
    # that have identical content and replace them with hard links to a single
    # copy.
    settings.auto-optimise-store = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "${currentHost}"; # Define your hostname.

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # We use the X server keyboard settings for the virtual console keymap to
  # provide a more consistent experience.
  console.useXkbConfig = true;

  services.xserver = {
    enable = true;
    layout = "us,it";
    xkbOptions = "terminate:ctrl_alt_bksp,eurosign:e,grp:alt_space_toggle";
    xkbVariant = "us";

    # We want to symlink the X server configuration under /etc/X11/xorg.conf
    # so that localectl list-x11-keymap-layouts and similar commands work.
    exportConfiguration = true;

    displayManager = {
      defaultSession = "none+bspwm";
      lightdm = {
        enable = true;
        greeters.mini.enable = true;
        greeters.mini.user = "${currentUser}";
      };
    };

    # We will configure bspwm on a per-user basis using home-manager.
    windowManager.bspwm.enable = true;
  };

  environment.systemPackages = with pkgs; [
    file
    git
    gnumake
    parted
    pciutils
    psmisc
    unzip
    vim
    wget2
    xclip
    xorg.xev
  ];

  # Set up the systemd-resolved DNS resolver.
  services.resolved = {
    enable = true;
    dnssec = "false";
    extraConfig = ''
      [Resolve]
      DNS=1.1.1.1#one.one.one.one 1.0.0.1#one.one.one.one 2606:4700:4700::1111#one.one.one.one 2606:4700:4700::1001#one.one.one.one
      DNSOverTLS=yes
    '';
  };
}
