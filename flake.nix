{
  description = "BuriedInTheGround's NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nur.url = "github:nix-community/NUR";

    perpetua.url = "github:perpetuatheme/nix";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... } @ inputs:
  let
    mkSystem = import ./lib/mksystem.nix;
    revision = self.rev or self.dirtyRev or "dirty";
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
      inputs.nur.overlay
    ];
    lib = nixpkgs.lib.extend (self: super: {
      perpetua = inputs.perpetua.lib;
    });
  in {
    nixosConfigurations.tameshi = mkSystem "tameshi" {
      inherit lib nixpkgs-unstable home-manager revision overlays;
      extraModules = [
        inputs.nixos-hardware.nixosModules.common-gpu-amd-southern-islands
      ];
      system = "x86_64-linux";
      user = "simone";
    };

    nixosConfigurations.kokoromi = mkSystem "kokoromi" {
      inherit lib nixpkgs-unstable home-manager revision overlays;
      extraModules = [
        inputs.nixos-hardware.nixosModules.common-gpu-intel
      ];
      system = "x86_64-linux";
      user = "simone";
    };
  };
}
