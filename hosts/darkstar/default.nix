{ lib, pkgs, ... }: {
  imports = [ ../../users/ahmet ];

  home = {
    uid = 1000;
    packages = with pkgs; [
      xorg.setxkbmap
      # rustup 
    ];
  };

  programs = {
    git.userEmail = lib.mkForce "ozgezer@gmail.com";
  };
}
