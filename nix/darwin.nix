{ self
, base16-schemes
, darwin
, home-manager
, impermanence
, nix-index-database
, nixpkgs
, stylix
, templates
, ...
}:
let
  inherit (nixpkgs) lib;

  genConfiguration = hostname: { hostPlatform, type, ... }:
    darwin.lib.darwinSystem {
      system = hostPlatform;
      pkgs = self.pkgs.${hostPlatform};
      modules = [
        (../hosts + "/${hostname}")
        {
          nix.registry = {
            nixpkgs.flake = nixpkgs;
            p.flake = nixpkgs;
            templates.flake = templates;
          };
        }
      ];
      specialArgs = {
        hostType = type;
        inherit
          base16-schemes
          home-manager
          impermanence
          nix-index-database
          stylix;
      };
    };
in
lib.recurseIntoAttrs
  (lib.mapAttrs
    genConfiguration
    (lib.filterAttrs (_: host: host.type == "darwin") self.hosts))
