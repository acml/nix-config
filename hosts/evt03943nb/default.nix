{ lib, pkgs, ... }:
{
  imports = [ ../../users/ahmet ];

  home = {
    uid = 1000;
    packages = with pkgs; [
      xorg.setxkbmap
    ];
  };

  programs = {
    git.settings.user.email = lib.mkForce "ahmet.ozgezer@siemens.com";
  };
}
