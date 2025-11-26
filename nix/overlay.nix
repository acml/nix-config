{ inputs, ... }:

let
  inherit (inputs.nixpkgs) lib;

  localOverlays = lib.mapAttrs' (
    f: _: lib.nameValuePair (lib.removeSuffix ".nix" f) (import (./overlays + "/${f}"))
  ) (builtins.readDir ./overlays);

in
localOverlays
// {
  default = lib.composeManyExtensions (
    [
      inputs.agenix.overlays.default
      inputs.deploy-rs.overlays.default
      (final: prev: {
        inherit (inputs.nix-fast-build.packages.${final.stdenv.hostPlatform.system}) nix-fast-build;
      })
      (final: _: {
        # this allows you to access `pkgs.unstable` anywhere in your config
        unstable = import inputs.nixpkgs-unstable {
          inherit (final.stdenv.hostPlatform) system;
          inherit (final) config;
        };
      })
      (
        final: prev:
        let
          nixvimPkgs = inputs.nixvim.legacyPackages.${final.stdenv.hostPlatform.system};
          nixvimModule = {
            pkgs = final;
            module = import ../users/bemeurer/neovim/config.nix;
          };
        in
        {
          neovim-bemeurer = nixvimPkgs.makeNixvimWithModule nixvimModule;
        }
      )
    ]
    ++ (lib.attrValues localOverlays)
  );
}
