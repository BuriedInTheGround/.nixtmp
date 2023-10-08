{
  description = "BuriedInTheGround's NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
  let
    mkSystem = import ./lib/mksystem.nix;
    revision = self.rev or self.dirtyRev or "dirty";
    overlays = [ inputs.nur.overlay ];
  in {
    nixosConfigurations.tameshi = mkSystem "tameshi" {
      inherit nixpkgs home-manager revision overlays;
      extraModules = [
        inputs.nixos-hardware.nixosModules.common-gpu-amd-southern-islands
      ];
      system = "x86_64-linux";
      user = "simone";
    };

    nixosConfigurations.kokoromi = mkSystem "kokoromi" {
      inherit nixpkgs home-manager revision overlays;
      system = "x86_64-linux"; # TODO: ??
      user = "simone";
    };
  };
}
