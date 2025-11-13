{ lib, pkgs, ... }:
{
  imports = [ ../../users/ahmet ];

  home = {
    uid = 1000;
    packages = with pkgs; [
      git-dt
      samba
      xorg.setxkbmap
    ];
  };

  programs = {
    git.settings.user.email = lib.mkForce "ahmet.ozgezer@siemens.com";
    docker-cli = {
      enable = true;
      settings = {
        "detachKeys" = "ctrl-z,z";
      };
    };
  };
}
