let
  pkgs = import (import ./nix).nixpkgs { };
  deploy = pkgs.writeScriptBin "deploy" ''
    #!${pkgs.stdenv.shell}
    set -o pipefail
    set -o xtrace
    set -o errexit

    trap "exit" INT TERM
    trap "kill 0" EXIT

    function deploy() {
      local cmd=("nix-build" "--no-out-link")
      if [ $# -gt 0 ]; then
        cmd+=("-A" "$1")
      fi
      "''${cmd[@]}" | ${pkgs.stdenv.shell}
    }

    eval "$(ssh-agent)"
    deploy "$@"
    exit
  '';
  genci = pkgs.writeScriptBin "genci" ''
    #!${pkgs.stdenv.shell}
    set -o pipefail
    set -o xtrace

    nix-build --no-out-link ci.nix | ${pkgs.stdenv.shell}
  '';
in
pkgs.mkShell {
  name = "nix-config";
  buildInputs = with pkgs; [
    cachix
    niv
    nixpkgs-fmt

    deploy
    genci
  ];
  shellHook = "${(import ./.).preCommitChecks.shellHook}";
}
