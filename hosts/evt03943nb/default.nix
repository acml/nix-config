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
    git.userEmail = lib.mkForce "ahmet.ozgezer@siemens.com";
  };
}
