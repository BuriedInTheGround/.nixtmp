{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.garden.firefox.tridactyl;
in {
  options.garden.firefox.tridactyl = {
    enable = mkEnableOption "Tridactyl";

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/tridactyl/tridactylrc`.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      profiles.default.extensions = [
        pkgs.nur.repos.rycee.firefox-addons.tridactyl
      ];
    };

    xdg.configFile."tridactyl/tridactylrc" = mkIf (cfg.extraConfig != "") {
      text = cfg.extraConfig;
    };
  };
}
