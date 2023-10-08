{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.garden.alacritty;
in {
  options.garden.alacritty = {
    enable = mkEnableOption "Alacritty";

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
      type = types.listOf (pkgs.formats.yaml { }).type;
      default = [ ];
      description = "Extra hints added to the Alacritty configuration file.";
    };
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        import = mkIf (cfg.import != [ ]) cfg.import;
        env.TERM = "alacritty";
        window.dynamic_padding = true;
        cursor.style.blinking = "On";
        colors = mkIf (cfg.colors != null) cfg.colors;
        hints.enabled = [
          {
            regex = "(ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh:|ftp://)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\\\s{-}\\\\^⟨⟩`]+";
            hyperlinks = true;
            command = "xdg-open";
            post_processing = true;
            persist = false;
            mouse = { enabled = true; };
            binding = { key = "U"; mods = "Control|Shift"; };
          }
          {
            regex = "[a-f0-9]{40}|[a-f0-9]{7,8}";
            action = "Copy";
            binding = { key = "H"; mods = "Control|Shift"; };
          }
        ] ++ cfg.extraHints;
        key_bindings = [
          # Ctrl-modified direct UTF-8 numbers.
          #
          # See https://www.leonerd.org.uk/hacks/fixterms/ for codes.
          #
          # Note that we cannot use caret notation or the octal value for
          # the ESC character because Alacritty does not support it.
          { key = "Key1"; mods = "Control"; chars = "\\x1b[49;5u"; }
          { key = "Key2"; mods = "Control"; chars = "\\x1b[50;5u"; }
          { key = "Key3"; mods = "Control"; chars = "\\x1b[51;5u"; }
          { key = "Key4"; mods = "Control"; chars = "\\x1b[52;5u"; }
          { key = "Key5"; mods = "Control"; chars = "\\x1b[53;5u"; }
          { key = "Key6"; mods = "Control"; chars = "\\x1b[54;5u"; }
          { key = "Key7"; mods = "Control"; chars = "\\x1b[55;5u"; }
          { key = "Key8"; mods = "Control"; chars = "\\x1b[56;5u"; }
          { key = "Key9"; mods = "Control"; chars = "\\x1b[57;5u"; }
        ];
      };
    };
  };
}
