{ self
, agenix
, base16-schemes
, home-manager
, impermanence
, lanzaboote
, nix-index-database
, nixos-hardware
, nixpkgs
, stylix
, templates
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
            templates.flake = templates;
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
          stylix;
      };
    };
in
lib.recurseIntoAttrs
  (lib.mapAttrs
    genConfiguration
    (lib.filterAttrs (_: host: host.type == "nixos") self.hosts))
