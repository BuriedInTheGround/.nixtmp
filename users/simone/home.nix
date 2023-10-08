{ config, lib, pkgs, currentUser, ... }:

{
  imports = [
    ../../modules/hm
  ];

  home.username = "${currentUser}";
  home.homeDirectory = "/home/${currentUser}";

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.age
    pkgs.bunnyfetch
    pkgs.cava
    pkgs.fd
    pkgs.ffmpeg
    # TODO: pkgs.gimp
    # TODO: pkgs.inkscape
    pkgs.logseq
    pkgs.mission-center # TODO: Remove after GTK theming.
    pkgs.mpc-cli
    pkgs.neovim # TODO: Configure.
    # TODO: pkgs.onlyoffice-bin_latest
    pkgs.pavucontrol
    pkgs.pfetch-rs
    pkgs.telegram-desktop
    pkgs.tree
    (pkgs.parallel-full.override {
      willCite = true;
    })
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/Scripts"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    BAT_THEME = "ansi";
  };

  home.shellAliases = {
    ".."      = "cd ..";
    "..."     = "cd ../..";
    "...."    = "cd ../../..";
    "q"       = "exit";
    "Q"       = "exit";
    "clr"     = "clear";
    "sudo"    = "sudo "; # Make sudo work with aliases.
    "cp"      = "cp -i";
    "mv"      = "mv -i";
    "t"       = "tree";
    "md"      = "mkdir -pv";
    "rr"      = "rm -r";
    "pbcopy"  = "xclip -selection clipboard";
    "pbpaste" = "xclip -selection clipboard -o";
    "gti"     = "printf '\\x1b[1;33mI absolutely know that you meant to type \\x1b[1;35m\"git\"\\x1b[1;33m.\\x1b[0m\\n\\n';git ";
    "pf"      = "PF_ASCII=linux PF_COL1=6 PF_COL2=3 PF_COL3=1 PF_INFO='ascii title os kernel uptime pkgs shell memory' pfetch";
  };

  xdg.userDirs.enable = true;

  # TODO: Finish theme configuration.
  gtk = let
    extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  in {
    enable = true;
    theme.package = pkgs.adw-gtk3;
    theme.name = "adw-gtk3";
    gtk3 = { inherit extraConfig; };
    gtk4 = { inherit extraConfig; };
  };
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    antidote = {
      enable = true;
      plugins = [
        "romkatv/powerlevel10k"
        "MichaelAquilina/zsh-you-should-use"
        "zsh-users/zsh-completions"
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-history-substring-search"
        "softmoth/zsh-vim-mode"
      ];
      useFriendlyNames = true;
    };
    dotDir = ".config/zsh";
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreAllDups = true;
      ignoreDups = true;
      ignorePatterns = [ "rm *" ];
      ignoreSpace = true;
      share = true;
    };
    initExtraFirst = ''
      if [[ -r "$\{XDG_CACHE_HOME:-$HOME/.cache\}/p10k-instant-prompt-$\{(%):-%n\}.zsh" ]]; then
        source "$\{XDG_CACHE_HOME:-$HOME/.cache\}/p10k-instant-prompt-$\{(%):-%n\}.zsh"
      fi
    '';
    initExtraBeforeCompInit = ''
      # Disable some options for dumb terminals.
      if [[ $TERM == dumb ]]; then
        unsetopt ZLE
        unsetopt PROMPT_CR
        unsetopt PROMPT_SUBST
      fi

      # Load modules.
      zmodload zsh/complist
    '';
    initExtra = ''
      # Changing Directories
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT
      setopt PUSHD_TO_HOME

      # Completion
      setopt AUTO_LIST
      setopt AUTO_MENU
      setopt AUTO_PARAM_KEYS
      setopt COMPLETE_ALIASES
      setopt COMPLETE_IN_WORD

      # Expansion and Globbing
      setopt NO_EXTENDED_GLOB

      # Input/Output
      setopt IGNORE_EOF
      setopt INTERACTIVE_COMMENTS

      # Completion System Configuration
      zstyle ':completion:*:complete:*' use-cache yes
      zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}-- %d (errors: %e) --%f'
      zstyle ':completion:*:*:*:*:default' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
      zstyle ':completion:*:*:*:*:functions' ignored-patterns '_*'
      zstyle ':completion:*:*:*:*:messages' format '%F{magenta} -- %d --%f'
      zstyle ':completion:*:*:*:*:warnings' format '%F{red}-- no matches found --%f'
      zstyle ':completion:*' completer _extensions _complete _list _match _approximate
      zstyle ':completion:*' group-name '''
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*' menu select
      zstyle ':completion:*' squeeze-slashes true
      zstyle ':completion:*' verbose yes

      bindkey -M menuselect 'h' vi-backward-char
      bindkey -M menuselect 'k' vi-up-line-or-history
      bindkey -M menuselect 'l' vi-forward-char
      bindkey -M menuselect 'j' vi-down-line-or-history
      bindkey -M menuselect '^P' vi-up-line-or-history
      bindkey -M menuselect '^N' vi-down-line-or-history

      bindkey '^[OA' history-substring-search-up
      bindkey '^[OB' history-substring-search-down
      bindkey '^P' history-substring-search-up
      bindkey '^N' history-substring-search-down

      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word

      fancy_ctrl_z() {
        if [[ ''${#BUFFER} -eq 0 ]]; then
          BUFFER="fg"
          zle accept-line -w
        else
          zle push-input -w
          zle clear-screen -w
        fi
      }
      zle -N fancy_ctrl_z
      bindkey '^Z' fancy_ctrl_z

      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      hash bunnyfetch 2>/dev/null && bunnyfetch
    '';
  };
  home.file.".p10k.zsh".source = ./.p10k.zsh;

  programs.dircolors.enable = true;
  programs.dircolors.enableZshIntegration = true;

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;

  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;

  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;

  programs.bat = {
    enable = true;
    config.theme = "ansi";
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "greyscale";
      theme_background = true;
      truecolor = true;
      vim_keys = true;
      update_ms = 1000;
      background_update = false;
    };
  };

  programs.git = {
    enable = true;
    aliases = {
      co = "commit";
      ch = "checkout";
      fa = "fetch --all";
      lg = "log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      st = "status -s";
      di = "diff";
      ds = "diff --staged";
    };
    delta = {
      enable = true;
      options.diff-highlight = true;
    };
    extraConfig.core.whitespace = "trailing-space,space-before-tab";
    userEmail = "hi@interrato.dev";
    userName = "Simone Ragusa";
  };

  programs.rofi = {
    enable = true;
    font = "monospace 12";
    location = "bottom";
    terminal = "alacritty";
    theme = "slim";
    plugins = [ pkgs.rofi-calc ];
    extraConfig = {
      modi = "drun,run";
      matching = "fuzzy";
      show-icons = false;
      display-drun = "";
      display-run = "";
      display-calc = "󰃬";
      drun-display-format = "{name}";
      kb-select-1 = "";
      kb-select-2 = "";
      kb-select-3 = "";
      kb-select-4 = "";
      kb-select-5 = "";
      kb-select-6 = "";
      kb-select-7 = "";
      kb-select-8 = "";
      kb-select-9 = "";
      kb-select-10 = "";
    };
  };
  xdg.configFile."rofi/themes/slim.rasi".text = (import ./rofi-theme.nix) { };

  programs = {
    feh.enable = true;
    jq.enable = true;
    mpv.enable = true;
    ripgrep.enable = true;
    zathura.enable = true;
  };

  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      alsaSupport = false;
      pulseSupport = true;
    };
    script = ''
      #!/usr/bin/env bash
      polybar-msg cmd quit
      sleep 1s # wait for bspwm
      polybar 2>&1 | /run/current-system/sw/bin/tee -a /tmp/polybar.log & disown
    '';
    settings = {
      "colors" = {
        background = "#0f0f0f"; # dim black
        background-alt = "#181818"; # black
        foreground = "#d8d8d8"; # white
        primary = "#f4bf75"; # yellow
        secondary = "#75b5aa"; #cyan
        alert = "#ac4242"; # red
        disabled = "#6b6b6b"; # bright black
      };
      "bar/bar" = {
        bottom = true;

        width = "100%";
        height = "20pt";

        background = "\${colors.background}";
        foreground = "\${colors.foreground}";

        padding.left = 0;
        padding.right = 1;

        module.margin = 1;

        font = [ "monospace;2" ];

        modules.left = "bspwm xwindow";
        modules.right = "filesystem battery xkeyboard memory cpu wlan eth pulseaudio date";

        separator.text = "|";
        separator.foreground = "\${colors.disabled}";

        wm.restack = "bspwm";

        enable.ipc = true;

        cursor.click = "pointer";
        cursor.scroll = "ns-resize";
      };
      "module/bspwm" = {
        type = "internal/bspwm";

        label.focused.text = "%name%";
        label.focused.background = "\${colors.background-alt}";
        label.focused.underline = "\${colors.primary}";
        label.focused.padding = 1;

        label.occupied.text = "%name%";
        label.occupied.padding = 1;

        label.urgent.text = "%name%";
        label.urgent.background = "\${colors.alert}";
        label.urgent.padding = 1;

        label.empty = "";
      };
      "module/xwindow".type = "internal/xwindow";
      "module/filesystem" = {
        type = "internal/fs";
        interval = 20;

        mount = [ "/" ];

        label.mounted = "%{F#f4bf75}%mountpoint%%{F-} %percentage_used%%";

        label.unmounted.text = "%mountpoint% not mounted";
        label.unmounted.foreground = "\${colors.disabled}";
      };
      "module/battery" = {
        type = "internal/battery";
        poll.interval = 20;

        format.charging.prefix.text = "BAT ";
        format.charging.prefix.foreground = "\${colors.primary}";
        format.charging.text = "<label-charging>";

        format.discharging.prefix.text = "BAT ";
        format.discharging.prefix.foreground = "\${colors.primary}";
        format.discharging.text = "<label-discharging>";

        format.full.prefix.text = "BAT ";
        format.full.prefix.foreground = "\${colors.primary}";
        format.full.text = "<label-full>";

        format.low.prefix.text = "BAT ";
        format.low.prefix.foreground = "\${colors.primary}";
        format.low.text = "<label-low>";

        label.charging = "%{F#75b5aa}%percentage%%";
        label.discharging = "%percentage%%";
        label.full = "FULL";
        label.low = "%{F#ac4242}%percentage%%";
      };
      "module/xkeyboard" = {
        type = "internal/xkeyboard";

        label.layout.text = "%layout%";
        label.layout.foreground = "\${colors.primary}";

        label.indicator.padding = 2;
        label.indicator.margin = 1;
        label.indicator.foreground = "\${colors.background}";
        label.indicator.background = "\${colors.secondary}";
      };
      "module/memory" = {
        type = "internal/memory";
        interval = 2;
        format.prefix.text = "RAM ";
        format.prefix.foreground = "\${colors.primary}";
        label= "%percentage_used:2%%";
      };
      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        format.prefix.text = "CPU ";
        format.prefix.foreground = "\${colors.primary}";
        label= "%percentage:2%%";
      };
      "network-base" = {
        type = "internal/network";
        interval = 2;
        format.connected = "<label-connected>";
        format.disconnected = "<label-disconnected>";
        label.disconnected = "%{F#f4bf75}%ifname%%{F#6b6b6b} disconnected";
      };
      "module/wlan" = {
        "inherit" = "network-base";
        interface.type = "wireless";
        label.connected = "%{F#f4bf75}%ifname%%{F-} %essid% %local_ip% (%downspeed%)";
      };
      "module/eth" = {
        "inherit" = "network-base";
        interface.type = "wired";
        label.connected = "%{F#f4bf75}%ifname%%{F-} %local_ip% (%downspeed%)";
      };
      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        click.right = "pavucontrol";

        format.volume.prefix.text = "VOL ";
        format.volume.prefix.foreground = "\${colors.primary}";
        format.volume.text = "<label-volume>";

        label.volume = "%percentage%%";

        label.muted.text = "muted";
        label.muted.foreground = "\${colors.disabled}";
      };
      "module/date" = {
        type = "internal/date";
        interval = 5;

        date = "%Y-%m-%d";
        time = "%H:%M:%S";

        label.text = "%date% %time%";
        label.foreground = "\${colors.primary}";
      };
      "global/wm" = {
        margin-bottom = 0;
        margin-top = 0;
      };
      "settings".screenchange-reload = true;
    };
  };

  # Adjust the screen color temperature based on the time of day.
  services.redshift = {
    enable = true;
    enableVerboseLogging = true;
    provider = "geoclue2";
    temperature.day = 6500;
    temperature.night = 4500;
  };

  # Cool lock screen service.
  services.betterlockscreen.enable = true;
  services.betterlockscreen.arguments = [ "dim" ];

  # Notification daemon.
  services.dunst.enable = true;

  # Screenshot capturing utility.
  services.flameshot.enable = true;

  # Music player daemon with MPRIS protocol support.
  services.mpd.enable = true;
  services.mpd-mpris.enable = true;

  # We want to be able to control media players via Bluetooth.
  services.mpris-proxy.enable = true;

  # Lightweight compositor for X11.
  services.picom.enable = true;

  # CLI utility to control MPRIS compliant media players.
  services.playerctld.enable = true;

  # We use continuous file synchronization between local devices
  # for Logseq notes.
  services.syncthing.enable = true;

  # Hide the cursor on inactivity.
  services.unclutter.enable = true;

  garden = {
    alacritty = {
      enable = true;
      # import = [ "/mnt/shared/theme.yml" ];
      # colors = {
      #   primary = {
      #     background = "#1E1E2E"; # base
      #     foreground = "#CDD6F4"; # text
      #     # Bright and dim foreground colors
      #     dim_foreground = "#CDD6F4"; # text
      #     bright_foreground = "#CDD6F4"; # text
      #   };
      #
      #   # Cursor colors
      #   cursor = {
      #     text = "#1E1E2E"; # base
      #     cursor = "#F5E0DC"; # rosewater
      #   };
      #   vi_mode_cursor = {
      #     text = "#1E1E2E"; # base
      #     cursor = "#B4BEFE"; # lavender
      #   };
      #
      #    # Search colors
      #    search = {
      #      matches = {
      #        foreground = "#1E1E2E"; # base
      #        background = "#A6ADC8"; # subtext0
      #      };
      #      focused_match = {
      #        foreground = "#1E1E2E"; # base
      #        background = "#A6E3A1"; # green
      #      };
      #      footer_bar = {
      #        foreground = "#1E1E2E"; # base
      #        background = "#A6ADC8"; # subtext0
      #      };
      #    };
      #
      #    # Keyboard regex hints
      #    hints = {
      #      start = {
      #        foreground = "#1E1E2E"; # base
      #        background = "#F9E2AF"; # yellow
      #      };
      #      end = {
      #        foreground = "#1E1E2E"; # base
      #        background = "#A6ADC8"; # subtext0
      #      };
      #    };
      #
      #   # Selection colors
      #   selection = {
      #     text = "#1E1E2E"; # base
      #     background = "#F5E0DC"; # rosewater
      #   };
      #
      #   # Normal colors
      #   normal = {
      #     black = "#45475A"; # surface1
      #     red = "#F38BA8"; # red
      #     green = "#A6E3A1"; # green
      #     yellow = "#F9E2AF"; # yellow
      #     blue = "#89B4FA"; # blue
      #     magenta = "#F5C2E7"; # pink
      #     cyan = "#94E2D5"; # teal
      #     white = "#BAC2DE"; # subtext1
      #   };
      #
      #   # Bright colors
      #   bright = {
      #     black = "#585B70"; # surface2
      #     red = "#F38BA8"; # red
      #     green = "#A6E3A1"; # green
      #     yellow = "#F9E2AF"; # yellow
      #     blue = "#89B4FA"; # blue
      #     magenta = "#F5C2E7"; # pink
      #     cyan = "#94E2D5"; # teal
      #     white = "#A6ADC8"; # subtext0
      #   };
      #
      #   # Dim colors
      #   dim = {
      #     black = "#45475A"; # surface1
      #     red = "#F38BA8"; # red
      #     green = "#A6E3A1"; # green
      #     yellow = "#F9E2AF"; # yellow
      #     blue = "#89B4FA"; # blue
      #     magenta = "#F5C2E7"; # pink
      #     cyan = "#94E2D5"; # teal
      #     white = "#BAC2DE"; # subtext1
      #   };
      #
      #   indexed_colors = [
      #     { index = 16; color = "#FAB387"; }
      #     { index = 17; color = "#F5E0DC"; }
      #   ];
      # };
      extraHints = [
        {
          regex = "(([0-9A-Za-z._\/]|[^\x00-\x7f]){1}[^ :\n]*):([0-9]+)(:([0-9]+))?";
          command = "${config.home.homeDirectory}/Scripts/hints/open_in_vim";
          binding = { key = "L"; mods = "Control|Shift"; };
        }
      ];
    };

    bspwm = {
      enable = true;
      extraSettings = {
        window_gap = 0;
      };
      rules = {
        "Alacritty" = {
          desktop = "2";
          follow = true;
        };
      };
      startupPrograms = [
        "feh --no-fehbg --bg-fill ${config.xdg.userDirs.pictures}/wallpaper.png"
      ];
      extraKeybindings = {
        "super + @space" = "rofi -show drun -disable-history -sort -sorting-method fzf";
        "super + {_,shift + }n" = "polybar-msg cmd {hide && bspc config bottom_padding 0,show}";
        "super + q" = "rofi -show calc -modi calc -no-show-match -no-sort";
        "super + x" = "betterlockscreen --lock dim";
        "Print" = "flameshot gui";
      };
    };

    firefox = {
      enable = true;
      supportTridactyl = true;
      containers = [
        { name = "Twitter"; icon = "fence"; color = "blue"; }
        { name = "Personal"; icon = "fingerprint"; color = "turquoise"; }
        { name = "Anything"; icon = "tree"; color = "green"; }
        { name = "Google"; icon = "pet"; color = "yellow"; }
        { name = "Engineering"; icon = "vacation"; color = "orange"; }
        { name = "University"; icon = "fruit"; color = "red"; }
        { name = "Shopping"; icon = "cart"; color = "pink"; }
        { name = "Twitch"; icon = "chill"; color = "purple"; }
        # { name = "Work"; icon = "briefcase"; color = "toolbar"; } # NOTE: Not used for now.
      ];
      allowCookies = [
        # Amazon
        "https://www.amazon.it/"

        # Fastmail
        "https://app.fastmail.com/"

        # GitHub
        "https://github.com/"

        # Google
        "https://accounts.google.com/"
        "https://mail.google.com/"
        "https://translate.google.com/"
        "https://www.google.com/"
        "https://www.youtube.com/"

        # Proton
        "https://account.proton.me/"
        "https://calendar.proton.me/"
        "https://mail.proton.me/"

        # Standard Notes
        "https://app.standardnotes.com/"

        # Twitch
        "https://www.twitch.tv/"

        # Twitter
        "https://twitter.com/"

        # UNIPD
        "https://shibidp.cca.unipd.it/"
        "https://uniweb.unipd.it/"

        # WhatsApp
        "https://web.whatsapp.com/"
      ];
      bookmarks = [
        {
          name = "Bookmarks Toolbar"; toolbar = true;
          bookmarks = [
            { name = "Calendar"; url = "https://calendar.proton.me/"; }
            { name = "DeepL"; url = "https://deepl.com/"; }
            { name = "Fastmail"; url = "https://app.fastmail.com/"; }
            { name = "GitHub"; url = "https://github.com/"; }
            { name = "Gmail"; url = "https://mail.google.com/"; }
            { name = "Man Pages"; url = "https://www.mankier.com/"; }
            { name = "Netflix"; url = "https://www.netflix.com/"; }
            { name = "NixOS"; url = "https://nixos.org/"; }
            { name = "NUR"; url = "https://nur.nix-community.org/"; }
            { name = "Translate"; url = "https://translate.google.com/"; }
            { name = "Twitch"; url = "https://www.twitch.com/"; }
            { name = "Twitter"; url = "https://twitter.com/"; }
            { name = "Uniweb"; url = "https://uniweb.unipd.it/"; }
            { name = "WhatsApp"; url = "https://web.whatsapp.com/"; }
            { name = "YouTube"; url = "https://www.youtube.com/"; }
          ];
        }
        {
          name = "Colors";
          bookmarks = [
            { name = "Color Designer"; url = "https://colordesigner.io/"; }
            { name = "Coolors"; url = "https://coolors.co/"; }
            { name = "Interactive color picker comparison (Oklch, Okhsv, Okhsl, Hsluv)"; url = "https://bottosson.github.io/misc/colorpicker/"; }
            { name = "RAL Farben"; url = "https://www.ral-farben.de/"; }
          ];
        }
        {
          name = "Cryptography and Mathematics";
          bookmarks = [
            { name = "A Computational Introduction to Number Theory and Algebra"; url = "https://shoup.net/ntb/"; }
            { name = "A Graduate Course in Applied Cryptography"; url = "https://toc.cryptobook.us/"; }
            { name = "Ben Lynn Notes"; url = "https://crypto.stanford.edu/pbc/notes/"; }
            { name = "The Cryptopals Crypto Challenges"; url = "https://cryptopals.com/"; }
            { name = "The Joy of Cryptography"; url = "https://joyofcryptography.com/"; }
          ];
        }
        {
          name = "Go";
          bookmarks = [
            { name = "Effective Go"; url = "https://go.dev/doc/effective_go"; }
            { name = "Go Packages"; url = "https://pkg.go.dev/"; }
            { name = "Go Playground"; url = "https://go.dev/play/"; }
            { name = "The Go Programming Language"; url = "https://go.dev/"; }
            { name = "The Go Programming Language Specification"; url = "https://go.dev/ref/spec"; }
          ];
        }
        {
          name = "Nix";
          bookmarks = [
            { name = "Home Manager Configuration Options"; url = "https://nix-community.github.io/home-manager/options.html"; }
            { name = "Nix Package Versions"; url = "https://lazamar.co.uk/nix-versions/"; }
            { name = "nix-community/home-manager"; url = "https://github.com/nix-community/home-manager"; }
            { name = "NixOS Wiki"; url = "https://nixos.wiki/wiki/Main_Page"; }
            { name = "NixOS/nixos-hardware"; url = "https://github.com/NixOS/nixos-hardware"; }
            { name = "NixOS/nixpkgs"; url = "https://github.com/NixOS/nixpkgs"; }
            { name = "Nixpkgs PR progress tracker"; url = "https://nixpk.gs/pr-tracker.html"; }
            { name = "noogle"; url = "https://noogle.dev/"; }
            { name = "Zero to Nix"; url = "https://zero-to-nix.com/"; }
          ];
        }
        {
          name = "One Piece";
          bookmarks = [
            { name = "One Piece Power"; url = "https://onepiecepower.com/index"; }
            { name = "One Piece Filler List"; url = "https://www.animefillerlist.com/shows/one-piece"; }
            { name = "Watch order for Movies, Specials, Cover Stories"; url = "https://www.reddit.com/r/OnePiece/comments/tr0izv/watch_order_for_movies_specials_cover_stories_etc/"; }
          ];
        }
        {
          name = "Typography";
          bookmarks = [
            { name = "Berkeley Graphics"; url = "https://berkeleygraphics.com/"; }
            { name = "Fontsource"; url = "https://fontsource.org/"; }
            { name = "Google Fonts"; url = "https://fonts.google.com/"; }
            { name = "google webfonts helper"; url = "https://gwfh.mranftl.com/fonts"; }
          ];
        }
        {
          name = "Web Development";
          bookmarks = [
            { name = "Can I use..."; url = "https://caniuse.com/"; }
            { name = "Fly"; url = "https://fly.io/"; }
            { name = "htmx"; url = "https://htmx.org/"; }
            { name = "Iconoir"; url = "https://iconoir.com/"; }
            { name = "Jeffsum"; url = "https://jeffsum.com/"; }
            { name = "Lorem Ipsum"; url = "https://loremipsum.io/"; }
            { name = "Namecheap"; url = "https://www.namecheap.com/"; }
            { name = "Omatsuri"; url = "https://omatsuri.app/"; }
            { name = "PageSpeed Insights"; url = "https://pagespeed.web.dev/"; }
            { name = "Place ID Finder | Maps JavaScript API"; url = "https://developers.google.com/maps/documentation/javascript/examples/places-placeid-finder"; }
            { name = "Svelte"; url = "https://svelte.dev/"; }
            { name = "Tailwind CSS"; url = "https://tailwindcss.com/"; }
          ];
        }
        {
          name = "Miscellaneous";
          bookmarks = [
            { name = "Amazon.it"; url = "https://www.amazon.it/"; }
            { name = "C data types - Wikipedia"; url = "https://en.wikipedia.org/wiki/C_data_types"; }
            { name = "Coursera"; url = "https://www.coursera.org/"; }
            { name = "decodeunicode"; url = "https://decodeunicode.org/"; }
            { name = "Devhints"; url = "https://devhints.io/"; }
            { name = "Excalidraw"; url = "https://excalidraw.com/"; }
            { name = "fstab - Wikipedia"; url = "https://en.wikipedia.org/wiki/Fstab"; }
            { name = "GitLab"; url = "https://gitlab.com/"; }
            { name = "Google Style Guides"; url = "https://google.github.io/styleguide/"; }
            { name = "How Many Days Has It Been Since a JWT alg:none Vulnerability?"; url = "https://www.howmanydayssinceajwtalgnonevuln.com/"; }
            { name = "Internet protocol suite - Wikipedia"; url = "https://en.wikipedia.org/wiki/Internet_protocol_suite"; }
            { name = "JSON Web Tokens"; url = "https://jwt.io/"; }
            { name = "LaTeX - Wikibooks"; url = "https://en.wikibooks.org/wiki/LaTeX"; }
            { name = "Manx"; url = "https://vt100.net/manx/"; }
            { name = "MathJax basic tutorial and quick reference"; url = "https://math.meta.stackexchange.com/questions/5020/mathjax-basic-tutorial-and-quick-reference"; }
            { name = "Policy Templates for Firefox"; url = "https://mozilla.github.io/policy-templates/"; }
            { name = "SequenceDiagram.org"; url = "https://sequencediagram.org/"; }
            { name = "Simone Ragusa"; url = "https://interrato.dev/"; }
            { name = "Standard Notes"; url = "https://app.standardnotes.com/"; }
            { name = "SVG Viewer"; url = "https://www.svgviewer.dev/"; }
            { name = "Usage message - Wikipedia"; url = "https://en.wikipedia.org/wiki/Usage_message"; }
            { name = "Wolfram|Alpha"; url = "https://www.wolframalpha.com/"; }
          ];
        }
      ];
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        canvasblocker
        darkreader
        duckduckgo-privacy-essentials
        multi-account-containers
        skip-redirect
        smart-referer
        ublock-origin
      ];
      homepage = "data:,";
      preferredSearchEngine = "DuckDuckGo";
      tridactyl.enable = true;
      tridactyl.extraConfig = ''
        " Clears all existing settings: if a setting in this file is
        " removed, it will revert to the default.
        sanitise tridactyllocal tridactylsync

        " Re-enable the browser's native 'Find in page' functionality.
        unbind <C-f>

        " Enable Tridactyl find mode bindings.
        bind / fillcmdline find
        bind ? fillcmdline find --reverse
        bind n findnext --search-from-view
        bind N findnext --search-from-view --reverse
        bind gn findselect
        bind gN composite findnext --search-from-view --reverse; findselect
        bind ,<Space> nohlsearch

        " Do not run Tridactyl on some web sites.
        autocmd DocStart app.standardnotes.com mode ignore
        autocmd DocStart mail.google.com mode ignore
        autocmd DocStart www.netflix.com mode ignore

        set completionfuzziness 0.2
        set hintfiltermode vimperator-reflow
        set hintnames numeric
        set modeindicatorshowkeys true
        set newtab data:,
        set smoothscroll true
      '';
    };
  };

  home.file."Scripts" = {
    source = ./scripts;
    recursive = true;
  };

  home.file."Pictures/wallpaper.png".source = ./gsgfez0h0p481.png;

  xdg.configFile."cava/config".text = ''
    [output]
    method = ncurses
    alacritty_sync = 1

    [color]
    gradient = 1
    gradient_count = 8
    gradient_color_1 = '#59cc33'
    gradient_color_2 = '#80cc33'
    gradient_color_3 = '#a6cc33'
    gradient_color_4 = '#cccc33'
    gradient_color_5 = '#cca633'
    gradient_color_6 = '#cc8033'
    gradient_color_7 = '#cc5933'
    gradient_color_8 = '#cc3333'

    [smoothing]
    noise_reduction = 66

    [eq]
    1 = 3
    2 = 6
    3 = 9
    4 = 7
    5 = 6
    6 = 5
    7 = 7
    8 = 9
    9 = 11
    10 = 8
  '';

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";
}
