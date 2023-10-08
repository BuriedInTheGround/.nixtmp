# This function creates a NixOS system.
name: { nixpkgs, home-manager, revision, overlays, extraModules, system, user }:

nixpkgs.lib.nixosSystem {
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
        currentSystemName = name;
        currentUser = user;
      };

      # Apply our overlays.
      nixpkgs.overlays = overlays;

      # Bake the git revision of the repository into the system.
      system.configurationRevision = revision;
    })
  ] ++ extraModules;
}
