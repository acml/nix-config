{ lib, pkgs, ... }:
{
  imports = [ ../../users/ahmet ];

  home = {
    uid = 1000;
    packages = with pkgs; [
      xorg.setxkbmap
      # rustup
    ];
  };

  programs = {
    git.settings.user.email = lib.mkForce "ozgezer@gmail.com";
  };
}
