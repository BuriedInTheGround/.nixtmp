{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.garden.bspwm;

  primitive = with types; oneOf [ bool int float str ];

  rule = types.submodule {
    freeformType = with types; attrsOf primitive;

    options = {
      monitor = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The monitor where the rule should be applied.";
        example = "HDMI-0";
      };

      desktop = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The desktop where the rule should be applied.";
        example = "^8";
      };

      node = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The node where the rule should be applied.";
        example = "1";
      };

      state = mkOption {
        type = types.nullOr
        (types.enum [ "tiled" "pseudo_tiled" "floating" "fullscreen" ]);
        default = null;
        description = "The state in which a new window should spawn.";
        example = "floating";
      };

      layer = mkOption {
        type = types.nullOr (types.enum [ "below" "normal" "above" ]);
        default = null;
        description = "The layer where a new window should spawn.";
        example = "above";
      };

      splitDir = mkOption {
        type = types.nullOr (types.enum [ "north" "west" "south" "east" ]);
        default = null;
        description = ''
          The direction where the container is going to be split.
        '';
        example = "south";
      };

      splitRatio = mkOption {
        type = types.nullOr types.float;
        default = null;
        description = ''
          The ratio between the new window and the previous existing window in
          the desktop.
        '';
        example = 0.65;
      };

      hidden = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Whether the node should occupy any space.";
        example = true;
      };

      sticky = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Whether the node should stay on the focused desktop.";
        example = true;
      };

      private = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = ''
          Whether the node should stay in the same tiling position and size.
        '';
        example = true;
      };

      locked = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = ''
          Whether the node should ignore {command}`node --close`
          messages.
        '';
        example = true;
      };

      marked = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Whether the node will be marked for deferred actions.";
        example = true;
      };

      center = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = ''
          Whether the node will be put in the center, in floating mode.
        '';
        example = true;
      };

      follow = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Whether focus should follow the node when it is moved.";
        example = true;
      };

      manage = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = ''
          Whether the window should be managed by bspwm. If false, the window
          will be ignored by bspwm entirely. This is useful for overlay apps,
          e.g. screenshot tools.
        '';
        example = true;
      };

      focus = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Whether the node should gain focus on creation.";
        example = true;
      };

      border = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Whether the node should have border.";
        example = true;
      };

      rectangle = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The node's geometry, in the format `WxH+X+Y`.";
        example = "800x600+32+32";
      };
    };
  };
