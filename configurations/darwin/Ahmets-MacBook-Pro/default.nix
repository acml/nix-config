# Darwin configuration for Ahmets-MacBook-Pro
{
  flake,
  lib,
  pkgs,
  ...
}:
let
  inherit (flake) self;
in
{
  imports = [
    # Internal modules via flake outputs
    self.darwinModules.default
    self.darwinModules.users-ahmet
    self.darwinModules.graphical
  ];

  # Host-specific home-manager user config
  home-manager.users.ahmet = {
    imports = [ self.homeModules.trusted ];
    # c.f. https://github.com/danth/stylix/issues/865
    nixpkgs.overlays = lib.mkForce null;
    # programs.git.settings.gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
  };

  # Platform
  nixpkgs.hostPlatform = "x86_64-darwin";

  # Host-specific configuration
  networking = {
    computerName = "Ahmets-MacBook-Pro";
    hostName = "Ahmets-MacBook-Pro";
  };

  nix = {
    gc.automatic = true;
    linux-builder = {
      enable = true;
      ephemeral = true;
      config = {
        imports = [ self.nixosModules.nix ];
        virtualisation.host.pkgs = lib.mkForce (
          pkgs.extend (final: _: { nix = final.nixVersions.latest; })
        );
      };
      maxJobs = 2;
      protocol = "ssh-ng";
    };
    settings = {
      max-substitution-jobs = 2;
      # system-features = [
      #   "big-parallel"
      #   "gccarch-armv8-a"
      # ];
      trusted-users = [ "ahmet" ];
    };
  };

  users.users.ahmet = {
    uid = 501;
    gid = 20;
  };

  system.primaryUser = "ahmet";

  ids.gids.nixbld = 350;
}
