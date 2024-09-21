# This function creates a NixOS system.
{ lib, inputs, overlays, revision }:

name: { extraModules, user }:

lib.nixosSystem {
  inherit lib;

  modules = [
    ../hosts/${name}
    ../hosts/shared.nix
    ../users/${user}/nixos.nix
    inputs.home-manager.nixosModules.home-manager {
      home-manager.extraSpecialArgs = { inherit inputs; }; # See below.
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

      # Bake the git revision of the repository into the system.
      system.configurationRevision = revision;
    })
  ] ++ extraModules;

  # We set the flake inputs as a special argument for all submodules, so we can
  # access them directly everywhere.
  specialArgs = { inherit inputs; };
}
