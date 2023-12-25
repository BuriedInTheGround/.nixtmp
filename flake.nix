{
  description = "BuriedInTheGround's NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    perpetua.url = "github:perpetuatheme/nix";
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
  let
    mkSystem = import ./lib/mksystem.nix;
    revision = self.rev or self.dirtyRev or "dirty";
    overlays = [ inputs.nur.overlay ];
    lib = nixpkgs.lib.extend (self: super: {
      perpetua = inputs.perpetua.lib;
    });
  in {
    nixosConfigurations.tameshi = mkSystem "tameshi" {
      inherit lib home-manager revision overlays;
      extraModules = [
        inputs.nixos-hardware.nixosModules.common-gpu-amd-southern-islands
      ];
      system = "x86_64-linux";
      user = "simone";
    };

    nixosConfigurations.kokoromi = mkSystem "kokoromi" {
      inherit lib home-manager revision overlays;
      extraModules = [
        inputs.nixos-hardware.nixosModules.common-gpu-intel
      ];
      system = "x86_64-linux";
      user = "simone";
    };
  };
}