in {
  options.garden.bspwm = {
    enable = mkEnableOption "bspwm";

    extraKeybindings = mkOption {
      type = types.attrsOf (types.nullOr (types.oneOf [ types.str types.path ]));
      default = { };
      description = "Extra hotkeys added to the sxhkd configuration file.";
      example = literalExpression ''
        {
          "alt + shift + x" = "betterlockscreen -l dim";
        }
      '';
    };

    extraSettings = mkOption {
      type = with types; attrsOf (either primitive (listOf primitive));
      default = { };
      description = "Extra settings added to the bspwm configuration file.";
    };

    rules = mkOption {
      type = types.attrsOf rule;
      default = { };
      description = ''
        Rule configuration. The keys of the attribute set are the targets of
        the rules.
      '';
      example = literalExpression ''
        {
          "Gimp" = {
            desktop = "^8";
            state = "floating";
            follow = true;
          };
          "Kupfer.py" = {
            focus = true;
          };
          "Screenkey" = {
            manage = false;
          };
        }
      '';
    };

    startupPrograms = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Programs to be executed during startup.";
      example = [ "numlockx on" "tilda" ];
    };

    terminalEmulator = mkOption {
      type = types.str;
      default = "alacritty";
      description = ''
        Preferred terminal emulator to launch with the `super + Escape` hotkey.
      '';
      example = "urxvt";
    };
  };

  config = mkIf cfg.enable {
    xsession.enable = true;
    xsession.windowManager.bspwm = {
      enable = true;
      monitors = {
        "primary" = [ "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" ];
      };
      settings = recursiveUpdate {
        split_ratio = 0.5;
        borderless_monocle = true;
        gapless_monocle = true;
        window_gap = 10;
        border_width = 2;
      } cfg.extraSettings;
      rules = cfg.rules;
      startupPrograms = cfg.startupPrograms;
    };

    services.sxhkd = {
      enable = true;
      keybindings =
      let
        terminalEmulator = if cfg.terminalEmulator == "alacritty" then
          "alacritty msg create-window || alacritty"
        else
          "${cfg.terminalEmulator}";
      in recursiveUpdate {
        # Force sxhkd to reload its configuration files.
        "super + Escape" = "pkill -USR1 -x sxhkd";

        # Launch the terminal emulator.
        "super + Return" = "${terminalEmulator}";
        "super + KP_Enter" = "${terminalEmulator}";

        # Control the audio volume level.
        "XF86Audio{Lower,Raise}Volume" = "${pkgs.wireplumber}/bin/wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ 0.05{-,+}";
        "@XF86AudioMute" = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

        # Quit/Restart bspwm.
        "super + alt + {q,r}" = "bspc {quit,wm -r}";

        # Close/Kill application.
        "super + {_,shift + }w" = "bspc node -{c,k}";

        # Toggle between the tiled and monocle layouts.
        "super + m" = "bspc desktop -l next";

        # Send the newest marked node to the newest preselected node.
        "super + y" = "bspc node newest.marked.local -n newest.!automatic.local";

        # Swap the current node and the biggest window.
        "super + g" = "bspc node -s biggest.window";

        # Set the window state: tiled, pseudo_tiled, floating, fullscreen.
        "super + {t,shift + t,s,f}" = "bspc node -t {tiled,pseudo_tiled,floating,fullscreen}"; 

        # Set the node flags: marked, locked, sticky, private.
        "super + ctrl + {m,x,y,z}" = "bspc node -g {marked,locked,sticky,private}";

        # Focus/Send the node in the given direction.
        "super + {_,shift + }{h,j,k,l}" = "bspc node -{f,s} {west,south,north,east}";

        # Focus the node for the given path jump.
        "super + {p,b,comma,period}" = "bspc node -f @{parent,brother,first,second}";

        # Focus the next/previous window in the current desktop.
        "super + {_,shift + }c" = "bspc node -f {next,prev}.local.!hidden.window"; 

        # Focus the next/previous desktop (current monitor or globally).
        "super + bracket{left,right}{_, + shift}" = "bspc desktop -f {prev,next}{.local,_}";

        # Focus the last node/desktop.
        "super + {grave,Tab}" = "bspc {node,desktop} -f last";

        # Focus the older/newer node in the focus history.
        "super + {o,i}" = "bspc wm -h off; bspc node {older,newer} -f; bspc wm -h on";

        # Focus/Send to the given desktop.
        "super + {_,shift + }{1-9,0}" = "bspc {desktop -f,node -d} '{1-9,10}'";

        # Preselect the direction.
        "super + ctrl + {h,j,k,l}" = "bspc node -p {west,south,north,east}";

        # Preselect the split ratio (between 0.1 and 0.9).
        "super + ctrl + {1-9}" = "bspc node -o 0.{1-9}";

        # Cancel the preselection for the focused node.
        "super + ctrl + space" = "bspc node -p cancel";

        # Cancel the preselection for the focused desktop.
        "super + ctrl + shift + space" = "bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel";

        # Rotate the tree nodes of the focused desktop.
        "super + shift + {d,a}" = "bspc node @/ -C {forward,backward}"; 

        # Expand a window by moving one of its sides outward.
        "super + alt + {h,j,k,l}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";

        # Contract a window by moving one of its sides inward.
        "super + alt + shift + {h,j,k,l}" = "bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}";

        # Move a floating window.
        "super + {Left,Down,Up,Right}" = "bspc node -v {-20 0,0 20,0 -20,20 0}";
      } cfg.extraKeybindings;
    };
  };
}
