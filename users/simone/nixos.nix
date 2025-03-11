{ lib, pkgs, currentHost, currentUser, ... }:

{
  # Unfortunately, Chromium is unfree.
  nixpkgs.config.allowUnfree = true;

  # We configure the Android Debug Bridge (adb) to work with Android devices.
  programs.adb.enable = true;

  # We enable seamless execution of AppImage applications.
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Start the OpenSSH agent at login. Keys can be added with ssh-add, the agent
  # will remember the passphrase.
  programs.ssh.startAgent = true;

  programs.zsh = {
    enable = true;

    # Since we handle Zsh completion in home.nix via home-manager, we set this
    # to false to avoid calling compinit multiple times.
    enableCompletion = false;
  };

  # This is necessary for Chrome Enterprise policies to be applied.
  environment.etc."chromium/policies" = {
    source = "/home/${currentUser}/.config/chromium/policies";
    mode = "symlink";
  };

  environment.pathsToLink = [
    # This is necessary to get completion for system packages. Since
    # programs.zsh.enableCompletion is set to false, this is not set
    # automatically.
    "/share/zsh"

    # This is necessary for the XDG desktop integration to work properly.
    "/share/xdg-desktop-portal" "/share/applications"
  ];

  # We enable the dconf configuration system. This is necessary for the
  # GSettings options to be applied correctly.
  programs.dconf.enable = true;

  # We enable Docker, as it is useful when someone gives us a Docker
  # Compose service or the like.
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    autoPrune.enable = true;
  };

  # We enable the geolocation service for Redshift to work properly.
  services.geoclue2.enable = true;

  services.keyd = lib.mkIf (currentHost == "kokoromi") {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        # Remap KP_Enter to Return.
        kpenter = "enter";
      };
    };
  };

  fonts = {
    enableDefaultPackages = true;
    packages = [
      pkgs.atkinson-hyperlegible
      pkgs.commit-mono # Monospace
      pkgs.dejavu_fonts # Fallbacks
      pkgs.departure-mono
      pkgs.dotcolon-fonts
      pkgs.eb-garamond
      pkgs.fira-code
      pkgs.fira-sans
      pkgs.ibm-plex
      pkgs.inter
      pkgs.jetbrains-mono
      pkgs.libertine
      pkgs.libre-baskerville
      pkgs.merriweather
      pkgs.mona-sans
      pkgs.monaspace
      pkgs.newcomputermodern
      pkgs.noto-fonts
      pkgs.noto-fonts-color-emoji # Emoji
      pkgs.public-sans # Sans-serif
      pkgs.source-code-pro
      pkgs.source-sans
      pkgs.source-serif
      pkgs.times-newer-roman # Serif
      pkgs.tt2020
      pkgs.ucs-fonts
      pkgs.work-sans
      (pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    ];
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Public Sans" "DejaVu Sans" ];
      serif = [ "Times Newer Roman" "DejaVu Serif" ];
      monospace = [ "Commit Mono" "DejaVu Sans Mono" "Symbols Nerd Font Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  users.users.${currentUser} = {
    isNormalUser = true;
    description = "Simone Ragusa";
    extraGroups = [ "wheel" "audio" "video" "networkmanager" "adbusers" "dialout" "docker" "wireshark" ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$S3pjVZTRl4iZNiYumeN4E0$QjbMrNx7K1t25pEhrXMnMAOtQSQ750NV1dqOJ7UBOP5"; # TODO: Change, now it's "nixos".
  };
}
