{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.garden.chromium;

  extension = types.submodule {
    options = {
      id = mkOption {
        type = types.strMatching "[A-Za-z]{32}";
        default = "";
        description = "The extension ID from the Chrome Web Store URL.";
        example = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
      };

      hash = mkOption {
        type = types.str;
        default = "";
        description = "The SRI hash of the extension crx file.";
        example = "sha256-lAJcYnfvnpVoyS8tQ2TGstmFA6PCu/4ySyZZcZSdlnk=";
      };

      version = mkOption {
        type = types.str;
        default = "";
        description = "The extension version.";
        example = "1.62.0";
      };
    };
  };
in {
  options.garden.chromium = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable Chromium.

        Make sure to add

        ```nix
          environment.etc."chromium/policies".source = "/home/<USER>/.config/chromium/policies";
        ```

        to your system configuration so that Chrome Enterprise policies can be applied.
      '';
      example = true;
    };

    allowedCookies = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        A list of URL patterns that specify sites for which cookies are always allowed.

        See https://chromeenterprise.google/intl/en_us/policies/url-patterns/ for
        details on valid URL patterns.
      '';
      example = literalExpression ''
        [
          "https://[*.]google.com"
          "https://bsky.app"
        ]
      '';
    };

    extensions = mkOption {
      type = types.listOf extension;
      default = [ ];
      description = "List of Chromium extensions to install.";
      example = literalExpression ''
        [
          {
            id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; # uBlock Origin
            hash = "sha256-lAJcYnfvnpVoyS8tQ2TGstmFA6PCu/4ySyZZcZSdlnk=";
            version = "1.62.0";
          }
        ]
      '';
    };

    defaultSearchProvider = mkOption {
      type = types.nullOr (types.enum [ "DuckDuckGo" ]);
      default = null;
      description = ''
        Default search provider to use when non-URL text is entered in the address bar.
      '';
      example = "DuckDuckGo";
    };
  };

  config = mkIf cfg.enable {
    programs.chromium =
      let
        browserPackage = pkgs.ungoogled-chromium.override { enableWideVine = true; };
        createChromiumExtensionFor = browserVersion: { id, hash, version }:
          {
            inherit id version;
            crxPath = pkgs.fetchurl {
              inherit hash;
              url = "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=${browserVersion}&x=id%3D${id}%26installsource%3Dondemand%26uc";
              name = "${id}.crx";
            };
          };
        createChromiumExtension = createChromiumExtensionFor (lib.versions.major browserPackage.version);
      in {
        enable = true;
        package = browserPackage;
        commandLineArgs = [
          # ungoogled-chromium flags
          "--extension-mime-request-handling=always-prompt-for-install"
          "--force-punycode-hostnames"
          "--close-confirmation=last"
          "--close-window-with-last-tab=never"
          "--hide-fullscreen-exit-ui"
          "--scroll-tabs=never"
          "--show-avatar-button=incognito-and-guest"
          # chromium flags
          "--disable-top-sites"
          "--ignore-gpu-blocklist"
          "--enable-zero-copy"
          # ungoogled-chromium first, chromium after
          "--enable-features=SetIpv6ProbeFalse,DisableLinkDrag,AcceleratedVideoEncoder"
        ];
        extensions = map (ext: createChromiumExtension ext) cfg.extensions;
      };

    # NOTE: Updated for Chrome 134 (see https://chromeenterprise.google/intl/en_us/policies/).
    xdg.configFile."chromium/policies/managed/policies.json".text = builtins.toJSON ({
      # Content settings
      CookiesAllowedForUrls = cfg.allowedCookies;
      DefaultCookiesSetting = 4;

      # Miscellaneous
      AutofillCreditCardEnabled = false; # Disable AutoFill for credit cards
      BrowserGuestModeEnabled = false; # Prevent guest browser logins
      BrowserSignin = 0; # Disable browser sign-in
      ClearBrowsingDataOnExitList = [
        "browsing_history"
        "download_history"
        # keep "cookies_and_other_site_data"
        "cached_images_and_files"
        "password_signin"
        "autofill"
        "site_settings"
        "hosted_app_data"
      ];
      DefaultBrowserSettingEnabled = false; # Disable the default browser check on startup
      HttpsOnlyMode = "force_balanced_enabled"; # Force enable HTTPS-Only Mode in Balanced Mode
      PaymentMethodQueryEnabled =  false; # Always tell websites that no payment methods are saved
      SiteSearchSettings = [
        {
          name = "Go Packages";
          shortcut = "go";
          url = "https://pkg.go.dev/search?q={searchTerms}";
        }
        {
          name = "Home Manager Options";
          shortcut = "hm";
          url = "https://home-manager-options.extranix.com/?query={searchTerms}";
        }
        {
          name = "Nix Packages";
          shortcut = "np";
          url = "https://search.nixos.org/packages?query={searchTerms}";
        }
        {
          name = "NixOS Options";
          shortcut = "no";
          url = "https://search.nixos.org/options?query={searchTerms}";
        }
        {
          name = "NixOS Wiki";
          shortcut = "nw";
          url = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
        }
        {
          name = "Searchix";
          shortcut = "sn";
          url = "https://searchix.alanpearce.eu/?query={searchTerms}";
        }
        {
          name = "YouTube";
          shortcut = "yt";
          url = "https://www.youtube.com/results?search_query={searchTerms}";
        }
      ];
      SyncDisabled = true; # Disable Chrome Sync

      # Password manager
      PasswordManagerEnabled = false; # Disable saving passwords using the password manager

      # Startup, Home page and New Tab page
      HomepageIsNewTabPage = true; # Use New Tab Page as homepage
    } // optionalAttrs (cfg.defaultSearchProvider == "DuckDuckGo") {
        # Default search provider
        DefaultSearchProviderEnabled = true;
        DefaultSearchProviderKeyword = "ddg";
        DefaultSearchProviderName = "DuckDuckGo";
        DefaultSearchProviderNewTabURL = "https://start.duckduckgo.com/";
        DefaultSearchProviderSearchURL = "https://start.duckduckgo.com/?q={searchTerms}";
        DefaultSearchProviderSuggestURL = "https://start.duckduckgo.com/ac/?q={searchTerms}&type=list";

        # Miscellaneous
        SearchSuggestEnabled = true; # Enable search suggestions
      });
  };
}
