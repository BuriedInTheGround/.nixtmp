{ config, lib, pkgs, inputs, currentUser, ... }:

let
  theme = "dark";

  perpetua = builtins.mapAttrs (_: color: color.hex) lib.perpetua.${theme};
in {
  imports = [
    ../../modules/hm
  ];

  home.username = "${currentUser}";
  home.homeDirectory = "/home/${currentUser}";

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.age # Encryption tool.
    pkgs.anki-bin # Spaced repetition flashcards.
    pkgs.bunnyfetch # Simple system info fetch utility.
    pkgs.chafa # Terminal graphics.
    pkgs.charm-freeze # Generate images of code and terminal output.
    pkgs.doggo # DNS client.
    pkgs.dust # Intuitive disk usage.
    pkgs.felix-fm # File manager.
    pkgs.ffmpeg # Multimedia processing framework.
    pkgs.gimp # Raster graphics editor.
    pkgs.glow # CLI markdown reader.
    pkgs.hyperfine # Benchmarking tool.
    pkgs.imagemagick # Raster images tools.
    pkgs.inkscape # Vector graphics editor.
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.mergiraf # Syntax-aware git merge driver.
    pkgs.minder # Mind-mapping tool.
    pkgs.mpc-cli # CLI for MPD.
    pkgs.okular # Document viewer.
    pkgs.onlyoffice-bin_latest # Office suite.
    pkgs.pavucontrol # PulseAudio volume control.
    pkgs.porsmo # Pomodoro.
    pkgs.progress # Coreutils progress viewer.
    pkgs.qalculate-gtk # Calculator.
    pkgs.ripgrep-all # Search with ripgrep in pdf, docx, sqlite, and more.
    pkgs.simplescreenrecorder # Screen recorder.
    pkgs.systemctl-tui # Interact with systemd services.
    pkgs.tree # Tree view of directories.
    pkgs.tz # Time zone helper.
    pkgs.xcolor # Color picker.
    (pkgs.parallel-full.override { # Execute jobs in parallel.
      willCite = true;
    })

    # Neovim nightly.
    inputs.neovim-nightly-overlay.packages.${pkgs.system}.default

    # Language servers.
    pkgs.asm-lsp
    pkgs.nodePackages.bash-language-server
    pkgs.clang-tools
    pkgs.lua-language-server
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.ltex-ls-plus
    pkgs.marksman
    pkgs.nil
    pkgs.tailwindcss-language-server
    pkgs.typescript-language-server
    pkgs.vscode-langservers-extracted
    pkgs.yaml-language-server

    # Formatters.
    pkgs.nixfmt-rfc-style
    pkgs.stylua
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/Scripts" # See near the bottom.
  ];

  home.sessionVariables = {
    BAT_THEME = "ansi";
    DIRENV_LOG_FORMAT = ""; # Make direnv quiet.
    EDITOR = "nvim";
    GTK_THEME = (if theme == "dark" then "adw-gtk3-dark" else "adw-gtk3");
    MANWIDTH = 100;
    NIXOS_THEME = theme; # Expose the current system theme for manual use.
    PAGER = "less --tabs 4 --mouse --wheel-lines 4 -RFX";
    TZ_LIST = "US/Eastern;US/Central;US/Mountain;US/Pacific;Asia/Shanghai;Asia/Tokyo;Australia/Sydney";
    WORDCHARS = "*[]~;!$%^(){}<>";
    XCOMPOSECACHE = "${config.xdg.cacheHome}/X11/xcompose"; # Declutter home.
    ZVM_CURSOR_STYLE_ENABLED = "false"; # Disable zsh-vi-mode cursor style.
  };

  home.shellAliases = {
    ".."      = "cd ..";
    "..."     = "cd ../..";
    "...."    = "cd ../../..";
    "q"       = "exit";
    "Q"       = "exit";
    "clr"     = "clear";
    "sudo"    = "sudo "; # Make sudo work with aliases.
    "cp"      = "cp --interactive";
    "mv"      = "mv --interactive";
    "t"       = "tree";
    "md"      = "mkdir --parents --verbose";
    "rr"      = "rm --recursive";
    "cat"     = "bat --plain";
    "man"     = "LESSOPEN=\"|- olivetti '%s'\" man";
    "pbcopy"  = "xclip -selection clipboard";
    "pbpaste" = "xclip -selection clipboard -o";
    "gti"     = "printf '\\x1b[1;33mI absolutely know that you meant to type \\x1b[1;35m\"git\"\\x1b[1;33m.\\x1b[0m\\n\\n';git ";
    "vim"     = "nvim";
    "dust"    = "dust --reverse --no-colors --bars-on-right";
    "ff"      = "fastfetch";
    "nap"     = "systemctl suspend";
  };

  # Enable management of XDG directories.
  xdg.enable = true;
  xdg.userDirs.enable = true;

  # Add some missing desktop entries.
  xdg.desktopEntries = {
    felix = {
      exec = "fx %f";
      genericName = "File Manager";
      name = "felix";
    };
  };

  # Set some default applications.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Browser
      "application/rdf+xml" = "chromium-browser.desktop";
      "application/rss+xml" = "chromium-browser.desktop";
      "application/xhtml+xml" = "chromium-browser.desktop";
      "application/xhtml_xml" = "chromium-browser.desktop";
      "application/xml" = "chromium-browser.desktop";
      "text/html" = "chromium-browser.desktop";
      "text/xml" = "chromium-browser.desktop";
      "x-scheme-handler/about" = "chromium-browser.desktop";
      "x-scheme-handler/chrome" = "chromium-browser.desktop";
      "x-scheme-handler/ftp" = "chromium-browser.desktop";
      "x-scheme-handler/http" = "chromium-browser.desktop";
      "x-scheme-handler/https" = "chromium-browser.desktop";
      "x-scheme-handler/mailto" = "chromium-browser.desktop";
      "x-scheme-handler/unknown" = "chromium-browser.desktop";
      "x-scheme-handler/webcal" = "chromium-browser.desktop";

      # File manager
      "inode/directory" = "felix.desktop";

      # Image viewer
      "image/bmp" = "feh.desktop";
      "image/gif" = "feh.desktop";
      "image/heic" = "feh.desktop";
      "image/jpeg" = "feh.desktop";
      "image/jpg" = "feh.desktop";
      "image/pjpeg" = "feh.desktop";
      "image/png" = "feh.desktop";
      "image/tiff" = "feh.desktop";
      "image/webp" = "feh.desktop";
      "image/x-bmp" = "feh.desktop";
      "image/x-pcx" = "feh.desktop";
      "image/x-png" = "feh.desktop";
      "image/x-portable-anymap" = "feh.desktop";
      "image/x-portable-bitmap" = "feh.desktop";
      "image/x-portable-graymap" = "feh.desktop";
      "image/x-portable-pixmap" = "feh.desktop";
      "image/x-tga" = "feh.desktop";
      "image/x-xbitmap" = "feh.desktop";

      # PDF viewer
      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
    };
  };

  # Enable XDG desktop integration.
  xdg.portal = {
    enable = true;
    config = {
      common.default = [ "gtk" ];
    };
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Apply the theme to GTK apps.
  gtk = {
    enable = true;
    theme = {
      name = (if theme == "dark" then "adw-gtk3-dark" else "adw-gtk3");
      package = pkgs.adw-gtk3;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    gtk3.extraConfig.gtk-application-prefer-dark-theme = (if theme == "dark" then 1 else 0);
    gtk4.extraConfig.gtk-application-prefer-dark-theme = (if theme == "dark" then 1 else 0);
  };
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-${theme}";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = false; # Disabled. Handled by zsh-autocomplete.
    enableVteIntegration = true; # Let the terminal track the current working directory.
    antidote = {
      enable = true;
      plugins = [
        "romkatv/powerlevel10k" # Prompt theme.
        "MichaelAquilina/zsh-you-should-use" # Reminders for existing aliases.
        "jeffreytse/zsh-vi-mode" # Better vim mode.
        "zsh-users/zsh-completions" # Additional completion definitions.
        "marlonrichert/zsh-autocomplete" # Real-time autocompletion.
        "zsh-users/zsh-autosuggestions" # Fish-like autosuggestions.
        "zsh-users/zsh-syntax-highlighting" # Fish-like syntax highlighting.
      ];
      useFriendlyNames = true;
    };
    dotDir = ".config/zsh";
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreAllDups = true;
      ignoreDups = true;
      ignorePatterns = [ "rm *" "rr *" "pkill *" "killall *" ];
      ignoreSpace = true;
      path = "${config.xdg.stateHome}/zsh/history";
      share = true;
    };
    initExtraFirst = ''
      hash bunnyfetch 2>/dev/null && ANSI_COLOR=32 bunnyfetch

      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';
    initExtraBeforeCompInit = ''
      # Disable some options for dumb terminals.
      if [[ $TERM == dumb ]]; then
        unsetopt ZLE
        unsetopt PROMPT_CR
        unsetopt PROMPT_SUBST
      fi

      # Set up dynamic title for terminal emulator.
      autoload -Uz add-zsh-hook
      function xterm_title_precmd() {
        builtin print -n -- "\e]2;''${(%):-%(4~|…/%3~|%~)}\a"
      }
      function xterm_title_preexec() {
        builtin print -n -- "\e]2;''${(q)1}\a"
      }
      if [[ "$TERM" == (alacritty*|ansi|*color*|*direct*|linux|tmux*|vt100|xterm*) ]]; then
        add-zsh-hook -Uz precmd xterm_title_precmd
        add-zsh-hook -Uz preexec xterm_title_preexec
      fi

      # Load modules.
      zmodload zsh/complist
    '';
    initExtra = ''
      # Changing Directories.
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT
      setopt PUSHD_TO_HOME

      # Expansion and Globbing.
      setopt CASE_PATHS
      setopt NUMERIC_GLOB_SORT
      setopt RC_EXPAND_PARAM

      # Input/Output.
      setopt IGNORE_EOF
      setopt INTERACTIVE_COMMENTS

      # Treat sequences of slashes in paths as a single slash.
      zstyle ':completion:*' squeeze-slashes yes

      # CLI: Tab and Shift+Tab go to the menu.
      bindkey   "$terminfo[ht]" menu-select
      bindkey "$terminfo[kcbt]" menu-select

      # Menu: Tab and Shift+Tab change the selection in the menu.
      bindkey -M menuselect   "$terminfo[ht]"         menu-complete
      bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete

      # CLI: Ctrl+{Left,Right} Arrow move cursor to {previous,next} word.
      bindkey "$terminfo[kLFT5]" backward-word
      bindkey "$terminfo[kRIT5]" forward-word

      function fancy_ctrl_z() {
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

      function ow() {
        local cols=$(tput cols || echo $\{COLUMNS:-80\})
        if [[ $cols -gt 100 ]]; then
          cat $@ | olivetti | eval "$PAGER"
        else
          cat $@ | eval "$PAGER"
        fi
      }

      source <(command fx --init)

      [[ ! -f "$ZDOTDIR/.p10k.zsh" ]] || source "$ZDOTDIR/.p10k.zsh"
    '';
  };
  xdg.configFile."zsh/.p10k.zsh".source = ./p10k.zsh;

  programs.dircolors.enable = true;
  programs.dircolors.enableZshIntegration = true;

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;

  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;

  programs.zoxide.enable = true;
  programs.zoxide.enableZshIntegration = true;

  # Powerful CLI download utility.
  programs.aria2 = {
    enable = true;
    settings = {
      save-session = "${config.home.homeDirectory}/aria2-session.gz";
      save-session-interval = 30;
    };
  };

  # A cat(1) clone with syntax highlighting.
  programs.bat = {
    enable = true;
    config.theme = "ansi";
  };

  # A monitor of resources.
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "TTY";
      theme_background = false;
      truecolor = true;
      vim_keys = true;
      background_update = false;
    };
  };

  # Audio visualizer.
  programs.cava = {
    enable = true;
    settings = {
      output.synchronized_sync = 1;
      color = {
        gradient = 1;
        gradient_color_1 = "'${perpetua.turquoise}'";
        gradient_color_2 = "'${perpetua.green}'";
        gradient_color_3 = "'${perpetua.lime}'";
        gradient_color_4 = "'${perpetua.yellow}'";
        gradient_color_5 = "'${perpetua.orange}'";
        gradient_color_6 = "'${perpetua.red}'";
        gradient_color_7 = "'${perpetua.pink}'";
        gradient_color_8 = "'${perpetua.lavender}'";
      };
      smoothing.noise_reduction = 66;
      eq = {
        "1" = 3;
        "2" = 6;
        "3" = 9;
        "4" = 7;
        "5" = 6;
        "6" = 5;
        "7" = 7;
        "8" = 9;
        "9" = 11;
        "10" = 8;
      };
    };
  };

  # Highly customizable system info fetch utility.
  programs.fastfetch = {
    enable = true;
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.fastfetch;
    # Adapted from https://github.com/usgraphics/TR-100.
    settings = {
      logo = null;
      display = {
        pipe = true;
        key.width = 16;
        separator = "│ ";
        percent.type = 3;
        bar = {
          charElapsed = "█";
          charTotal = "░";
          borderLeft = "";
          borderRight = "";
          width = 30;
        };
        constants = builtins.fromJSON ''[ "\u001b[32C" ]'';
      };
      modules = [
        {
          type = "custom";
          format = "┌┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┐";
        }
        {
          type = "custom";
          format = "├┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┤";
        }
        {
          type = "version";
          key = " ";
          format = "│              FASTFETCH v{version}              │";
        }
        {
          type = "custom";
          format = "│            TR-100 MACHINE REPORT            │";
        }
        {
          type = "custom";
          format = "├────────────┬────────────────────────────────┤";
        }
        {
          type = "os";
          key = "│ OS         │{$1}";
          format = "{pretty-name}";
        }
        {
          type = "kernel";
          key = "│ KERNEL     │{$1}";
        }
        {
          type = "custom";
          format = "├────────────┼────────────────────────────────┤";
        }
        {
          type = "title";
          key = "│ HOSTNAME   │{$1}";
          format = "{host-name}";
        }
        {
          type = "localip";
          key = "│ INTERFACE  │{$1}";
          format = "{ifname}";
        }
        {
          type = "localip";
          showMac = true;
          key = "│ MAC ADDR   │{$1}";
          format = "{mac}";
        }
        {
          type = "localip";
          showPrefixLen = false;
          key = "│ CLIENT  IP │{$1}";
          format = "{ipv4}";
        }
        {
          type = "dns";
          showType = "ipv4";
          key = "│ DNS     IP │{$1}";
        }
        {
          type = "title";
          key = "│ USER       │{$1}";
          format = "{user-name}";
        }
        {
          type = "custom";
          format = "├────────────┼────────────────────────────────┤";
        }
        {
          type = "chassis";
          key = "│ CHASSIS    │{$1}";
          format = "{type}";
        }
        {
          type = "cpu";
          key = "│ PROCESSOR  │{$1}";
          format = "{name}";
        }
        {
          type = "cpu";
          key = "│ CORES      │{$1}";
          format = "{cores-physical} Physical / {cores-logical} Threads";
        }
        {
          type = "cpu";
          key = "│ CPU FREQ   │{$1}";
          format = "{?freq-max}{freq-max}{?}{/freq-max}{freq-base}{/}";
        }
        {
          type = "loadavg";
          key = "│ LOAD  1m   │{$1}";
          format = "{loadavg1}";
        }
        {
          type = "loadavg";
          key = "│ LOAD  5m   │{$1}";
          format = "{loadavg2}";
        }
        {
          type = "loadavg";
          key = "│ LOAD 15m   │{$1}";
          format = "{loadavg3}";
        }
        {
          type = "custom";
          format = "├────────────┼────────────────────────────────┤";
        }
        {
          type = "memory";
          key = "│ MEMORY     │{$1}";
          format = "{used} / {total} [{percentage}]";
        }
        {
          type = "memory";
          key = "│ USAGE      │{$1}";
          format = "{percentage-bar}";
        }
        {
          type = "custom";
          format = "├────────────┼────────────────────────────────┤";
        }
        {
          type = "disk";
          folders = "/";
          key = "│ VOLUME     │{$1}";
          format = "{size-used} / {size-total} [{size-percentage}]";
        }
        {
          type = "disk";
          folders = "/";
          key = "│ DISK USAGE │{$1}";
          format = "{size-percentage-bar}";
        }
        {
          type = "custom";
          format = "├────────────┼────────────────────────────────┤";
        }
        {
          type = "command";
          text = "LOGIN_TIME=$(last -R -n 1 --time-format iso $USER | awk '/still logged in/{print $3}'); date -d $LOGIN_TIME '+%b %-d %Y %H:%M:%S'";
          key = "│ LAST LOGIN │{$1}";
        }
        {
          type = "command";
          text = "last -i -n 1 $USER | awk '/still logged in/{print $3}'";
          key = "│            │{$1}";
        }
        {
          type = "uptime";
          key = "│ UPTIME     │{$1}";
          format = "{?days}{days}d, {?}{?hours}{hours}h, {?}{?minutes}{minutes}m{?}{/minutes}{seconds}s{/}";
        }
        {
          type = "custom";
          format = "└────────────┴────────────────────────────────┘";
        }
      ];
    };
  };

  # Fast, feature-rich, and native terminal emulator.
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      font-family = "monospace";
      font-size = 14;
      theme = "dark:perpetua-dark,light:perpetua-light";
      mouse-hide-while-typing = true;
      background-opacity = 0.95;
      window-decoration = "server";
      window-theme = "ghostty";
      gtk-single-instance = true;
      keybind = [
        "ctrl+shift+e=equalize_splits"
        "ctrl+shift+o=unbind"
        # new window panes
        "ctrl+shift+k=new_split:up"
        "ctrl+shift+j=new_split:down"
        "ctrl+shift+l=new_split:right"
        "ctrl+shift+h=new_split:left"
        # moving between panes
        "ctrl+alt+h=goto_split:left"
        "ctrl+alt+j=goto_split:down"
        "ctrl+alt+k=goto_split:up"
        "ctrl+alt+l=goto_split:right"
      ];
    };
    themes = builtins.mapAttrs
      (_: palette: {
        background = palette.base0;
        foreground = palette.text0;
        selection-foreground = palette.text0;
        selection-background = palette.base4;
        palette = [
          "0=${palette.base2}"
          "1=${palette.red}"
          "2=${palette.green}"
          "3=${palette.yellow}"
          "4=${palette.blue}"
          "5=${palette.pink}"
          "6=${palette.cyan}"
          "7=${palette.text0}"
          "8=${palette.base3}"
          "9=${palette.red}"
          "10=${palette.green}"
          "11=${palette.yellow}"
          "12=${palette.blue}"
          "13=${palette.pink}"
          "14=${palette.cyan}"
          "15=${palette.text1}"
        ];
        cursor-color = palette.text0;
        cursor-text = palette.base0;
      })
      {
        perpetua-dark = builtins.mapAttrs (_: color: color.hex) lib.perpetua.dark;
        perpetua-light = builtins.mapAttrs (_: color: color.hex) lib.perpetua.light;
      };
  };

  # Distributed version control system.
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
    attributes = [
      "*java merge=mergiraf"
      "*kt merge=mergiraf"
      "*rs merge=mergiraf"
      "*go merge=mergiraf"
      "*js merge=mergiraf"
      "*jsx merge=mergiraf"
      "*mjs merge=mergiraf"
      "*json merge=mergiraf"
      "*yml merge=mergiraf"
      "*yaml merge=mergiraf"
      "*toml merge=mergiraf"
      "*html merge=mergiraf"
      "*htm merge=mergiraf"
      "*xhtml merge=mergiraf"
      "*xml merge=mergiraf"
      "*c merge=mergiraf"
      "*h merge=mergiraf"
      "*cc merge=mergiraf"
      "*cpp merge=mergiraf"
      "*hpp merge=mergiraf"
      "*cs merge=mergiraf"
      "*dart merge=mergiraf"
      "*dts merge=mergiraf"
      "*scala merge=mergiraf"
      "*sbt merge=mergiraf"
      "*ts merge=mergiraf"
      "*tsx merge=mergiraf"
      "*py merge=mergiraf"
      "*php merge=mergiraf"
      "*phtml merge=mergiraf"
      "*sol merge=mergiraf"
      "*lua merge=mergiraf"
      "*rb merge=mergiraf"
    ];
    delta = {
      enable = true;
      options = {
        diff-highlight = true;
        hyperlinks = true;
        navigate = true; # Use n and N to move between diff sections.
      };
    };
    extraConfig = {
      init.defaultBranch = "main";
      core.whitespace = "trailing-space,space-before-tab";
      merge = {
        "mergiraf" = {
          name = "mergiraf";
          driver = "mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
        };
      };
    };
    userEmail = "hi@interrato.dev";
    userName = "Simone Ragusa";
  };

  # Media player.
  programs.mpv = {
    enable = true;
    profiles = {
      "1080".ytdl-format = "bestvideo[height<=?1080]+bestaudio/best";
      "1440".ytdl-format = "bestvideo[height<=?1440]+bestaudio/best";
    };
    scripts = with pkgs.mpvScripts; [
      mpris
      mpv-cheatsheet
      thumbfast
      uosc
    ];
  };

  # Application launcher.
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
  xdg.configFile."rofi/themes/slim.rasi".text = (import ./rofi-theme.nix) {
    background = perpetua.base0;
    background-alt = perpetua.base2;
    foreground = perpetua.text0;
    selected = perpetua.yellow;
    active = perpetua.cyan;
    urgent = perpetua.red;
  };

  # PDF viewer.
  programs.zathura = {
    enable = true;
    options = {
      default-fg = perpetua.text0;
      default-bg = perpetua.base0;
      database = "sqlite";
      selection-clipboard = "clipboard";
    };
  };

  programs = {
    fd.enable = true; # Fast alternative to find.
    feh.enable = true; # Light-weight image viewer.
    jq.enable = true; # JSON processor.
    ripgrep.enable = true; # Recursive search in directories.
    yt-dlp.enable = true; # CLI audio/video downloader.
  };

  # Cool lock screen service.
  services.betterlockscreen = {
    enable = true;
    arguments = [ "dimblur" ];
    inactiveInterval = 5; # In minutes.
  };

  # Lightweight compositor for X11.
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
  };

  # Highly customizable status bar.
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      alsaSupport = false;
      pulseSupport = true;
    };
    script = ''
      #!/usr/bin/env bash
      polybar-msg cmd quit
      polybar bar 2>&1 | ${pkgs.coreutils}/bin/tee -a /tmp/polybar.log & disown
    '';
    settings = {
      "colors" = {
        background = perpetua.base0;
        background-alt = perpetua.base2;
        foreground = perpetua.text0;
        primary = perpetua.yellow;
        secondary = perpetua.cyan;
        alert = perpetua.red_back;
        disabled = perpetua.over1;
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
      "module/xwindow" = {
        type = "internal/xwindow";
        label-maxlen = 30;
      };
      "module/filesystem" = {
        type = "internal/fs";
        interval = 20;

        mount = [ "/" ];

        label.mounted = "%{F${perpetua.yellow}}%mountpoint%%{F-} %percentage_used%%";

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

        label.charging = "%{F${perpetua.cyan}}%percentage%% (%time%)";
        label.discharging = "%percentage%% (%time%)";
        label.full = "FULL";
        label.low = "%{F${perpetua.red}}%percentage%% (%time%)";
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
        label = "%percentage_used:2%%";
      };
      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        format.prefix.text = "CPU ";
        format.prefix.foreground = "\${colors.primary}";
        label = "%percentage:2%%";
      };
      "network-base" = {
        type = "internal/network";
        interval = 2;
        format.connected = "<label-connected>";
        format.disconnected = "<label-disconnected>";
        label.disconnected = "%{F${perpetua.yellow}}%ifname%%{F${perpetua.over1}} disconnected";
      };
      "module/wlan" = {
        "inherit" = "network-base";
        interface.type = "wireless";
        label.connected = "%{F${perpetua.yellow}}%ifname%%{F-} %essid% %local_ip% (%downspeed%)";
      };
      "module/eth" = {
        "inherit" = "network-base";
        interface.type = "wired";
        label.connected = "%{F${perpetua.yellow}}%ifname%%{F-} %local_ip% (%downspeed%)";
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

  # Notification daemon.
  services.dunst.enable = true;

  # Screenshot capturing utility.
  services.flameshot.enable = true;

  # Music player daemon with MPRIS protocol support.
  services.mpd.enable = true;
  services.mpd-mpris.enable = true;

  # Control media players via bluetooth.
  services.mpris-proxy.enable = true;

  # CLI utility to control MPRIS compliant media players.
  services.playerctld.enable = true;

  # File synchronization between local devices.
  services.syncthing.enable = true;

  # Hide the cursor on inactivity.
  services.unclutter.enable = true;

  garden = {
    alacritty = {
      enable = true;
      transparency = true;
      colors = {
        primary = {
          foreground = "${perpetua.text0}";
          background = "${perpetua.base0}";
          dim_foreground = "${perpetua.text2}";
          bright_foreground = "${perpetua.text0}";
        };
        cursor = {
          text = "${perpetua.base0}";
          cursor = "${perpetua.text0}";
        };
        vi_mode_cursor = {
          text = "${perpetua.base0}";
          cursor = "${perpetua.violet}";
        };
        search = {
          matches = {
            foreground = "${perpetua.text0}";
            background = "${perpetua.yellow_back}";
          };
          focused_match = {
            foreground = "${perpetua.text0}";
            background = "${perpetua.turquoise_back}";
          };
        };
        hints = {
          start = {
            foreground = "${perpetua.base0}";
            background = "${perpetua.yellow}";
          };
          end = {
            foreground = "${perpetua.base0}";
            background = "${perpetua.text1}";
          };
        };
        footer_bar = {
          foreground = "${perpetua.base0}";
          background = "${perpetua.text0}";
        };
        selection = {
          text = "${perpetua.text0}";
          background = "${perpetua.base4}";
        };
        normal = {
          black = "${perpetua.base2}";
          red = "${perpetua.red}";
          green = "${perpetua.green}";
          yellow = "${perpetua.yellow}";
          blue = "${perpetua.blue}";
          magenta = "${perpetua.pink}";
          cyan = "${perpetua.cyan}";
          white = "${perpetua.text0}";
        };
        bright = {
          black = "${perpetua.base3}";
          red = "${perpetua.red}";
          green = "${perpetua.green}";
          yellow = "${perpetua.yellow}";
          blue = "${perpetua.blue}";
          magenta = "${perpetua.pink}";
          cyan = "${perpetua.cyan}";
          white = "${perpetua.text1}";
        };
      };
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
      extraKeybindings = {
        "super + @space" = "rofi -show drun -disable-history -sort -sorting-method fzf";
        "super + {_,shift + }n" = "polybar-msg cmd {hide && bspc config bottom_padding 0,show}";
        "super + q" = "rofi -show calc -modi calc -no-show-match -no-sort";
        "super + x" = "betterlockscreen --lock dimblur";
        "{_,shift + }Print" = "flameshot {gui,screen}";
      };
      extraSettings = {
        normal_border_color = perpetua.base2;
        active_border_color = perpetua.yellow_back;
        focused_border_color = perpetua.orange_back;
        presel_feedback_color = perpetua.orange;
        window_gap = 0;
        border_width = 1;
      };
      rules = {
        "Qalculate-gtk".state = "floating";
      };
      startupPrograms = [ "xsetroot -cursor_name left_ptr" ];
    };

    chromium = {
      enable = true;
      allowedCookies = [
        # Bitwarden
        "https://[*.]bitwarden.com"
        # Bluesky
        "https://bsky.app"
        # Duolingo
        "https://www.duolingo.com"
        # Excalidraw
        "https://[*.]excalidraw.com"
        # Fastmail
        "https://[*.]fastmail.com"
        # GitHub
        "https://[*.]github.com"
        # Google
        "https://[*.]google.com"
        "https://www.youtube.com"
        # Netflix
        "https://www.netflix.com"
        # Proton
        "https://[*.]proton.me"
        # Telegram
        "https://web.telegram.org"
        # tldraw
        "https://www.tldraw.com"
        # UniPD
        "https://[*.]unipd.it"
        # WhatsApp
        "https://web.whatsapp.com"
      ];
      extensions = [
        # Bitwarden Password Manager
        {
          id = "nngceckbapebfimnlniiiahkandclblb";
          hash = "sha256-dzw9WHFayRAOi/RbezqRXEKtve3gxcN0kOAvUhXXW+8=";
          version = "2025.2.1";
        }
        # Dark Reader
        {
          id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
          hash = "sha256-YmcbHJ5/CNBeaOui3jx8bmMEH3waocQPPQ94YEQVNHU=";
          version = "4.9.103";
        }
        # LanguageTool
        {
          id = "oldceeleldhonbafppcapldpdifcinji";
          hash = "sha256-CzfPSDYCMGcfS9dV0VH20b+cb+jQKGYbNHy3smSvG7E=";
          version = "8.18.2";
        }
        # Markdown Viewer
        {
          id = "ckkdlimhmcjmikdlpkmbgfkaikojcbjk";
          hash = "sha256-f0m9VUbymI1wWmGasxR2i8XgU+LyNUyTHszYrquD6FE=";
          version = "5.3";
        }
        # Privacy Badger
        {
          id = "pkehgijcmpdhfbdbbnkijodmdjhbjlgp";
          hash = "sha256-gDssatIKJL/0eSDiH/+1/IKRTddRmRGNusiu+DfkDrU=";
          version = "2025.3.3";
        }
        # Refined GitHub
        {
          id = "hlepfoohegkhhmjieoechaddaejaokhf";
          hash = "sha256-D2J3dzrdf+YQAzIn9chRvuRWzekr3STQ0dVkhzgwoAQ=";
          version = "25.2.26";
        }
        # Return YouTube Dislike
        {
          id = "gebbhagfogifgggkldgodflihgfeippi";
          hash = "sha256-V6vZHcLZ2yFe0Mhlm91fky5CB8KEDcV4BqW7zHlRPmY=";
          version = "3.0.0.18";
        }
        # uBlock Origin
        {
          id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
          hash = "sha256-lAJcYnfvnpVoyS8tQ2TGstmFA6PCu/4ySyZZcZSdlnk=";
          version = "1.62.0";
        }
        # Vimium
        {
          id = "dbepggeogbaibhgnhhndojpepiihcmeb";
          hash = "sha256-DaEM1NyMX8RMBvWoIVOhmfY/ae66HCNfRFnwAuLUHVU=";
          version = "2.1.2";
        }
      ];
      defaultSearchProvider = "DuckDuckGo";
    };

    firefox = {
      enable = true;
      supportTridactyl = true;
      containers = [
        { name = "Social"; icon = "fence"; color = "blue"; }
        { name = "Personal"; icon = "fingerprint"; color = "turquoise"; }
        { name = "Anything"; icon = "tree"; color = "green"; }
        { name = "Google"; icon = "pet"; color = "yellow"; }
        { name = "Engineering"; icon = "vacation"; color = "orange"; }
        { name = "University"; icon = "fruit"; color = "red"; }
        { name = "Shopping"; icon = "cart"; color = "pink"; }
        { name = "Fun"; icon = "chill"; color = "purple"; }
        # { name = "Work"; icon = "briefcase"; color = "toolbar"; } # NOTE: Not used for now.
      ];
      allowCookies = [
        # Amazon
        "https://www.amazon.it"

        # Bitwarden
        "https://bitwarden.com"
        "https://vault.bitwarden.com"

        # Bluesky
        "https://bsky.app"

        # Duolingo
        "https://www.duolingo.com"

        # Excalidraw
        "https://excalidraw.com"
        "https://math.preview.excalidraw.com"

        # Fastmail
        "https://app.fastmail.com"

        # GitHub
        "https://github.com"

        # Google
        "https://accounts.google.com"
        "https://mail.google.com"
        "https://translate.google.com"
        "https://www.google.com"
        "https://www.youtube.com"

        # Netflix
        "https://www.netflix.com"

        # Proton
        "https://account.proton.me"
        "https://calendar.proton.me"
        "https://mail.proton.me"

        # Standard Notes
        "https://app.standardnotes.com"

        # Telegram
        "https://web.telegram.org"

        # tldraw
        "https://www.tldraw.com"

        # Twitch
        "https://www.twitch.tv"

        # UniPD
        "https://shibidp.cca.unipd.it"
        "https://stem.elearning.unipd.it"
        "https://uniweb.unipd.it"

        # WhatsApp
        "https://web.whatsapp.com"
      ];
      settings = {
        # This is not well enforced by Firefox, so we also use the
        # automatic-dark extension (installed below).
        "extensions.activeThemeID" = "firefox-compact-${theme}@mozilla.org";
      };
      bookmarks = [
        {
          name = "Bookmarks Toolbar"; toolbar = true;
          bookmarks = [
            { name = "Bluesky"; url = "https://bsky.app/"; }
            { name = "Calendar"; url = "https://calendar.proton.me/"; }
            { name = "DeepL"; url = "https://deepl.com/"; }
            { name = "Dictionary"; url = "https://www.dictionary.com/"; }
            { name = "Fastmail"; url = "https://app.fastmail.com/"; }
            { name = "GitHub"; url = "https://github.com/"; }
            { name = "Gmail"; url = "https://mail.google.com/"; }
            { name = "Netflix"; url = "https://www.netflix.com/"; }
            { name = "NixOS"; url = "https://nixos.org/"; }
            { name = "Spotify"; url = "https://open.spotify.com/"; }
            { name = "Syncthing"; url = "http://127.0.0.1:8384/"; }
            { name = "Telegram"; url = "https://web.telegram.org/"; }
            { name = "Thesaurus"; url = "https://www.thesaurus.com/"; }
            { name = "tldraw"; url = "https://www.tldraw.com/"; }
            { name = "Translate"; url = "https://translate.google.com/"; }
            { name = "Treccani"; url = "https://www.treccani.it/"; }
            { name = "Twitch"; url = "https://www.twitch.tv/"; }
            { name = "Uniweb"; url = "https://uniweb.unipd.it/"; }
            { name = "WhatsApp"; url = "https://web.whatsapp.com/"; }
            { name = "YouTube"; url = "https://www.youtube.com/"; }
          ];
        }
        {
          name = "Artificial Intelligence";
          bookmarks = [
            { name = "ChatGPT"; url = "https://chatgpt.com/"; }
            { name = "Cheshire Cat AI"; url = "https://cheshirecat.ai/"; }
            { name = "Hugging Face"; url = "https://huggingface.co/"; }
            { name = "Ollama"; url = "https://ollama.com/"; }
          ];
        }
        {
          name = "Audio and Music";
          bookmarks = [
            { name = "BUSINESSFUNK"; url = "https://datassette.net/businessfunk/"; }
            { name = "infinifi"; url = "https://infinifi.cafe/"; }
            { name = "Music For Programming"; url = "https://musicforprogramming.net/"; }
          ];
        }
        {
          name = "Colors";
          bookmarks = [
            { name = "APCA Contrast Calculator"; url = "https://www.myndex.com/APCA/"; }
            { name = "Color Designer"; url = "https://colordesigner.io/"; }
            { name = "Coolors"; url = "https://coolors.co/"; }
            { name = "Interactive color picker comparison (Oklch, Okhsv, Okhsl, Hsluv)"; url = "https://bottosson.github.io/misc/colorpicker/"; }
            { name = "Large list of handpicked color names"; url = "https://meodai.github.io/color-names/"; }
            { name = "RAL Farben"; url = "https://www.ral-farben.de/"; }
            { name = "The Dimensions of Colour, modern colour theory"; url = "http://www.huevaluechroma.com/"; }
          ];
        }
        {
          name = "Cryptography and Mathematics";
          bookmarks = [
            { name = "A Computational Introduction to Number Theory and Algebra"; url = "https://shoup.net/ntb/"; }
            { name = "A Few Thoughts on Cryptographic Engineering"; url = "https://blog.cryptographyengineering.com/"; }
            { name = "A Graduate Course in Applied Cryptography"; url = "https://toc.cryptobook.us/"; }
            { name = "An Introduction to Secret-Sharing-Based Secure Multiparty Computation"; url = "https://eprint.iacr.org/2022/062"; }
            { name = "Ben Lynn Notes"; url = "https://crypto.stanford.edu/pbc/notes/"; }
            { name = "cryptii"; url = "https://cryptii.com/"; }
            { name = "Cryptographic Computing"; url = "https://users-cs.au.dk/orlandi/crycom/"; }
            { name = "Cryptography Social"; url = "https://cryptography.social/"; }
            { name = "Desmos | Geometry"; url = "https://www.desmos.com/geometry"; }
            { name = "Dhole Moments"; url = "https://soatok.blog/category/cryptography/"; }
            { name = "EncryptedSystems.org"; url = "https://encryptedsystems.org/"; }
            { name = "GeoGebra Classic"; url = "https://www.geogebra.org/classic"; }
            { name = "Handbook of Applied Cryptography"; url = "https://cacr.uwaterloo.ca/hac/"; }
            { name = "Key Material"; url = "https://keymaterial.net/category/cryptography/"; }
            { name = "Mathematics for Computer Science"; url = "https://courses.csail.mit.edu/6.042/spring18/mcs.pdf"; }
            { name = "Sage Cell Server"; url = "https://sagecell.sagemath.org/"; }
            { name = "Sage Reference Manual"; url = "https://doc.sagemath.org/html/en/reference/"; }
            { name = "Tamarin Prover"; url = "https://tamarin-prover.com/"; }
            { name = "Tamarin Prover Manual"; url = "https://tamarin-prover.com/manual/master/book/004_cryptographic-messages.html"; }
            { name = "The Cryptopals Crypto Challenges"; url = "https://cryptopals.com/"; }
            { name = "The Joy of Cryptography"; url = "https://joyofcryptography.com/"; }
            { name = "Wolfram|Alpha"; url = "https://www.wolframalpha.com/"; }
          ];
        }
        {
          name = "Cybersecurity";
          bookmarks = [
            { name = "CyberChef"; url = "https://gchq.github.io/CyberChef/"; }
            { name = "HackTricks"; url = "https://book.hacktricks.xyz/"; }
            { name = "pwn.college"; url = "https://pwn.college/"; }
            { name = "Shellcodes database"; url = "https://shell-storm.org/shellcode/index.html"; }
            { name = "Web Security Academy - PortSwigger"; url = "https://portswigger.net/web-security/all-topics"; }
            { name = "x86 / x64 Assembler and Disassembler"; url = "https://defuse.ca/online-x86-assembler.htm"; }
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
            { name = "TinyGo"; url = "https://tinygo.org/"; }
          ];
        }
        {
          name = "Nix";
          bookmarks = [
            { name = "aliases.nix"; url = "https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/top-level/aliases.nix"; }
            { name = "all-packages.nix"; url = "https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/top-level/all-packages.nix"; }
            { name = "linux-kernels.nix"; url = "https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/top-level/linux-kernels.nix"; }
            { name = "Flakes aren't real and cannot hurt you"; url = "https://jade.fyi/blog/flakes-arent-real/"; }
            { name = "Home Manager Configuration Options"; url = "https://nix-community.github.io/home-manager/options.xhtml"; }
            { name = "Nix Package Versions"; url = "https://lazamar.co.uk/nix-versions/"; }
            { name = "Nix User Repositories"; url = "https://nur.nix-community.org/"; }
            { name = "nix-community/home-manager"; url = "https://github.com/nix-community/home-manager"; }
            { name = "NixOS & Flakes Book"; url = "https://nixos-and-flakes.thiscute.world/"; }
            { name = "NixOS Wiki"; url = "https://wiki.nixos.org/wiki/NixOS_Wiki"; }
            { name = "NixOS/nixos-hardware"; url = "https://github.com/NixOS/nixos-hardware"; }
            { name = "NixOS/nixpkgs"; url = "https://github.com/NixOS/nixpkgs"; }
            { name = "Nixpkgs PR progress tracker"; url = "https://nixpk.gs/pr-tracker.html"; }
            { name = "noogle"; url = "https://noogle.dev/"; }
            { name = "The Nix lectures"; url = "https://ayats.org/blog/nix-tuto-1"; }
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
          name = "Research";
          bookmarks = [
            { name = "Google Scholar"; url = "https://scholar.google.com/"; }
            { name = "Internet Archive"; url = "https://archive.org/"; }
            { name = "Internet Archive Scholar"; url = "https://scholar.archive.org/"; }
            { name = "Sci-Hub"; url = "https://sci-hub.se/"; }
            { name = "Six Degrees of Wikipedia"; url = "https://www.sixdegreesofwikipedia.com/"; }
          ];
        }
        {
          name = "Rust";
          bookmarks = [
            { name = "crates.io"; url = "https://crates.io/"; }
            { name = "Docs.rs"; url = "https://docs.rs/"; }
            { name = "Query.rs"; url = "https://query.rs/"; }
            { name = "Rust By Example"; url = "https://doc.rust-lang.org/stable/rust-by-example/"; }
            { name = "Rust Playground"; url = "https://play.rust-lang.org/"; }
            { name = "Rust Programming Language"; url = "https://www.rust-lang.org/"; }
            { name = "The Rust Programming Language (book)"; url = "https://doc.rust-lang.org/stable/book/"; }
            { name = "The Rust Standard Library"; url = "https://doc.rust-lang.org/stable/std/"; }
          ];
        }
        {
          name = "Typography";
          bookmarks = [
            { name = "Beautiful Web Type"; url = "https://beautifulwebtype.com/"; }
            { name = "Butterick’s Practical Typography"; url = "https://practicaltypography.com/"; }
            { name = "Chicago Manual of Style"; url = "https://www.grammarly.com/blog/chicago-manual-of-style-citations/"; }
            { name = "Collletttivo | CLT"; url = "https://www.collletttivo.it/"; }
            { name = "Commit Mono"; url = "https://commitmono.com/"; }
            { name = "Dash - Wikipedia"; url = "https://en.wikipedia.org/wiki/Dash"; }
            { name = "Departure Mono"; url = "https://departuremono.com/"; }
            { name = "ドットコロン"; url = "https://dotcolon.net/"; }
            { name = "Font Library"; url = "https://fontlibrary.org/en"; }
            { name = "Font Squirrel"; url = "https://www.fontsquirrel.com/"; }
            { name = "Fonts & Encodings - Yannis Haralambous"; url = "https://hal.science/hal-02112942/document"; }
            { name = "Fonts by Hoefler&Co"; url = "https://www.typography.com/"; }
            { name = "Fontsource"; url = "https://fontsource.org/"; }
            { name = "Fontspring"; url = "https://www.fontspring.com/"; }
            { name = "Get an Emdash"; url = "https://emdash.fan/"; }
            { name = "Google Fonts"; url = "https://fonts.google.com/"; }
            { name = "google webfonts helper"; url = "https://gwfh.mranftl.com/fonts"; }
            { name = "Manrope Font"; url = "https://gent.media/manrope"; }
            { name = "Nerd Fonts"; url = "https://www.nerdfonts.com/"; }
            { name = "Quotation mark - Wikipedia"; url = "https://en.wikipedia.org/wiki/Quotation_mark"; }
            { name = "Title Case Converter"; url = "https://titlecaseconverter.com/"; }
            { name = "Typewolf"; url = "https://www.typewolf.com/"; }
            { name = "U.S. Graphics Company"; url = "https://usgraphics.com/"; }
            { name = "Widows and orphans - Wikipedia"; url = "https://en.wikipedia.org/wiki/Widows_and_orphans"; }
            { name = "zetafonts · the Italian type foundry"; url = "https://www.zetafonts.com/"; }
          ];
        }
        {
          name = "University";
          bookmarks = [
            { name = "Didattica - Cybersecurity"; url = "https://it.didattica.unipd.it/off/2023/LM/SC/SC2542/000ZZ"; }
            { name = "Macroarea STEM"; url = "https://stem.elearning.unipd.it/"; }
            { name = "The illustrated guide to a Ph.D."; url = "https://matt.might.net/articles/phd-school-in-pictures/"; }
            { name = "Università di Padova"; url = "https://www.unipd.it/"; }
          ];
        }
        {
          name = "Web Development";
          bookmarks = [
            { name = "Can I use..."; url = "https://caniuse.com/"; }
            { name = "Favic-o-Matic"; url = "https://favicomatic.com/"; }
            { name = "Fly"; url = "https://fly.io/"; }
            { name = "htmx"; url = "https://htmx.org/"; }
            { name = "Iconoir"; url = "https://iconoir.com/"; }
            { name = "Jeffsum"; url = "https://jeffsum.com/"; }
            { name = "Lorem Ipsum"; url = "https://loremipsum.io/"; }
            { name = "Lucide"; url = "https://lucide.dev/"; }
            { name = "Namecheap"; url = "https://www.namecheap.com/"; }
            { name = "Omatsuri"; url = "https://omatsuri.app/"; }
            { name = "PageSpeed Insights"; url = "https://pagespeed.web.dev/"; }
            { name = "Phosphor Icons"; url = "https://phosphoricons.com/"; }
            { name = "Place ID Finder | Maps JavaScript API"; url = "https://developers.google.com/maps/documentation/javascript/examples/places-placeid-finder"; }
            { name = "player.style"; url = "https://player.style/"; }
            { name = "Quantum Lorem Ipsum"; url = "https://raw.githubusercontent.com/neilpanchal/quantum-lorem-ipsum/master/quantum-lorem-ipsum.txt"; }
            { name = "Squoosh"; url = "https://squoosh.app/"; }
            { name = "Svelte"; url = "https://svelte.dev/"; }
            { name = "SvelteKit"; url = "https://kit.svelte.dev/"; }
            { name = "SweetAlert2"; url = "https://sweetalert2.github.io/"; }
            { name = "Tabler Icons"; url = "https://tablericons.com/"; }
            { name = "Tailwind CSS"; url = "https://tailwindcss.com/"; }
            { name = "templ docs"; url = "https://templ.guide/"; }
          ];
        }
        {
          name = "Miscellaneous";
          bookmarks = [
            { name = "Alacritty"; url = "https://alacritty.org/"; }
            { name = "Amazon.it"; url = "https://www.amazon.it/"; }
            { name = "Apple Rankings"; url = "https://applerankings.com/"; }
            { name = "arkenfox"; url = "https://github.com/arkenfox/user.js"; }
            { name = "arkenfox gui"; url = "https://arkenfox.github.io/gui/"; }
            { name = "Benjamin Keep"; url = "https://www.benjaminkeep.com/"; }
            { name = "Bionic Reading"; url = "https://app.bionic-reading.com/"; }
            { name = "Bluesky Embed"; url = "https://embed.bsky.app/"; }
            { name = "C data types - Wikipedia"; url = "https://en.wikipedia.org/wiki/C_data_types"; }
            { name = "Choose a License"; url = "https://choosealicense.com/"; }
            { name = "cobalt"; url = "https://cobalt.tools/"; }
            { name = "Command Line Interface Guidelines"; url = "https://clig.dev/"; }
            { name = "Compiler Explorer"; url = "https://godbolt.org/"; }
            { name = "configure"; url = "https://configure.xn--stpie-k0a81a.com/"; }
            { name = "Conventional Commits"; url = "https://www.conventionalcommits.org/"; }
            { name = "Coursera"; url = "https://www.coursera.org/"; }
            { name = "Cronokirby (Lúcás Meier)"; url = "https://cronokirby.com/"; }
            { name = "CTAN"; url = "https://ctan.org/"; }
            { name = "decodeunicode"; url = "https://decodeunicode.org/"; }
            { name = "Detexify"; url = "https://detexify.kirelabs.org/"; }
            { name = "Devhints"; url = "https://devhints.io/"; }
            { name = "Diátaxis"; url = "https://diataxis.fr/"; }
            { name = "Dictionary of Algorithms and Data Structures"; url = "https://xlinux.nist.gov/dads/"; }
            { name = "Discord"; url = "https://discord.com/channels/@me"; }
            { name = "Dizionario Etimologico"; url = "https://etimo.it/"; }
            { name = "Duolingo"; url = "https://www.duolingo.com/learn"; }
            { name = "Emojipedia"; url = "https://emojipedia.org/"; }
            { name = "Etsy"; url = "https://www.etsy.com/"; }
            { name = "Every Time Zone"; url = "https://everytimezone.com/"; }
            { name = "Excalidraw"; url = "https://excalidraw.com/"; }
            { name = "Excalidraw STEM"; url = "https://math.preview.excalidraw.com/"; }
            { name = "FilePizza"; url = "https://file.pizza/"; }
            { name = "Filippo Valsorda"; url = "https://filippo.io/"; }
            { name = "Flightradar24"; url = "https://www.flightradar24.com/"; }
            { name = "Freedium"; url = "https://freedium.cfd/"; }
            { name = "fstab - Wikipedia"; url = "https://en.wikipedia.org/wiki/Fstab"; }
            { name = "Generatore di Anagrammi"; url = "https://www.generatorediparole.it/anagramma"; }
            { name = "Gernot's List of Systems Benchmarking Crimes"; url = "https://gernot-heiser.org/benchmarking-crimes.html"; }
            { name = "Ghostty"; url = "https://ghostty.org/"; }
            { name = "GitHub Gist"; url = "https://gist.github.com/"; }
            { name = "GitLab"; url = "https://gitlab.com/"; }
            { name = "Google Style Guides"; url = "https://google.github.io/styleguide/"; }
            { name = "Grammarly"; url = "https://app.grammarly.com/"; }
            { name = "HHKB"; url = "https://hhkeyboard.us/"; }
            { name = "How Many Days Has It Been Since a JWT alg:none Vulnerability?"; url = "https://www.howmanydayssinceajwtalgnonevuln.com/"; }
            { name = "ICANN Lookup"; url = "https://lookup.icann.org/"; }
            { name = "ImperialViolet (Adam Langley)"; url = "https://www.imperialviolet.org/"; }
            { name = "International System of Units - Wikipedia"; url = "https://en.wikipedia.org/wiki/International_System_of_Units"; }
            { name = "Internet protocol suite - Wikipedia"; url = "https://en.wikipedia.org/wiki/Internet_protocol_suite"; }
            { name = "IOC.exchange - Mastodon"; url = "https://ioc.exchange/"; }
            { name = "Jisho"; url = "https://jisho.org/"; }
            { name = "Johnny.Decimal"; url = "https://johnnydecimal.com/"; }
            { name = "Johnny.Decimal Forum"; url = "https://forum.johnnydecimal.com/"; }
            { name = "Johnny.Decimal Workshop"; url = "https://courses.johnnydecimal.com/enrollments/"; }
            { name = "JScrewIt"; url = "https://jscrew.it/"; }
            { name = "JSON Web Tokens"; url = "https://jwt.io/"; }
            { name = "Just Programmer's Manual"; url = "https://just.systems/man/en/"; }
            { name = "Keep a Changelog"; url = "https://keepachangelog.com/"; }
            { name = "Keychron"; url = "https://www.keychron.com/"; }
            { name = "Killed by Google"; url = "https://killedbygoogle.com/"; }
            { name = "Latency Numbers Every Programmer Should Know"; url = "https://samwho.dev/numbers/"; }
            { name = "latex2png"; url = "https://latex2png.com/"; }
            { name = "LaTeX - Wikibooks"; url = "https://en.wikibooks.org/wiki/LaTeX"; }
            { name = "lazy.nvim"; url = "https://lazy.folke.io/"; }
            { name = "Lilaq"; url = "https://lilaq.org/"; }
            { name = "Man Pages"; url = "https://www.mankier.com/"; }
            { name = "Manx"; url = "https://vt100.net/manx/"; }
            { name = "MathJax basic tutorial and quick reference"; url = "https://math.meta.stackexchange.com/questions/5020/mathjax-basic-tutorial-and-quick-reference"; }
            { name = "Microsoft Activation Scripts (MAS)"; url = "https://massgrave.dev/"; }
            { name = "NIST Uncertainty Machine"; url = "https://uncertainty.nist.gov/"; }
            { name = "NO_COLOR"; url = "https://no-color.org/"; }
            { name = "No Starch Press"; url = "https://nostarch.com/"; }
            { name = "Non-SI units mentioned in the SI - Wikipedia"; url = "https://en.wikipedia.org/wiki/Non-SI_units_mentioned_in_the_SI"; }
            { name = "PanelsDesu"; url = "https://panelsdesu.com/"; }
            { name = "Perpetua"; url = "https://perpetuatheme.com/"; }
            { name = "Policy Templates for Firefox"; url = "https://mozilla.github.io/policy-templates/"; }
            { name = "Project Gutenberg"; url = "https://www.gutenberg.org/"; }
            { name = "QuickPic"; url = "https://quickpic.t3.gg/"; }
            { name = "Reference - The Chromium Projects"; url = "https://www.chromium.org/chromium-os/developer-library/reference/"; }
            { name = "RegExr"; url = "https://regexr.com/"; }
            { name = "research!rsc"; url = "https://research.swtch.com/"; }
            { name = "Screego"; url = "https://app.screego.net/"; }
            { name = "Semantic Versioning"; url = "https://semver.org/"; }
            { name = "SequenceDiagram.org"; url = "https://sequencediagram.org/"; }
            { name = "Simone Ragusa"; url = "https://interrato.dev/"; }
            { name = "SPDX License List"; url = "https://spdx.org/licenses/"; }
            { name = "Special Publication 811 | NIST"; url = "https://www.nist.gov/pml/special-publication-811"; }
            { name = "Stack Exchange"; url = "https://stackexchange.com/sites"; }
            { name = "Standard Notes"; url = "https://app.standardnotes.com/"; }
            { name = "SVG Repo"; url = "https://www.svgrepo.com/"; }
            { name = "SVG Viewer"; url = "https://www.svgviewer.dev/"; }
            { name = "The Official U.S. Time | NIST"; url = "https://www.time.gov/"; }
            { name = "Time.is"; url = "https://time.is/"; }
            { name = "Touying"; url = "https://touying-typ.github.io/docs/start/"; }
            { name = "Typst Documentation"; url = "https://typst.app/docs/"; }
            { name = "Usage message - Wikipedia"; url = "https://en.wikipedia.org/wiki/Usage_message"; }
            { name = "Watson Text to Speech"; url = "https://www.ibm.com/demos/live/tts-demo/self-service/home"; }
            { name = "WordSafety.com"; url = "http://wordsafety.com/"; }
            { name = "Xe Iaso"; url = "https://xeiaso.net/"; }
            { name = "Yr - Weather forecast"; url = "https://www.yr.no/en"; }
            { name = "ZSH - Documentation"; url = "https://zsh.sourceforge.io/Doc/"; }
          ];
        }
      ];
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        automatic-dark
        bitwarden
        darkreader
        multi-account-containers
        skip-redirect
        ublock-origin
      ];
      homepage = "https://interrato.dev/";
      preferredSearchEngine = "DuckDuckGo";
      tridactyl.enable = true;
      tridactyl.extraConfig = ''
        " Clear all existing settings: if a setting in this file is removed, it
        " will revert to the default.
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

        " Ignore Tridactyl on some websites.
        autocmd DocStart app.grammarly.com mode ignore
        autocmd DocStart app.standardnotes.com mode ignore
        autocmd DocStart excalidraw.com mode ignore
        autocmd DocStart mail.google.com mode ignore
        autocmd DocStart math.preview.excalidraw.com mode ignore
        autocmd DocStart open.spotify.com mode ignore
        autocmd DocStart web.telegram.org mode ignore
        autocmd DocStart web.whatsapp.com mode ignore
        autocmd DocStart www.duolingo.com mode ignore
        autocmd DocStart www.geogebra.org mode ignore
        autocmd DocStart www.netflix.com mode ignore
        autocmd DocStart www.tldraw.com mode ignore
        autocmd DocStart www.twitch.tv mode ignore
        autocmd DocStart www.youtube.com mode ignore

        set completionfuzziness 0.2
        set hintfiltermode vimperator-reflow
        set hintnames numeric
        set modeindicatorshowkeys true
        set smoothscroll true
      '';
    };
  };

  systemd.user.services = {
    set-wallpaper = {
      Unit.Description = "Set a random wallpaper";
      Service = {
        Environment = [
          "PATH=/etc/profiles/per-user/${currentUser}/bin:/run/current-system/sw/bin"
          "NIXOS_THEME=${theme}"
        ];
        ExecStart = "/home/${currentUser}/Scripts/set-wallpaper";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.timers = {
    set-wallpaper = {
      Unit.Description = "Set a random wallpaper every 60 minutes";
      Timer.OnUnitActiveSec = "60min";
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };

  home.file."Pictures" = {
    source = ./wallpapers;
    recursive = true;
  };

  home.file."Scripts" = {
    source = ./scripts;
    recursive = true;
  };

  xdg.configFile."betterlockscreen/betterlockscreenrc".text = ''
    wallpaper_cmd="feh --no-fehbg --bg-fill"
    loginbox=00000000
    ringcolor=${perpetua.text0}ff
    ringvercolor=${perpetua.text0}ff
    ringwrongcolor=${perpetua.text0}ff
    insidewrongcolor=${perpetua.red}ff
    timecolor=${perpetua.text0}ff
    time_format="%H:%M:%S"
    greetercolor=${perpetua.text0}ff
    layoutcolor=${perpetua.text0}ff
    keyhlcolor=${perpetua.red}ff
    bshlcolor=${perpetua.red}ff
    veriftext="Verifying..."
    verifcolor=${perpetua.text0}ff
    wrongtext="Failure!"
    wrongcolor=${perpetua.red}ff
    modifcolor=${perpetua.red}ff
    bgcolor=${perpetua.base0}ff
  '';

  xdg.configFile."felix/config.yaml".text = ''
    match_vim_exit_behavior: true
    exec:
      'feh -.':
        [gif, hdr, jpeg, jpg, png, svg]
      mpv:
        [flac, mkv, mov, mp3, mp4]
      zathura:
        [pdf]
    color:
      dir_fg: LightBlue
      file_fg: LightWhite
      symlink_fg: LightCyan
      dirty_fg: Red
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
