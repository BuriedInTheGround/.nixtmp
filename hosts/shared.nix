{ options, lib, pkgs, currentHost, currentUser, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # We enable redistributable firmware for better hardware compatibility.
  hardware.enableRedistributableFirmware = true;

  nix = {
    # We always want to use the latest version of Nix so that we have access to
    # the latest updates for the experimental features.
    package = pkgs.nixVersions.latest;

    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
      keep-derivations = true;
      keep-outputs = true;
      use-xdg-base-directories = true;
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "${currentHost}"; # Define your hostname.

    # Use Cloudflare DNS.
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    timeServers = options.networking.timeServers.default ++ [
      # Apple
      "time.apple.com"

      # Cloudflare
      "time.cloudflare.com"

      # Istituto nazionale di ricerca metrologica
      "ntp1.inrim.it"
      "ntp2.inrim.it"
    ];
  };

  # Use a Rust implementation of NTP.
  services.ntpd-rs.enable = true;

  # Use the systemd-resolved DNS resolver.
  services.resolved = {
    enable = true;
    dnsovertls = "true";
    dnssec = "false"; # Disabled as advised by upstream systemd.
    domains = [ "~." ];
  };

  # Query and manipulate storage devices as non-root.
  services.udisks2.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # We use the X server keyboard settings for the virtual console keymap to
  # provide a more consistent experience.
  console.useXkbConfig = true;

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us,it";
      options = "terminate:ctrl_alt_bksp,eurosign:e,grp:alt_space_toggle";
      variant = "us";
    };

    # We want to symlink the X server configuration under /etc/X11/xorg.conf
    # so that `localectl list-x11-keymap-layouts` and similar commands work.
    exportConfiguration = true;

    displayManager.lightdm = {
      enable = true;
      # Declutter users' home directories.
      extraConfig = ''
        user-authority-in-system-dir = true
      '';
      greeters.mini = {
        enable = true;
        user = "${currentUser}";
        extraConfig = ''
          [greeter]
          show-password-label = false
          password-alignment = left
          password-input-width = 20
          [greeter-theme]
          font = "Mono"
          font-size = 20px
          text-color = "#ffffff"
          error-color = "#ffffff"
          background-image = ""
          background-color = "#808080"
          window-color = "#808080"
          border-color = "#808080"
          password-character = *
          password-color = "#ffffff"
          password-background-color = "#000000"
          password-border-color = "#dddddd"
          password-border-radius = 0px
        '';
      };
    };

    # We will configure bspwm on a per-user basis using home-manager.
    windowManager.bspwm.enable = true;
  };

  services.displayManager.defaultSession = "none+bspwm";

  # Use GrapheneOS hardened memory allocator for better security.
  # To reduce the possibility of breakage, the light variant is selected.
  environment.memoryAllocator.provider = "graphene-hardened-light";

  environment.systemPackages = with pkgs; [
    file
    gcc
    git
    gnumake
    linux-manual
    man-pages
    man-pages-posix
    parted
    pciutils
    psmisc
    unzip
    vim
    wget2
    xclip
    xorg.xev
  ];

  documentation = {
    dev.enable = true;
    nixos.includeAllModules = true;
  };

  # Setting this to true slows down nixos-rebuild too much.
  # To make apropos usable, run:
  #
  #   sudo mkdir -p /var/cache/man/nixos
  #   sudo mandb
  #
  documentation.man.generateCaches = lib.mkForce false;
}
