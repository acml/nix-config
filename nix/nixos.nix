{ self
, agenix
, base16-schemes
, home-manager
, impermanence
, lanzaboote
, nix-index-database
, nixos-hardware
, nixpkgs
, nixvim
, catppuccin
, stylix
, ...
}:
let
  inherit (nixpkgs) lib;

  genConfiguration = hostname: { address, hostPlatform, type, ... }:
    lib.nixosSystem {
      modules = [
        (../hosts + "/${hostname}")
        {
          nix.registry = {
            nixpkgs.flake = nixpkgs;
            p.flake = nixpkgs;
          };
          nixpkgs.pkgs = self.pkgs.${hostPlatform};
        }
      ];
      specialArgs = {
        hostAddress = address;
        hostType = type;
        inherit
          agenix
          base16-schemes
          home-manager
          impermanence
          lanzaboote
          nix-index-database
          nixos-hardware
          nixvim
          catppuccin
          stylix;
      };
    };
in
lib.mapAttrs
  genConfiguration
  (lib.filterAttrs (_: host: host.type == "nixos") self.hosts)
