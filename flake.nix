{
  description = "Simone's NixOS configurations";

  inputs = {
    # We pin our primary nixpkgs repository. Be careful when changing this, as
    # it affects the entire system. Always check the Backward Incompatibilities
    # section of the Release Notes in the NixOS manual before upgrading.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # We use the unstable nixpkgs repo for some packages, such as Neovim.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # We need specific hardware configurations for some hosts.
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # We use Home Manager to manage user environments (i.e. /home/<user>).
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Community packages from the Nix User Repository.
    nur.url = "github:nix-community/NUR";

    # Nightly version of Neovim.
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Lightness-calibrated, unique natural hues for the tireless artisan. 🎨
    perpetua.url = "github:perpetuatheme/nix";
  };

  outputs = { self, ... } @ inputs:
  let
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
      inputs.nur.overlay
    ];

    lib = inputs.nixpkgs.lib.extend (final: prev: {
      perpetua = inputs.perpetua.lib;
    });

    revision = self.rev or self.dirtyRev or "dirty";

    mkSystem = import ./lib/mksystem.nix {
      inherit lib inputs overlays revision;
    };
  in {
    nixosConfigurations.tameshi = mkSystem "tameshi" {
      extraModules = [
        inputs.nixos-hardware.nixosModules.common-gpu-amd-southern-islands
      ];
      user = "simone";
    };

    nixosConfigurations.kokoromi = mkSystem "kokoromi" {
      extraModules = [
        inputs.nixos-hardware.nixosModules.common-gpu-intel
      ];
      user = "simone";
    };

    devShells.x86_64-linux =
    let
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    in {
      default = pkgs.mkShell {
        packages = [ pkgs.just ];
      };
    };
  };
}
