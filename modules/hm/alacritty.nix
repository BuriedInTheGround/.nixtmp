{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.garden.alacritty;
in {
  options.garden.alacritty = {
    enable = mkEnableOption "Alacritty";

    transparency = mkEnableOption "terminal transparency";

    import = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Configuration of the `import` section of Alacritty.";
    };

    colors = mkOption {
      type = (pkgs.formats.yaml { }).type;
      default = null;
      description = "Configuration of the `colors` section of Alacritty.";
    };

    extraHints = mkOption {
      type = types.listOf (pkgs.formats.toml { }).type;
      default = [ ];
      description = "Extra hints added to the Alacritty configuration file.";
    };
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.alacritty;
      settings = {
        import = mkIf (cfg.import != [ ]) cfg.import;
        env.TERM = "alacritty";
        window.dynamic_padding = true;
        window.opacity = mkIf cfg.transparency 0.95;
        cursor.style.blinking = "On";
        colors = mkIf (cfg.colors != null) cfg.colors;
        hints.enabled = [
          {
            regex = "(ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh:|ftp://)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\\\s{-}\\\\^⟨⟩`\\\\\\\\]+";
            hyperlinks = true;
            post_processing = true;
            persist = false;
            command = "xdg-open";
            binding = { key = "O"; mods = "Control|Shift"; };
            mouse.enabled = true;
          }
          {
            regex = "[0-9a-f]{7,40}";
            action = "Copy";
            binding = { key = "H"; mods = "Control|Shift"; };
          }
        ] ++ cfg.extraHints;
      };
    };
  };
}
