{ inputs, ... }:

let
  inherit (inputs.nixpkgs) lib;

  importLocalOverlay =
    file: lib.composeExtensions (_: _: { __inputs = inputs; }) (import (./overlays + "/${file}"));

  localOverlays = lib.mapAttrs' (
    f: _: lib.nameValuePair (lib.removeSuffix ".nix" f) (importLocalOverlay f)
  ) (builtins.readDir ./overlays);

in
localOverlays
// {
  default = lib.composeManyExtensions (
    [
      inputs.agenix.overlays.default
      inputs.deploy-rs.overlays.default
      inputs.lovesegfault-vim-config.overlays.default
      inputs.nh.overlays.default
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
    ]
    ++ (lib.attrValues localOverlays)
  );
}
