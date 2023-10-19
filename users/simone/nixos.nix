{ config, lib, pkgs, currentSystemName, currentUser, ... }:

{
  programs.zsh = {
    enable = true;

    # Since we enabled Zsh completion in home.nix via home-manager, we set this
    # to false to avoid calling compinit twice.
    enableCompletion = false;
  };

  # This is necessary to get completion for system packages. Since
  # programs.zsh.enableCompletion is set to false, this is not set
  # automatically.
  environment.pathsToLink = [ "/share/zsh" ];

  # We enable the dconf configuration system. This is necessary for the
  # GSettings options to be applied correctly.
  programs.dconf.enable = true;

  # We enable the geolocation service for Redshift to work properly.
  services.geoclue2.enable = true;

  services.keyd = lib.mkIf (currentSystemName == "kokoromi") {
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
      pkgs.dejavu_fonts
      pkgs.fira-code-nerdfont
      pkgs.noto-fonts-emoji
    ];
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "DejaVu Sans" ];
      serif = [ "DejaVu Serif" ];
      monospace = [ "FiraCode Nerd Font Mono" "Noto Color Emoji" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  users.users.${currentUser} = {
    isNormalUser = true;
    description = "Simone Ragusa";
    extraGroups = [ "wheel" "audio" "video" "networkmanager" ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$S3pjVZTRl4iZNiYumeN4E0$QjbMrNx7K1t25pEhrXMnMAOtQSQ750NV1dqOJ7UBOP5"; # TODO: Change, now is "nixos".
  };
}
