{ self
, agenix
, deploy-rs
, nixpkgs
, ...
}:

let
  inherit (nixpkgs) lib;
  localOverlays =
    lib.mapAttrs'
      (f: _: lib.nameValuePair
        (lib.removeSuffix ".nix" f)
        (import (./overlays + "/${f}")))
      (builtins.readDir ./overlays);

in
localOverlays // {
  default = lib.composeManyExtensions ([
    agenix.overlays.default
    deploy-rs.overlay
    (final: prev: {
      inherit (self.packages.${final.stdenv.hostPlatform.system}) nix-fast-build;
    })
  ] ++ (lib.attrValues localOverlays));
}
