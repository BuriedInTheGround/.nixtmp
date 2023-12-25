# This function creates a NixOS system.
name: { lib, home-manager, revision, overlays, extraModules, system, user }:

lib.nixosSystem {
  inherit lib;
  inherit system;

  modules = [
    ../hosts/${name}
    ../hosts/shared.nix
    ../users/${user}/nixos.nix
    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = {
        imports = [ ../users/${user}/home.nix ];
        _module.args.currentUser = user;
      };
    }

    ({ ... }: {
      # We expose some extra arguments so that our modules can better
      # parameterize based on these values.
      _module.args = {
        currentHost = name;
        currentUser = user;
      };

      # Apply our overlays.
      nixpkgs.overlays = overlays;

      # FIXME: this is needed for Logseq and must be removed when no longer
      # necessary.
      nixpkgs.config.permittedInsecurePackages = [
        "electron-25.9.0"
      ];

      # Bake the git revision of the repository into the system.
      system.configurationRevision = revision;
    })
  ] ++ extraModules;
}
