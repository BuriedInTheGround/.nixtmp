{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.garden.firefox;

  container = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        default = "Container";
        description = "The name of the container.";
        example = "Shopping";
      };

      icon = mkOption {
        type = types.enum [
          "fingerprint"
          "briefcase"
          "dollar"
          "cart"
          "vacation"
          "gift"
          "food"
          "fruit"
          "pet"
          "tree"
          "chill"
          "circle"
          "fence"
        ];
        default = "fence";
        description = "The icon of the container.";
        example = "cart";
      };

      color = mkOption {
        type = types.enum [
          "blue"
          "turquoise"
          "green"
          "yellow"
          "orange"
          "red"
          "pink"
          "purple"
          # "toolbar" # NOTE: Unsupported by the extension.
        ];
        default = "blue";
        description = "The color of the container.";
        example = "pink";
      };
    };
  };

  bookmark = types.addCheck (types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        default = "Bookmark";
        description = "The name of the bookmark.";
      };

      url = mkOption {
        type = types.str;
        default = "https://example.com/";
        description = "The URL of the bookmark. Use %s for search terms.";
      };
    };
  }) (item: item ? "url");

  folder = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        default = "Bookmarks";
        description = "The name of the bookmarks folder.";
      };

      bookmarks = mkOption {
        type = with types; listOf (either bookmark folder);
        default = [ ];
        description = "The bookmarks inside the folder.";
      };

      toolbar = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to display the folder in the toolbar.";
      };
    };
  };

  firefoxBookmarksFile = bookmarks:
    let
      indent = level: concatStringsSep "" (map (const "  ") (range 1 level));

      bookmarkToHTML = indentLevel: bookmark: ''
        ${indent indentLevel}<DT><A ADD_DATE="1" LAST_MODIFIED="1" HREF="${
          escapeXML bookmark.url
        }">${escapeXML bookmark.name}</A>
      '';

      directoryToHTML = indentLevel: directory: ''
        ${indent indentLevel}<DT>${
          if directory.toolbar then
            ''<H3 PERSONAL_TOOLBAR_FOLDER="true">Bookmarks Toolbar''
          else
            "<H3>${escapeXML directory.name}"
        }</H3>
        ${indent indentLevel}<DL><p>
        ${allItemsToHTML (indentLevel + 1) directory.bookmarks}
        ${indent indentLevel}</p></DL>
      '';

      itemToHTMLOrRecurse = indentLevel: item:
        if item ? "url" then
          bookmarkToHTML indentLevel item
        else
          directoryToHTML indentLevel item;

      allItemsToHTML = indentLevel: bookmarks:
        concatStringsSep "\n" (map (itemToHTMLOrRecurse indentLevel) bookmarks);

      bookmarkEntries = allItemsToHTML 1 bookmarks;
    in pkgs.writeText "firefox-bookmarks.html" ''
      <!DOCTYPE NETSCAPE-Bookmark-file-1>
      <!-- This is an automatically generated file.
        It will be read and overwritten.
        DO NOT EDIT! -->
      <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
      <TITLE>Bookmarks</TITLE>
      <H1>Bookmarks Menu</H1>
      <DL><p>
      ${bookmarkEntries}
      </p></DL>
    '';

  mkUserJs = { prefs ? { }, bookmarks ? [ ] }:
    let
      prefs' = optionalAttrs (bookmark != [ ]) {
        "browser.bookmarks.file" = toString (firefoxBookmarksFile bookmarks);
        "browser.places.importBookmarksHTML" = true;
      } // prefs;
    in ''
      // ============ ARKENFOX BEGIN ============
      ${fileContents "${pkgs.nur.repos.ataraxiasjel.arkenfox-userjs}/share/user.js/user.js"}
      // ============= ARKENFOX END =============

      // ============ OVERRIDE BEGIN ============
      ${concatStrings (mapAttrsToList (name: value: ''
        user_pref("${name}", ${builtins.toJSON value});
      '') prefs')}
      // ============= OVERRIDE END =============
    '';
in {
  options.garden.firefox = {
    enable = mkEnableOption "Firefox";

    supportTridactyl = mkEnableOption ''
      Tridactyl integration with Firefox Native Messaging
    '';

    containers = mkOption {
      type = types.listOf container;
      default = [ ];
      description = "The initial set for Firefox Multi-Account Containers.";
      example = literalExpression ''
        [
          {
            name = "Shopping";
            icon = "cart";
            color = "pink";
          }
        ]
      '';
    };

    allowCookies = mkOption {
      type = with types; listOf (strMatching "^(http|https):\/\/[[:graph:]]*$");
      default = [ ];
      description = ''
        A list of origins (not domains) where cookies are always allowed.
        You must include http or https.
      '';
      example = literalExpression ''
        [
          "https://accounts.google.com/"
          "https://mail.google.com/"
        ]
      '';
    };

    bookmarks = mkOption {
      type = with types; listOf (either bookmark folder);
      default = [ ];
      description = ''
        A list of preloaded bookmarks.

        Create a folder named "Bookmarks Toolbar" to display bookmarks
        directly in the toolbar.
      '';
    };

    extensions = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = ''
        List of Firefox add-on packages to install.

        Note that it is necessary to manually enable these extensions
        inside Firefox after the first installation.
      '';
      example = literalExpression ''
        with pkgs.nur.repos.rycee.firefox-addons; [
          privacy-badger
        ]
      '';
    };

    homepage = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        The page you see when you open your homepage, new windows, and new tabs.
      '';
    };

    preferredSearchEngine = mkOption {
      type = types.enum [ "DuckDuckGo" "Google" ];
      default = "DuckDuckGo";
      description = ''
        The preferred search engine used in the address bar and search bar.
      '';
    };

    userChrome = mkOption {
      type = types.lines;
      default = "";
      description = "Custom Firefox userChrome.css.";
    };
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox.override {
        nativeMessagingHosts = optional cfg.supportTridactyl pkgs.tridactyl-native;
        extraPolicies = {
          CaptivePortal = false;
          Containers.Default = cfg.containers;
          Cookies.Allow = cfg.allowCookies;
          DisableFirefoxAccounts = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          FirefoxHome = {
            Search = true;
            TopSites = false;
            SponsoredTopSites = false;
            Highlights = false;
            Pocket = false;
            SponsoredPocket = false;
            Snippets = false;
            Locked = true;
          };
          UserMessaging = {
            WhatsNew = false;
            ExtensionRecommendations = false;
            FeatureRecommendations = false;
            UrlbarInterventions = false;
            SkipOnboarding = true;
            MoreFromMozilla = false;
            Locked = true;
          };
        };
      };
      profiles.default = {
        extensions = cfg.extensions;
        extraConfig = mkUserJs {
          prefs = {
            # Allow Firefox to verify the safety of certain executables by
            # sending some information to the Google Safe Browsing service.
            "browser.safebrowsing.downloads.remote.enabled" = true; # 0403

            # Enable searching from the location bar.
            "keyword.enabled" = true; # 0801

            # Enable and customize search suggestions.
            "browser.search.suggest.enabled" = true; # 0804
            "browser.urlbar.suggest.searches" = true; # 0804
            "browser.urlbar.suggest.engines" = false; # 0808
            "browser.urlbar.suggest.history" = true; # 5010
            "browser.urlbar.suggest.bookmark" = true; # 5010
            "browser.urlbar.suggest.openpage" = false; # 5010
            "browser.urlbar.suggest.topsites" = false; # 5010

            # Send a cross-origin referer.
            "network.http.referer.XOriginPolicy" = 0; # 1601

            # Disable RFP.
            "privacy.resistFingerprinting" = false; # 4501
            "privacy.resistFingerprinting.letterboxing" = false; # 4504
            "webgl.disabled" = false; # 4520

            # Set the browser home page.
            "browser.startup.page" = 1;
            "browser.startup.homepage" =
              if (cfg.homepage != null) then
                cfg.homepage
              else if (cfg.preferredSearchEngine == "DuckDuckGo") then
                "https://duckduckgo.com/"
              else if (cfg.preferredSearchEngine == "Google") then
                "https://www.google.com/"
              else "about:blank";

            # Disable Firefox View.
            "browser.tabs.firefox-view" = false;

            # Don't draw the tabs inside the title bar.
            "browser.tabs.inTitlebar" = 0;

            # Don't hide the toolbars automatically when going fullscreen.
            "browser.fullscreen.autohide" = false;

            # Set CTRL+Tab to switch to the most recently used tab, not to
            # cycle through all tabs.
            "browser.ctrlTab.sortByRecentlyUsed" = true;

            # We want to be able to apply a heavily customized userChrome.
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };
          bookmarks = cfg.bookmarks;
        };
        search = {
          default = cfg.preferredSearchEngine;
          engines = {
            "Amazon.com".metaData.hidden = true;
            "Amazon.it".metaData.hidden = true;
            "Amazon.fr".metaData.hidden = true;
            "Bing".metaData.hidden = true;
            "DuckDuckGo" = mkIf (cfg.preferredSearchEngine != "DuckDuckGo") {
              metaData.hidden = true;
            };
            "Google" = mkIf (cfg.preferredSearchEngine != "Google") {
              metaData.hidden = true;
            };
            "Wikipedia (en)".metaData.hidden = true;
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "type"; value = "packages"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "NixOS Options" = {
              urls = [{
                template = "https://search.nixos.org/options";
                params = [
                  { name = "type"; value = "options"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@no" ];
            };
            "Home Manager Options" = {
              urls = [{
                template = "https://mipmip.github.io/home-manager-option-search/?query={searchTerms}";
              }];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@hm" ];
            };
            "Go Packages" = {
              urls = [{
                template = "https://pkg.go.dev/search?q={searchTerms}";
              }];
              icon = "${pkgs.super-tiny-icons}/share/icons/SuperTinyIcons/svg/go.svg";
              definedAliases = [ "@go" ];
            };
          };
          force = true;
        };
        userChrome = cfg.userChrome;
      };
    };
  };
}
